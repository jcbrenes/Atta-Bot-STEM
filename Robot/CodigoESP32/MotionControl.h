#pragma once
#include <cmath>
#include <cstdint>
#include <initializer_list>

// Control independiente de Arduino: las mismas funciones se prueban en PC.
namespace atta {
inline float clamp(float x, float lo, float hi) { return x < lo ? lo : (x > hi ? hi : x); }
constexpr float pi = 3.14159265358979323846f;
struct DriveCalibration {
  float start = 60, sustain = 0, feedforward = 0; // PWM, PWM, PWM/(mm/s)
};
struct WheelConfig {
  float ppr = 820, radius = 22;
  float kp = 2, ki = 0.8f, kd = 0; // integral/derivada en segundos
  DriveCalibration forward, reverse;
};
struct MotionConfig {
  uint32_t version = 2;
  WheelConfig right, left;
  float track = 120, speed = 90, turnSpeed = 60;
  float acceleration = 120, deceleration = 180;
  float syncGain = 1, maxPWM = 200, tolerance = 0.5f;
  float filterMs = 50, stallMs = 1500, startMs = 200;
};
enum class Fault { None, RightStall, LeftStall, Timeout, Timing, Config };
inline const char* faultName(Fault f) {
  switch (f) {
    case Fault::RightStall: return "RIGHT_STALL";
    case Fault::LeftStall: return "LEFT_STALL";
    case Fault::Timeout: return "TIMEOUT";
    case Fault::Timing: return "CONTROL_LATE";
    case Fault::Config: return "CONFIG";
    default: return "NONE";
  }
}
inline bool within(float x, float lo, float hi) { return std::isfinite(x) && x >= lo && x <= hi; }
inline bool validWheel(const WheelConfig& w, float maxPWM) {
  if (!within(w.ppr, 1, 100000) || !within(w.radius, 5, 100) ||
      !within(w.kp, 0, 100) || !within(w.ki, 0, 100) || !within(w.kd, 0, 10)) return false;
  for (const auto* d : {&w.forward, &w.reverse}) {
    if (!within(d->start, 0, maxPWM) || !within(d->sustain, 0, d->start) ||
        !within(d->feedforward, 0, 10)) return false;
  }
  return true;
}
inline bool validConfig(const MotionConfig& c) {
  return c.version == 2 && within(c.maxPWM, 1, 255) && validWheel(c.right, c.maxPWM) &&
    validWheel(c.left, c.maxPWM) && within(c.track, 40, 400) &&
    within(c.speed, 10, 300) && within(c.turnSpeed, 10, 300) &&
    within(c.acceleration, 10, 1000) && within(c.deceleration, 10, 1000) &&
    within(c.syncGain, 0, 10) && within(c.tolerance, 0.1f, 5) &&
    within(c.filterMs, 0, 200) && within(c.stallMs, 300, 5000) &&
    within(c.startMs, 0, 500) && c.startMs < c.stallMs;
}
inline void migrateGains(WheelConfig& w, float kp, float ki, float kd) {
  w.kp = kp;
  w.ki = ki * 0.4f; // 0.01 s anterior / 0.025 s nominal
  w.kd = kd * 0.025f;
}
struct WheelState {
  uint32_t origin = 0, previous = 0, lastProgress = 0;
  float distance = 0, speed = 0, reference = 0, integral = 0, previousSpeed = 0;
  int pwm = 0;
  bool saturated = false, arrived = false;
};
inline int wheelPWM(const WheelConfig& c, const DriveCalibration& d, WheelState& s,
                    float dt, float maxPWM, bool starting) {
  if (s.reference <= 0) { s.integral = 0; s.previousSpeed = s.speed; s.saturated = false; return 0; }
  const float error = s.reference - s.speed;
  // Derivada de la medición: no produce impulso al cambiar la referencia.
  const float derivative = -(s.speed - s.previousSpeed) / dt;
  s.previousSpeed = s.speed;
  const float base = d.feedforward * s.reference;
  const float candidate = clamp(s.integral + c.ki * error * dt, -maxPWM, maxPWM);
  const float raw = base + c.kp * error + candidate + c.kd * derivative;
  const float floor = error > 0 ? (starting ? d.start : d.sustain) : 0;
  const float output = clamp(raw, floor, maxPWM);
  // Solo integrar si no profundiza saturación superior o inferior.
  if ((raw >= floor && raw <= maxPWM) || (raw > maxPWM && error < 0) ||
      (raw < floor && error > 0)) s.integral = candidate;
  s.saturated = raw > maxPWM || raw < floor;
  return static_cast<int>(output);
}
struct Controller {
  WheelState right, left;
  bool active = false, turning = false, reverse = false;
  Fault fault = Fault::None;
  uint32_t previousTime = 0, startTime = 0, timeoutMs = 0;
  float target = 0, dt = 0;

  bool rightReverse() const { return turning ? !reverse : reverse; }
  bool leftReverse() const { return reverse; }

  void stop() {
    active = false;
    right.pwm = left.pwm = 0;
    right.integral = left.integral = 0;
    right.reference = left.reference = 0;
  }
  void fail(Fault f) { fault = f; stop(); }
  void clear() { stop(); fault = Fault::None; }
  bool begin(float amount, bool turn, uint32_t now, uint32_t r, uint32_t l,
             const MotionConfig& c) {
    stop();
    if (fault != Fault::None) return false;
    if (!validConfig(c) || !std::isfinite(amount) || std::fabs(amount) > 10000) {
      fail(Fault::Config); return false;
    }
    right = WheelState{}; left = WheelState{};
    right.origin = right.previous = r; left.origin = left.previous = l;
    right.lastProgress = left.lastProgress = now;
    previousTime = startTime = now;
    dt = 0; turning = turn; reverse = amount < 0;
    target = std::fabs(amount) * (turn ? pi * c.track / 360.0f : 1.0f);
    const float nominal = turn ? c.turnSpeed : c.speed;
    timeoutMs = static_cast<uint32_t>(clamp(5000 + 4000 * target / nominal, 5000, 120000));
    active = target > c.tolerance;
    return active;
  }
  static void sample(WheelState& s, const WheelConfig& c, uint32_t ticks,
                     uint32_t now, float dt, float filterMs) {
    const uint32_t delta = ticks - s.previous; // resta modular: contador nunca se reinicia
    s.previous = ticks;
    if (delta || s.pwm == 0) s.lastProgress = now;
    const float mmPerTick = 2 * pi * c.radius / c.ppr;
    s.distance = (ticks - s.origin) * mmPerTick;
    const float rawSpeed = delta * mmPerTick / dt;
    s.speed += dt / (filterMs / 1000 + dt) * (rawSpeed - s.speed);
  }
  bool update(uint32_t now, uint32_t r, uint32_t l, const MotionConfig& c) {
    if (!active) return false;
    const uint32_t elapsed = now - previousTime;
    if (elapsed < 25) return false;
    if (elapsed > 250) { fail(Fault::Timing); return true; }
    if (now - startTime > timeoutMs) { fail(Fault::Timeout); return true; }
    previousTime = now; dt = elapsed / 1000.0f;
    sample(right, c.right, r, now, dt, c.filterMs);
    sample(left, c.left, l, now, dt, c.filterMs);
    right.arrived = right.arrived || target - right.distance <= c.tolerance;
    left.arrived = left.arrived || target - left.distance <= c.tolerance;
    if (right.arrived && left.arrived) { stop(); return true; }
    if (!right.arrived && now - right.lastProgress >= c.stallMs) { fail(Fault::RightStall); return true; }
    if (!left.arrived && now - left.lastProgress >= c.stallMs) { fail(Fault::LeftStall); return true; }
    const float limit = turning ? c.turnSpeed : c.speed;
    const float correction = clamp(c.syncGain * (right.distance - left.distance), -limit / 2, limit / 2);
    reference(right, c, clamp(limit - correction, 0, limit));
    reference(left, c, clamp(limit + correction, 0, limit));
    // Sentidos físicos: recta +/-; giro positivo derecha atrás e izquierda adelante.
    right.pwm = wheelPWM(c.right, rightReverse() ? c.right.reverse : c.right.forward,
                         right, dt, c.maxPWM, now - startTime < c.startMs && right.distance == 0);
    left.pwm = wheelPWM(c.left, leftReverse() ? c.left.reverse : c.left.forward,
                        left, dt, c.maxPWM, now - startTime < c.startMs && left.distance == 0);
    return true;
  }
  void reference(WheelState& s, const MotionConfig& c, float requested) {
    if (s.arrived) { s.reference = 0; return; }
    const float remaining = clamp(target - s.distance, 0, target);
    const float braking = std::sqrt(2 * c.deceleration * remaining);
    const float desired = clamp(requested, 0, braking);
    s.reference = clamp(desired, s.reference - c.deceleration * dt,
                       s.reference + c.acceleration * dt);
    // Nunca mantener más velocidad que la admitida por distancia restante.
    s.reference = clamp(s.reference, 0, braking);
  }
};
} // namespace atta

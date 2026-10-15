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
// Valores por defecto: los más repetidos entre los Attas calibrados (hoja control-attas, 2026-10-15),
// con velocidad y aceleraciones del escalón 2 validado en V-02 (octágono 20 cm: 1.2 cm de cierre).
struct MotionConfig {
  uint32_t version = 2;
  WheelConfig right, left;
  float track = 120, speed = 150, turnSpeed = 120;
  float acceleration = 350, deceleration = 400;
  float syncGain = 1, maxPWM = 230, tolerance = 0.5f;
  float filterMs = 50, stallMs = 1500, startMs = 200;
};
// Perfil separado: mantiene intacto el formato binario motionV2 ya instalado.
struct TurnConfig {
  uint32_t version = 1;
  float acceleration = 120, deceleration = 120;
  float approachSpeed = 40, approachDistance = 5; // mm/s y mm por rueda
};
enum class Fault { None, RightStall, LeftStall, Timeout, Timing, Config, Settling };
inline const char* faultName(Fault f) {
  switch (f) {
    case Fault::RightStall: return "RIGHT_STALL";
    case Fault::LeftStall: return "LEFT_STALL";
    case Fault::Timeout: return "TIMEOUT";
    case Fault::Timing: return "CONTROL_LATE";
    case Fault::Config: return "CONFIG";
    case Fault::Settling: return "NOT_SETTLED";
    default: return "NONE";
  }
}
inline bool within(float x, float lo, float hi) { return std::isfinite(x) && x >= lo && x <= hi; }
inline bool validTurnConfig(const TurnConfig& c) {
  return c.version == 1 && within(c.acceleration, 10, 1000) &&
    within(c.deceleration, 10, 1000) && within(c.approachSpeed, 5, 100) &&
    within(c.approachDistance, 1, 100);
}
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
  bool settling = false, turnSettled = false, turnOvershoot = false;
  TurnConfig turnProfile;
  uint32_t settleStart = 0, lastSettlePulse = 0;
  float rightAtCutoff = 0, leftAtCutoff = 0;
  Fault fault = Fault::None;
  uint32_t previousTime = 0, startTime = 0, timeoutMs = 0;
  float target = 0, dt = 0;

  bool rightReverse() const { return turning ? !reverse : reverse; }
  bool leftReverse() const { return reverse; }

  void stop() {
    active = false;
    settling = false;
    right.pwm = left.pwm = 0;
    right.integral = left.integral = 0;
    right.reference = left.reference = 0;
  }
  void fail(Fault f) { fault = f; stop(); }
  void clear() { stop(); fault = Fault::None; }
  bool begin(float amount, bool turn, uint32_t now, uint32_t r, uint32_t l,
             const MotionConfig& c, const TurnConfig& turnConfig = TurnConfig{}) {
    stop();
    turnSettled = turnOvershoot = false;
    if (fault != Fault::None) return false;
    if (!validConfig(c) || !validTurnConfig(turnConfig) || !std::isfinite(amount) || std::fabs(amount) > 10000) {
      fail(Fault::Config); return false;
    }
    right = WheelState{}; left = WheelState{};
    right.origin = right.previous = r; left.origin = left.previous = l;
    right.lastProgress = left.lastProgress = now;
    previousTime = startTime = now;
    dt = 0; turning = turn; reverse = amount < 0;
    turnProfile = turnConfig;
    rightAtCutoff = leftAtCutoff = 0;
    target = std::fabs(amount) * (turn ? pi * c.track / 360.0f : 1.0f);
    const float nominal = turn ? c.turnSpeed : c.speed;
    timeoutMs = static_cast<uint32_t>(clamp(5000 + 4000 * target / nominal, 5000, 120000));
    if (turn) {
      // Incluir el tramo lento en el presupuesto, especialmente en giros cortos.
      const float slow = clamp(turnProfile.approachDistance, 0, target);
      const float cruise = std::fmin(nominal, turnProfile.approachSpeed);
      timeoutMs = static_cast<uint32_t>(clamp(5000 + 4000 *
        ((target - slow) / nominal + slow / cruise), 5000, 120000));
    }
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
    if (!settling && now - startTime > timeoutMs) { fail(Fault::Timeout); return true; }
    previousTime = now; dt = elapsed / 1000.0f;
    const bool newPulses = r != right.previous || l != left.previous;
    sample(right, c.right, r, now, dt, c.filterMs);
    sample(left, c.left, l, now, dt, c.filterMs);
    if (settling) {
      if (newPulses) lastSettlePulse = now;
      // Reposo observado en encoders, no garantia de ausencia de deslizamiento.
      if (now - settleStart >= 500 && now - lastSettlePulse >= 150) {
        turnSettled = true;
        turnOvershoot = right.distance > target + c.tolerance || left.distance > target + c.tolerance;
        stop();
      } else if (now - settleStart >= 2000) {
        fail(Fault::Settling);
      }
      return true;
    }
    right.arrived = right.arrived || target - right.distance <= c.tolerance;
    left.arrived = left.arrived || target - left.distance <= c.tolerance;
    if (right.arrived && left.arrived) {
      if (turning) {
        rightAtCutoff = right.distance; leftAtCutoff = left.distance;
        right.pwm = left.pwm = 0;
        right.reference = left.reference = right.integral = left.integral = 0;
        settling = true; settleStart = lastSettlePulse = now;
      } else stop();
      return true;
    }
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
    const float accel = turning ? turnProfile.acceleration : c.acceleration;
    const float decel = turning ? turnProfile.deceleration : c.deceleration;
    const float braking = std::sqrt(2 * decel * remaining);
    // Llegar al tramo final lento mediante una rampa, no un salto de referencia.
    const float approach = !turning ? requested :
      (remaining < turnProfile.approachDistance ?
       turnProfile.approachSpeed * std::sqrt(remaining / turnProfile.approachDistance) :
       std::sqrt(turnProfile.approachSpeed * turnProfile.approachSpeed +
         2 * decel * (remaining - turnProfile.approachDistance)));
    const float desired = clamp(requested, 0, std::fmin(braking, approach));
    s.reference = clamp(desired, s.reference - decel * dt,
                       s.reference + accel * dt);
    // Nunca mantener más velocidad que la admitida por distancia restante.
    s.reference = clamp(s.reference, 0, braking);
  }
};
} // namespace atta

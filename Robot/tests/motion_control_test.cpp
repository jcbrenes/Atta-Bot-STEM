#include "../CodigoESP32/MotionControl.h"
#include <cassert>
#include <iostream>
#include <limits>

using namespace atta;
int main() {
  MotionConfig c;
  // Perfil conservador fijo: las cotas de la planta simulada se ajustaron con él,
  // no con los valores por defecto de campo (que pueden cambiar).
  c.speed = 90; c.turnSpeed = 60; c.acceleration = 120; c.deceleration = 180; c.maxPWM = 200;
  assert(validConfig(c));
  WheelConfig legacy;
  migrateGains(legacy, 2, 2, 0.4f);
  assert(std::fabs(legacy.ki - 0.8f) < 1e-6f);
  assert(std::fabs(legacy.kd - 0.01f) < 1e-6f);
  auto bad = c; bad.right.ppr = 0; assert(!validConfig(bad));
  bad = c; bad.left.kp = std::numeric_limits<float>::quiet_NaN(); assert(!validConfig(bad));
  bad = c; bad.right.forward.sustain = 61; assert(!validConfig(bad));

  // Mismo error durante un segundo, independiente del período real.
  WheelConfig w; w.kp = 0; w.ki = 1;
  DriveCalibration d; d.start = d.sustain = 0;
  WheelState a, b; a.reference = b.reference = 10;
  for (int i = 0; i < 40; ++i) wheelPWM(w, d, a, .025f, 200, false);
  for (int i = 0; i < 20; ++i) wheelPWM(w, d, b, .05f, 200, false);
  assert(std::fabs(a.integral - b.integral) < 1e-5f);
  assert(std::fabs(a.integral - 10) < 1e-5f);

  // Saturación sostenida no acumula integral; exceso de velocidad permite cero.
  w.kp = 10; a = WheelState{}; a.reference = 100;
  for (int i = 0; i < 1000; ++i) assert(wheelPWM(w, d, a, .025f, 200, false) == 200);
  assert(a.integral == 0);
  a.speed = 200; assert(wheelPWM(w, d, a, .025f, 200, false) == 0);
  a.reference = 0; assert(wheelPWM(w, d, a, .025f, 200, false) == 0 && a.integral == 0);

  Controller m;
  assert(!m.begin(0, false, 100, 42, 52, c));
  assert(m.right.pwm == 0 && m.left.pwm == 0);
  assert(m.begin(300, false, 10000, 42, 52, c));
  assert(!m.update(10024, 42, 52, c));
  assert(m.update(10025, 42, 52, c));
  assert(std::fabs(m.dt - .025f) < 1e-6f);
  assert(m.right.reference <= c.acceleration * .025f);
  assert(m.right.pwm > 0 && m.left.pwm > 0);
  m.stop();
  assert(m.right.pwm == 0 && m.right.integral == 0 && !m.active);
  // Reiniciar desde contadores no nulos y tras pausa: ninguna velocidad negativa.
  assert(m.begin(-90, true, 20000, 1000, 3000, c));
  assert(m.turning && m.reverse);
  assert(!m.rightReverse() && m.leftReverse());
  m.update(20025, 1001, 3001, c);
  assert(m.right.speed > 0 && m.left.speed > 0);
  assert(m.right.pwm > 0 && m.left.pwm > 0);

  // El promedio no puede completar una orden con una rueda inmóvil.
  c.filterMs = 0;
  m.clear(); m.begin(10, false, 0, 0, 0, c);
  m.update(25, 120, 0, c);
  assert(m.active && m.right.arrived && !m.left.arrived && m.right.pwm == 0);
  m.update(50, 120, 60, c);
  assert(!m.active && m.right.pwm == 0 && m.left.pwm == 0);

  // Una rueda adelanta: reducir su referencia. Frenar al acercarse al objetivo.
  m.begin(300, false, 0, 0, 0, c);
  for (uint32_t t = 25; t <= 1000; t += 25) m.update(t, t / 2, t / 2 - 1, c);
  m.update(1025, 550, 505, c);
  assert(m.right.reference < m.left.reference);
  m.update(1050, 1760, 1750, c);
  assert(m.right.reference < c.speed);
  assert(m.right.reference <= std::sqrt(2*c.deceleration*(m.target-m.right.distance))+.001f);

  // Detección independiente y fallo enclavado hasta CLEAR.
  m.clear(); m.begin(500, false, 0, 0, 0, c);
  for (uint32_t t = 25; t <= 1700 && m.active; t += 25) m.update(t, 0, t / 2, c);
  assert(m.fault == Fault::RightStall && m.right.pwm == 0 && m.left.pwm == 0);
  assert(!m.begin(100, false, 2000, 0, 100, c));
  m.clear(); assert(m.begin(100, false, 2000, 0, 100, c));
  m.update(2251, 0, 100, c);
  assert(m.fault == Fault::Timing && !m.active);

  // Wrap de millis y cuentas: las restas deben ser modulares.
  m.clear(); m.begin(100, false, UINT32_MAX - 10, UINT32_MAX - 2, UINT32_MAX - 2, c);
  m.update(14, 2, 2, c);
  assert(m.fault == Fault::None && m.right.distance > .8f && m.right.distance < .9f);

  // Timeout aunque ambos encoders produzcan algo de avance (sin stall).
  m.clear(); m.begin(100, false, 0, 0, 0, c);
  for (uint32_t t = 25; t <= 10000 && m.active; t += 25) m.update(t, t/1000, t/1000, c);
  assert(m.fault == Fault::Timeout);
  m.clear(); m.begin(90, true, 0, 0, 0, c);
  assert(m.rightReverse() && !m.leftReverse());
  m.stop(); m.begin(-100, false, 0, 0, 0, c);
  assert(m.rightReverse() && m.leftReverse());
  m.stop(); m.begin(100, false, 0, 0, 0, c);
  assert(!m.rightReverse() && !m.leftReverse());
  for (uint32_t t = 25; t <= 1700 && m.active; t += 25) m.update(t, t / 4, 0, c);
  assert(m.fault == Fault::LeftStall);

  // Planta simulada con dos motores diferentes, fricción y retardo.
  // Comprueba terminación/rampas; no sustituye calibración física.
  TurnConfig simTurn; simTurn.approachSpeed = 20; simTurn.approachDistance = 20;
  for (bool turn : {false, true}) for (float amount : {100.f, -100.f, 300.f}) {
    m.clear(); m.begin(amount, turn, 0, 0, 0, c, simTurn);
    float rDistance = 0, lDistance = 0, rSpeed = 0, lSpeed = 0;
    for (uint32_t t = 25; t <= 20000 && m.active; t += 25) {
      const float rTarget = std::fmax(0.f, (m.right.pwm - 35.f) * 1.1f);
      const float lTarget = std::fmax(0.f, (m.left.pwm - 45.f) * .9f);
      rSpeed += .2f * (rTarget - rSpeed); lSpeed += .15f * (lTarget - lSpeed);
      rDistance += rSpeed * .025f; lDistance += lSpeed * .025f;
      m.update(t, static_cast<uint32_t>(rDistance * c.right.ppr / (2*pi*c.right.radius)),
                  static_cast<uint32_t>(lDistance * c.left.ppr / (2*pi*c.left.radius)), c);
    }
    assert(!m.active && m.fault == Fault::None);
    assert(std::fabs(m.right.distance - m.target) < 2);
    assert(std::fabs(m.left.distance - m.target) < 2);
  }
  std::cout << "motion_control_test: OK\n";
}

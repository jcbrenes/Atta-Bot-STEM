#include "../CodigoESP32/MotionControl.h"
#include <cassert>
#include <iostream>
using namespace atta;
uint32_t ticks(float mm, const WheelConfig& c) {
  return uint32_t(std::ceil(mm * c.ppr / (2*pi*c.radius)));
}
int main() {
  MotionConfig c; TurnConfig tc; Controller m;
  c.right.ppr = 822; c.left.ppr = 808;
  c.speed = 110; c.turnSpeed = 90; c.acceleration = 250; c.deceleration = 300;
  c.maxPWM = 230;
  auto invalid = tc; invalid.approachSpeed = 0;
  assert(!m.begin(90, true, 0, 0, 0, c, invalid));
  assert(m.fault == Fault::Config); m.clear();
  // Rampas de giro independientes de las rectas; misma geometria y sentidos.
  assert(m.begin(90, true, 0, 0, 0, c, tc)); m.update(25, 0, 0, c);
  assert(std::fabs(m.target - pi*c.track/4) < .001f);
  assert(m.right.reference <= tc.acceleration*.025f + .001f);
  assert(m.rightReverse() && !m.leftReverse());
  m.begin(100, false, 0, 0, 0, c, tc); m.update(25, 0, 0, c);
  assert(std::fabs(m.right.reference - c.acceleration*.025f) < .001f);
  // Llegar no significa estar quieto: medir pulsos tras cortar PWM.
  m.begin(-90, true, 0, 0, 0, c, tc);
  const auto r = ticks(m.target, c.right), l = ticks(m.target, c.left);
  m.update(25, r, l, c);
  assert(m.active && m.settling && !m.turnSettled && m.right.pwm == 0 && m.left.pwm == 0);
  const float cutoff = m.rightAtCutoff;
  for (uint32_t t = 50; t <= 525; t += 25) m.update(t, r + t/25, l, c);
  assert(m.active && m.right.distance > cutoff);
  for (uint32_t t = 550; t <= 675; t += 25) m.update(t, r + 21, l, c);
  assert(!m.active && m.turnSettled && m.turnOvershoot && m.fault == Fault::None);
  // Nueva maniobra no hereda llegada/reposo, STOP termina tambien SETTLE.
  m.begin(90, true, 1000, r+21, l, c, tc);
  assert(!m.settling && !m.turnSettled && !m.turnOvershoot);
  m.update(1025, 2*r+21, 2*l, c); assert(m.settling);
  m.stop(); assert(!m.active && !m.settling && m.right.pwm == 0);
  // Limite de asentamiento: no afirmar COMPLETE con pulsos continuos.
  m.begin(90, true, 0, 0, 0, c, tc); m.update(25, r, l, c);
  for (uint32_t t = 50; t <= 2025; t += 25) m.update(t, r+t/25, l, c);
  assert(!m.active && m.fault == Fault::Settling && !m.turnSettled);
  // Wrap de millis durante asentamiento y terminacion estable sin exceso.
  m.clear(); const uint32_t start = UINT32_MAX - 100;
  m.begin(90, true, start, 0, 0, c, tc); m.update(start+25, r, l, c);
  for (uint32_t elapsed = 50; elapsed <= 525; elapsed += 25) m.update(start+elapsed, r, l, c);
  assert(m.turnSettled && !m.turnOvershoot && m.fault == Fault::None);
  // Giros de distintos tamaños/sentidos con planta e inercia tras terminacion.
  float worst = 0;
  for (float response : {.1f, .2f, .4f}) for (float angle : {45.f, 90.f, -90.f, 180.f}) {
    m.clear(); m.begin(angle, true, 0, 0, 0, c, tc);
    float rd=0, ld=0, rv=0, lv=0;
    auto plant = [&]() {
      rv += response * (std::fmax(0.f, (m.right.pwm-35)*1.1f)-rv);
      lv += response*.75f * (std::fmax(0.f, (m.left.pwm-45)*.9f)-lv);
      rd += rv*.025f; ld += lv*.025f;
    };
    for (uint32_t t=25; t<20000 && m.active; t+=25) {
      plant();
      m.update(t, uint32_t(rd*c.right.ppr/(2*pi*c.right.radius)),
                  uint32_t(ld*c.left.ppr/(2*pi*c.left.radius)), c);
    }
    assert(m.turnSettled && !m.active && m.fault == Fault::None);
    assert(m.turnOvershoot == (m.right.distance > m.target+c.tolerance || m.left.distance > m.target+c.tolerance));
    for (int i=0; i<20; ++i) plant();
    const float error = std::fabs((rd+ld)*180/(pi*c.track)-std::fabs(angle));
    worst = std::fmax(worst, error);
    assert(error < 3); // cota de esta planta hipotetica, NO especificacion fisica
  }
  std::cout << "turn_control_test: OK, worst simulated error=" << worst << " deg\n";
}

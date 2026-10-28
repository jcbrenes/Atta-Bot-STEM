// Diagnostico reproducible del controlador real con una planta hipotetica.
// No representa mediciones de un Atta ni modela deslizamiento/contacto del lapiz.
#include "../CodigoESP32/MotionControl.h"
#include <cstdio>
#include <cmath>

//***************************************************************************************
// Simula giros con el controlador real y una planta hipotética e imprime un CSV.
//
// Barre respuesta de la planta, ángulo y período de control, y reporta ángulo al cortar,
// al terminar y 500 ms después, para ver cuánto se pasa el giro por inercia. Sirve para
// comparar cambios del controlador, no para calibrar un robot. Ver Auditoria_giros_V2.md.
//
// @return 0.
//***************************************************************************************
int main() {
  using namespace atta;
  MotionConfig c;
  c.right.ppr = 822; c.left.ppr = 808;
  c.speed = 110; c.turnSpeed = 90;
  c.acceleration = 250; c.deceleration = 300; c.maxPWM = 230;
  // track=120 es el valor del codigo: el usuario no ha proporcionado su track.
  std::puts("response,angle,dt_ms,fault,finish_ms,model_deg_at_cutoff,encoder_deg_at_finish,model_deg_at_finish,model_deg_after_500ms,r_speed_at_finish,l_speed_at_finish,overshoot");
  for (float response : {.1f, .2f, .4f})
    for (float angle : {45.f, 90.f, -90.f, 180.f})
      for (unsigned step : {25u, 50u}) {
        Controller m;
        m.begin(angle, true, 0, 0, 0, c);
        float rd = 0, ld = 0, rv = 0, lv = 0;
        unsigned t = 0;
        float cutoffAngle = 0;
        bool sawCutoff = false;
        auto plant = [&]() {
          // Misma familia de planta que motion_control_test, con dt normalizado.
          const float ar = 1 - std::pow(1 - response, step / 25.f);
          const float al = 1 - std::pow(1 - response * .75f, step / 25.f);
          rv += ar * (std::fmax(0.f, (m.right.pwm - 35.f) * 1.1f) - rv);
          lv += al * (std::fmax(0.f, (m.left.pwm - 45.f) * .9f) - lv);
          rd += rv * step / 1000.f; ld += lv * step / 1000.f;
        };
        while (m.active && t < 20000) {
          t += step; plant();
          m.update(t, uint32_t(rd * c.right.ppr / (2*pi*c.right.radius)),
                      uint32_t(ld * c.left.ppr / (2*pi*c.left.radius)), c);
          if (m.settling && !sawCutoff) {
            sawCutoff = true;
            cutoffAngle = (rd+ld)*180/(pi*c.track);
          }
        }
        const float factor = 180 / (pi * c.track);
        const float encAngle = (m.right.distance + m.left.distance) * factor;
        const float stopAngle = (rd + ld) * factor;
        const float stopR = rv, stopL = lv;
        for (unsigned settle = 0; settle < 500; settle += step) plant();
        std::printf("%.2f,%.0f,%u,%s,%u,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%d\n",
          response, angle, step, faultName(m.fault), t, cutoffAngle, encAngle, stopAngle,
          (rd + ld) * factor, stopR, stopL, m.turnOvershoot);
      }
}

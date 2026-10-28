// Valida la calculadora del cuadrado contra el controlador real del firmware:
// una planta con geometría "verdadera" distinta a la configurada genera las
// mediciones; la corrección estimada debe cerrar el cuadrado.
#include "../CodigoESP32/MotionControl.h"
#include "../tools/CalibracionCuadrado.h"
#include <cassert>
#include <cmath>
#include <cstdio>

using namespace atta;

// Chasis físico: no cambia al reconfigurar el firmware.
struct Chasis { double mmPulsoR, mmPulsoL, via; };

// kR/kL respecto a la configuración original del firmware.
Chasis chasis(const cuadrado::Errores& e, const MotionConfig& original) {
  return {e.kR * 2 * pi * original.right.radius / original.right.ppr,
          e.kL * 2 * pi * original.left.radius / original.left.ppr, e.via};
}

struct Planta {
  Chasis real;
  cuadrado::Pose pose;
  double vR = 0, vL = 0, restoR = 0, restoL = 0;
  uint32_t ticksR = 0, ticksL = 0;

  void paso(const Controller& m, double dt) {
    const double sR = m.rightReverse() ? -1 : 1, sL = m.leftReverse() ? -1 : 1;
    const double objR = sR * std::fmax(0, (m.right.pwm - 20) * 1.2);
    const double objL = sL * std::fmax(0, (m.left.pwm - 25) * 1.1);
    vR += .5 * (objR - vR); vL += .5 * (objL - vL);
    const double dR = vR * dt, dL = vL * dt;
    cuadrado::tramo(pose, dR, dL, real.via);
    // Encoders sin sentido, como el firmware: solo magnitud.
    restoR += std::fabs(dR) / real.mmPulsoR; restoL += std::fabs(dL) / real.mmPulsoL;
    while (restoR >= 1) { ++ticksR; restoR -= 1; }
    while (restoL >= 1) { ++ticksL; restoL -= 1; }
  }
};

// Ejecuta el cuadrado con el controlador real y devuelve la posición final del lápiz.
cuadrado::Punto correr(const Chasis& real, const MotionConfig& c, float lado, bool horario) {
  Planta p{real, {}};
  TurnConfig t; t.approachSpeed = 40; t.approachDistance = 5;
  Controller m;
  uint32_t ms = 0;
  auto maniobra = [&](float cantidad, bool giro) {
    assert(m.begin(cantidad, giro, ms, p.ticksR, p.ticksL, c, t));
    while (m.active && ms < 600000) {
      ms += 5; p.paso(m, .005);
      m.update(ms, p.ticksR, p.ticksL, c);
    }
    assert(m.fault == Fault::None);
    for (int i = 0; i < 200; ++i) { ms += 5; p.paso(m, .005); } // reposo entre maniobras
  };
  for (int i = 0; i < 4; ++i) {
    maniobra(lado, false);
    maniobra(horario ? 90 : -90, true);
  }
  return {p.pose.x, p.pose.y};
}

int main() {
  // 1) El modelo puro devuelve exactamente los parámetros que lo generaron.
  {
    const cuadrado::Errores e{1.012, 0.988, 127};
    const auto h = cuadrado::cuadrado(e, 120, 500, true, 30);
    const auto a = cuadrado::cuadrado(e, 120, 500, false, 30);
    const auto r = cuadrado::estimar(h, a, 120, 500, 30);
    assert(r.convergio && r.residuoRMS < 1e-6);
    assert(std::fabs(r.errores.kR - e.kR) < 1e-9 && std::fabs(r.errores.via - e.via) < 1e-6);
    // Sin errores: robot ideal, cierra el cuadrado.
    const auto ideal = cuadrado::cuadrado({1, 1, 120}, 120, 500, true, 30);
    assert(std::hypot(ideal.x, ideal.y) < 1e-9);
  }

  // 2) Controlador real del firmware con un chasis distinto al configurado.
  MotionConfig c;
  c.right.ppr = c.left.ppr = 820; c.track = 120;
  c.speed = 110; c.turnSpeed = 90; c.acceleration = 250; c.deceleration = 300; c.maxPWM = 230;
  const cuadrado::Errores real{1.008, 0.992, 126};
  const Chasis fisico = chasis(real, c);
  const float lado = 500;
  const auto h = correr(fisico, c, lado, true), a = correr(fisico, c, lado, false);
  const double antes = std::fmax(std::hypot(h.x, h.y), std::hypot(a.x, a.y));
  const auto est = cuadrado::estimar(h, a, c.track, lado, 0);
  assert(est.convergio);
  const auto corr = cuadrado::corregir(est.errores, c.right.ppr, c.left.ppr);
  std::printf("antes: cw=(%.1f,%.1f) ccw=(%.1f,%.1f) | estimado kR=%.4f kL=%.4f via=%.2f residuo=%.2f\n",
    h.x, h.y, a.x, a.y, est.errores.kR, est.errores.kL, est.errores.via, est.residuoRMS);
  // Los signos (qué rueda, qué sentido) deben coincidir con el firmware real.
  assert(est.errores.kR > est.errores.kL);
  assert(std::fabs(est.errores.via - real.via) < 3);

  MotionConfig c2 = c;
  c2.right.ppr = corr.rppr; c2.left.ppr = corr.lppr; c2.track = corr.track;
  const auto h2 = correr(fisico, c2, lado, true), a2 = correr(fisico, c2, lado, false);
  const double despues = std::fmax(std::hypot(h2.x, h2.y), std::hypot(a2.x, a2.y));
  std::printf("despues: cw=(%.1f,%.1f) ccw=(%.1f,%.1f) | cierre %.1f -> %.1f mm\n",
    h2.x, h2.y, a2.x, a2.y, antes, despues);
  assert(antes > 40 && despues < antes * 0.25);
  std::puts("square_calibration_test OK");
}

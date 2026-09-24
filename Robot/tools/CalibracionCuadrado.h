#pragma once
// Prueba del cuadrado (UMBmark, Borenstein y Feng 1996) para odometría de dos ruedas.
// Separa los dos errores sistemáticos que un giro aislado confunde:
//   - track efectivo distinto al configurado (error igual en ambos sentidos);
//   - escala distinta entre ruedas, es decir, la proporción rppr/lppr
//     (curva las rectas y cambia de signo entre horario y antihorario).
// Mantiene la escala media de distancia: las rectas ya calibradas no cambian.
#include <cmath>

namespace cuadrado {
constexpr double pi = 3.14159265358979323846;

// Marco de medición: origen en el punto de partida del lápiz,
// x = hacia donde mira el robot al empezar, y = hacia su izquierda.
struct Punto { double x = 0, y = 0; };
struct Pose { double x = 0, y = 0, rumbo = 0; }; // rumbo antihorario positivo

// Recorrido real de cada rueda en mm (con signo) sobre la vía real.
inline void tramo(Pose& p, double dR, double dL, double via) {
  const double giro = (dR - dL) / via, avance = (dR + dL) / 2;
  if (std::fabs(giro) < 1e-12) {
    p.x += avance * std::cos(p.rumbo); p.y += avance * std::sin(p.rumbo);
  } else {
    const double r = avance / giro;
    p.x += r * (std::sin(p.rumbo + giro) - std::sin(p.rumbo));
    p.y -= r * (std::cos(p.rumbo + giro) - std::cos(p.rumbo));
  }
  p.rumbo += giro;
}

// Robot real frente a lo que cree el firmware.
// kR/kL: mm reales por cada mm que el firmware cree haber recorrido en esa rueda.
struct Errores { double kR = 1, kL = 1, via = 120; };

// Cuatro veces: avanzar `lado` mm y girar 90°. horario = giros a la derecha.
// `lapiz`: mm del lápiz por delante del centro del eje (negativo si va detrás).
inline Punto cuadrado(const Errores& e, double trackFirmware, double lado,
                      bool horario, double lapiz) {
  Pose p;
  const double porRueda = (pi / 2) * trackFirmware / 2; // mm que el firmware manda por rueda
  for (int i = 0; i < 4; ++i) {
    tramo(p, e.kR * lado, e.kL * lado, e.via);
    // Firmware: giro derecho = rueda derecha atrás, izquierda adelante.
    const double s = horario ? 1 : -1;
    tramo(p, -s * e.kR * porRueda, s * e.kL * porRueda, e.via);
  }
  return {p.x + lapiz * (std::cos(p.rumbo) - 1), p.y + lapiz * std::sin(p.rumbo)};
}

struct Resultado {
  Errores errores;       // estimación del robot real
  double residuoRMS = 0; // mm que el modelo no explica (ruido, deslizamiento, medición)
  bool convergio = false;
};

// Ajuste por mínimos cuadrados (Gauss-Newton) de 2 incógnitas con 4 mediciones:
// delta = (kR - kL) / 2 con kR + kL = 2, y la vía efectiva.
inline Resultado estimar(Punto horario, Punto antihorario, double trackFirmware,
                         double lado, double lapiz) {
  double delta = 0, via = trackFirmware;
  auto residuos = [&](double d, double v, double r[4]) {
    const Errores e{1 + d, 1 - d, v};
    const Punto h = cuadrado(e, trackFirmware, lado, true, lapiz);
    const Punto a = cuadrado(e, trackFirmware, lado, false, lapiz);
    r[0] = h.x - horario.x; r[1] = h.y - horario.y;
    r[2] = a.x - antihorario.x; r[3] = a.y - antihorario.y;
  };
  Resultado out;
  for (int it = 0; it < 50; ++it) {
    double r[4], rd[4], rv[4];
    const double hd = 1e-6, hv = 1e-4 * trackFirmware;
    residuos(delta, via, r);
    residuos(delta + hd, via, rd);
    residuos(delta, via + hv, rv);
    double a = 0, b = 0, c = 0, gd = 0, gv = 0; // JtJ = [[a b][b c]], Jt r = [gd gv]
    for (int i = 0; i < 4; ++i) {
      const double jd = (rd[i] - r[i]) / hd, jv = (rv[i] - r[i]) / hv;
      a += jd * jd; b += jd * jv; c += jv * jv; gd += jd * r[i]; gv += jv * r[i];
    }
    const double det = a * c - b * b;
    if (!(std::fabs(det) > 0)) break;
    const double pasoD = -(c * gd - b * gv) / det, pasoV = -(a * gv - b * gd) / det;
    delta += pasoD; via += pasoV;
    if (!std::isfinite(delta) || !std::isfinite(via) || via <= 0) break;
    if (std::fabs(pasoD) < 1e-10 && std::fabs(pasoV) < 1e-7) { out.convergio = true; break; }
  }
  double r[4], suma = 0;
  residuos(delta, via, r);
  for (double x : r) suma += x * x;
  out.errores = {1 + delta, 1 - delta, via};
  out.residuoRMS = std::sqrt(suma / 4);
  out.convergio = out.convergio && std::isfinite(out.residuoRMS);
  return out;
}

// Nuevos valores del firmware: mm por pulso = mm reales por pulso, track = vía real.
struct Correccion { double rppr, lppr, track; };
inline Correccion corregir(const Errores& e, double rppr, double lppr) {
  return {rppr / e.kR, lppr / e.kL, e.via};
}
} // namespace cuadrado

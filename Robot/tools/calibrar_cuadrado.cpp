// Calculadora de la prueba del cuadrado: de mediciones físicas a líneas SET.
// Uso: calibrar_cuadrado <archivo>   (ver ejemplo_cuadrado.txt y Calibracion_cuadrado.md)
#include "CalibracionCuadrado.h"
#include <cmath>
#include <cstdio>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

namespace {
struct Serie {
  std::vector<cuadrado::Punto> puntos;
  cuadrado::Punto media() const {
    cuadrado::Punto m;
    for (const auto& p : puntos) { m.x += p.x; m.y += p.y; }
    m.x /= puntos.size(); m.y /= puntos.size();
    return m;
  }
  // Distancia típica de cada corrida a la media: error aleatorio del robot.
  double dispersion() const {
    if (puntos.size() < 2) return NAN;
    const auto m = media();
    double s = 0;
    for (const auto& p : puntos) s += (p.x - m.x) * (p.x - m.x) + (p.y - m.y) * (p.y - m.y);
    return std::sqrt(s / (puntos.size() - 1));
  }
};

std::string minusculas(std::string s) {
  for (auto& c : s) c = std::tolower(static_cast<unsigned char>(c));
  return s;
}
} // namespace

int main(int argc, char** argv) {
  if (argc != 2) {
    std::fprintf(stderr, "Uso: %s <archivo de mediciones>\n", argv[0]);
    return 2;
  }
  std::ifstream in(argv[1]);
  if (!in) { std::fprintf(stderr, "No se pudo abrir %s\n", argv[1]); return 2; }

  std::string robot = "(sin nombre)";
  double rppr = NAN, lppr = NAN, track = NAN, lado = NAN, lapiz = 0;
  Serie horario, antihorario;
  std::string linea;
  for (int n = 1; std::getline(in, linea); ++n) {
    const auto hash = linea.find('#');
    if (hash != std::string::npos) linea.erase(hash);
    std::istringstream ss(linea);
    std::string clave;
    if (!(ss >> clave)) continue;
    clave = minusculas(clave);
    if (clave == "set" && !(ss >> clave)) continue; // acepta la salida de SHOW tal cual
    clave = minusculas(clave);
    if (clave == "robot" || clave == "device") { ss >> robot; continue; }
    double a, b;
    if (!(ss >> a)) continue; // otras líneas de SHOW (CONFIG, texto) se ignoran
    if (clave == "rppr") rppr = a;
    else if (clave == "lppr") lppr = a;
    else if (clave == "track") track = a;
    else if (clave == "lado") lado = a;
    else if (clave == "lapiz") lapiz = a;
    else if (clave == "cw" || clave == "horario" || clave == "ccw" || clave == "antihorario") {
      if (!(ss >> b)) { std::fprintf(stderr, "Línea %d: faltan x y\n", n); return 2; }
      (clave == "cw" || clave == "horario" ? horario : antihorario).puntos.push_back({a, b});
    }
  }
  if (!(rppr > 0 && lppr > 0 && track > 0 && lado > 0) ||
      horario.puntos.empty() || antihorario.puntos.empty()) {
    std::fprintf(stderr, "Faltan datos: rppr, lppr, track, lado y al menos una corrida horario y antihorario.\n");
    return 2;
  }

  const auto h = horario.media(), a = antihorario.media();
  const auto r = cuadrado::estimar(h, a, track, lado, lapiz);
  if (!r.convergio) { std::puts("ERROR: el ajuste no convergió. Revise signos y unidades (mm)."); return 1; }
  const auto e = r.errores;
  const auto c = cuadrado::corregir(e, rppr, lppr);

  std::printf("Robot %s | lado %.0f mm | lapiz %+.0f mm | corridas: %zu horario, %zu antihorario\n\n",
    robot.c_str(), lado, lapiz, horario.puntos.size(), antihorario.puntos.size());
  std::printf("Cierre medido (x adelante, y izquierda):\n");
  std::printf("  horario     x=%+7.1f  y=%+7.1f  -> %.1f mm", h.x, h.y, std::hypot(h.x, h.y));
  if (std::isfinite(horario.dispersion())) std::printf("  (dispersion %.1f mm)", horario.dispersion());
  std::printf("\n  antihorario x=%+7.1f  y=%+7.1f  -> %.1f mm", a.x, a.y, std::hypot(a.x, a.y));
  if (std::isfinite(antihorario.dispersion())) std::printf("  (dispersion %.1f mm)", antihorario.dispersion());

  const double giro = 90 * track / e.via;
  const double desvio1m = 1e6 * (e.kR - e.kL) / (2 * e.via); // mm laterales tras 1 m
  std::printf("\n\nDiagnostico:\n");
  std::printf("  Giros: cada 90 grados gira %.2f grados (%+.2f)\n", giro, giro - 90);
  std::printf("  Rectas: rueda %s recorre %.2f%% mas; se desvia %.1f mm hacia la %s por metro\n",
    e.kR >= e.kL ? "derecha" : "izquierda", 100 * std::fabs(e.kR / e.kL - 1), std::fabs(desvio1m),
    e.kR >= e.kL ? "izquierda" : "derecha");
  std::printf("  No explicado por el modelo: %.1f mm (deslizamiento, medicion, rueda loca)\n", r.residuoRMS);

  bool dudoso = false;
  if (std::fabs(e.kR - 1) > 0.03 || std::fabs(e.via / track - 1) > 0.15) {
    std::puts("\nAVISO: correccion muy grande. Revise signos de x/y, unidades (mm) y el lado del cuadrado;");
    std::puts("       si las mediciones son correctas, sospeche de encoders o motores antes de calibrar.");
    dudoso = true;
  }
  const double medido = std::fmax(std::hypot(h.x, h.y), std::hypot(a.x, a.y));
  if (r.residuoRMS > 0.3 * medido && medido > 10) {
    std::puts("\nAVISO: el modelo explica mal las mediciones (error aleatorio dominante).");
    std::puts("       Repita 3 corridas por sentido; corregir no mejorara mucho este robot.");
    dudoso = true;
  }
  if (!(c.track >= 40 && c.track <= 400 && c.rppr >= 1 && c.lppr >= 1)) {
    std::puts("\nERROR: valores fuera del rango aceptado por el firmware. No aplicar.");
    return 1;
  }

  std::printf("\n%s en modo DEV (anterior -> nuevo):\n", dudoso ? "Valores propuestos (revisar avisos antes de aplicar)" : "Aplicar");
  std::printf("SET rppr %.1f     # %.1f\n", c.rppr, rppr);
  std::printf("SET lppr %.1f     # %.1f\n", c.lppr, lppr);
  std::printf("SET track %.2f    # %.2f\n", c.track, track);
  std::puts("\nDespues: VERIFY y repetir un cuadrado en cada sentido para confirmar.");
  return 0;
}

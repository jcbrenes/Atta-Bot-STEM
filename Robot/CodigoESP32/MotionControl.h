//***************************************************************************************
// Controlador de movimiento V2 (controller=3): rectas y giros con encoders.
//
// Todo está en el namespace atta y no usa nada de Arduino, así que se compila y prueba en PC
// (tests/motion_control_test.cpp, tests/turn_control_test.cpp). MotionRuntime.h es la capa
// que lo conecta al hardware: lee los encoders, llama a Controller cada vuelta de loop() y
// aplica el PWM que calcula.
//
// Cómo se mueve el robot:
// 1. Controller.begin convierte la orden (mm o grados) en una distancia objetivo por rueda.
// 2. Cada 25 ms Controller.update mide distancia y velocidad de cada rueda (Controller.sample),
//    calcula la velocidad de referencia con rampas de aceleración y frenado
//    (Controller.reference), la corrige para que las dos ruedas avancen parejas (sync) y
//    obtiene el PWM de cada rueda con un PI por rueda (wheelPWM).
// 3. Cada rueda se detiene al llegar a su distancia; en los giros, además, se espera a que
//    las ruedas queden quietas (asentamiento) para informar si el giro se pasó.
// 4. Si algo no cuadra (rueda trabada, tiempo agotado, configuración inválida) se detiene y
//    deja un Fault que MotionRuntime.h informa por Serial.
//
// Unidades: mm, mm/s, mm/s², ms; PWM de 0 a 255. Guía completa: Control_movimiento_V2.md.
//***************************************************************************************
#pragma once
#include <cmath>
#include <cstdint>
#include <initializer_list>

// Control independiente de Arduino: las mismas funciones se prueban en PC.
namespace atta {
//***************************************************************************************
// Limita x al intervalo [lo, hi].
//***************************************************************************************
inline float clamp(float x, float lo, float hi) { return x < lo ? lo : (x > hi ? hi : x); }
// pi en float, para no depender de M_PI.
constexpr float pi = 3.14159265358979323846f;
//***************************************************************************************
// Compensación de la zona muerta de un motor en un sentido (adelante o atrás).
//
// - start (SET rfstart/rrstart/lfstart/lrstart): PWM mínimo para que la rueda arranque desde
//   quieta. Solo se aplica durante los primeros startms y mientras la rueda no se haya movido.
//   Se mide con el comando MOTOR: el menor PWM que la mueve.
// - sustain (SET rfhold/rrhold/lfhold/lrhold): PWM mínimo mientras la rueda va más lenta de lo
//   pedido, ya en marcha. No puede superar a start.
// - feedforward (SET rfff/rrff/lfff/lrff): PWM por cada mm/s de velocidad pedida, sumado antes
//   de la corrección del PI. En 0 mientras no haya una curva PWM/velocidad medida.
//***************************************************************************************
struct DriveCalibration {
  float start = 60, sustain = 0, feedforward = 0; // PWM, PWM, PWM/(mm/s)
};
//***************************************************************************************
// Calibración de una rueda: geometría, ganancias del PI y zona muerta por sentido.
//
// ppr son las cuentas del encoder por vuelta de rueda (se cuentan los flancos de A y B, x4) y
// radius el radio efectivo en mm; juntos dan los mm por cuenta (2·pi·radius/ppr). En la
// práctica radius se deja en 22 y se calibra ppr (CalibracionMotores o prueba del cuadrado).
//
// Ganancias (por rueda: SET rkp/rki/rkd, lkp/lki/lkd; kp/ki/kd para las dos):
// - kp: PWM por cada mm/s de error de velocidad.
// - ki: PWM por cada mm acumulado de error (error·segundos).
// - kd: sobre la derivada de la velocidad medida, en segundos; se deja en 0.
// Están en segundos desde V2; las del firmware anterior se convierten con migrateGains.
//***************************************************************************************
struct WheelConfig {
  float ppr = 820, radius = 22;
  float kp = 2, ki = 0.8f, kd = 0; // integral/derivada en segundos
  DriveCalibration forward, reverse;
};
//***************************************************************************************
// Perfil de movimiento completo de un Atta; se guarda tal cual en la clave NVS "motionV2".
//
// - version: formato del bloque binario; validConfig exige 2.
// - right/left: calibración de cada rueda (WheelConfig).
// - track (SET track): separación efectiva entre ruedas en mm; convierte grados en mm de arco
//   por rueda. Si todos los giros quedan cortos o largos, es el track.
// - speed / turnSpeed: velocidad de crucero de rectas y de giros, mm/s.
// - acceleration / deceleration (SET accel/decel): rampas de las rectas, mm/s². Los giros usan
//   las de TurnConfig.
// - syncGain (SET sync): mm/s que se le quitan a la rueda adelantada (y se le dan a la
//   atrasada) por cada mm de diferencia de recorrido entre las dos.
// - maxPWM: tope de PWM que entrega el controlador.
// - tolerance: mm que le pueden faltar a una rueda para darla por llegada.
// - filterMs: constante de tiempo del filtro de la velocidad medida, ms.
// - stallMs: ms sin cuentas con PWM aplicado para declarar la rueda trabada.
// - startMs: ventana inicial en la que se aplica el PWM de arranque (start).
//
// Si se agrega o reordena un miembro cambia el bloque binario: los perfiles guardados dejarían
// de leerse (loadConfig los rechaza por tamaño o por version). Hay que subir version y migrar.
//
// Valores por defecto: los más repetidos entre los Attas calibrados (hoja control-attas, 2026-10-15),
// con velocidad y aceleraciones del escalón 2 validado en V-02 (octágono 20 cm: 1.2 cm de cierre).
//***************************************************************************************
struct MotionConfig {
  uint32_t version = 2;
  WheelConfig right, left;
  float track = 120, speed = 150, turnSpeed = 120;
  float acceleration = 350, deceleration = 400;
  float syncGain = 1, maxPWM = 230, tolerance = 0.5f;
  float filterMs = 50, stallMs = 1500, startMs = 200;
};
//***************************************************************************************
// Perfil de giro; se guarda en la clave NVS "turnV1", aparte de motionV2.
//
// - acceleration / deceleration (SET turnaccel/turndecel): rampas de los giros, mm/s².
// - approachSpeed (SET turnapproach): velocidad en el tramo final del giro, mm/s.
// - approachDistance (SET turnzone): últimos mm por rueda que se recorren a approachSpeed.
//   Este tramo lento es lo que da precisión al ángulo.
//***************************************************************************************
struct TurnConfig {
  uint32_t version = 1;
  float acceleration = 120, deceleration = 120;
  float approachSpeed = 40, approachDistance = 5; // mm/s y mm por rueda
};
//***************************************************************************************
// Motivo por el que se abortó una maniobra (o None).
//
// RightStall/LeftStall: una rueda con PWM no contó pulsos en stallMs. Timeout: la maniobra
// tardó más que el presupuesto de begin. Timing: loop() tardó más de 250 ms entre dos
// controles. Config: perfil inválido o salidas PWM no listas. Settling: tras un giro las
// ruedas no quedaron quietas en 2 s.
//***************************************************************************************
enum class Fault { None, RightStall, LeftStall, Timeout, Timing, Config, Settling };
//***************************************************************************************
// Nombre del fallo tal como sale en los mensajes FAULT, TURN_RESULT y la telemetría.
//
// @param f Fallo.
//
// @return Texto fijo en mayúsculas ("RIGHT_STALL", "CONTROL_LATE", ...).
//***************************************************************************************
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
//***************************************************************************************
// Dice si x es un número finito dentro de [lo, hi]. Base de todas las validaciones de rango.
//***************************************************************************************
inline bool within(float x, float lo, float hi) { return std::isfinite(x) && x >= lo && x <= hi; }
//***************************************************************************************
// Valida el perfil de giro: version 1 y cada campo dentro de su rango.
//
// Rangos: rampas 10..1000 mm/s², approachSpeed 5..100 mm/s, approachDistance 1..100 mm.
//
// @param c Perfil de giro.
//
// @return true si se puede usar y guardar.
//***************************************************************************************
inline bool validTurnConfig(const TurnConfig& c) {
  return c.version == 1 && within(c.acceleration, 10, 1000) &&
    within(c.deceleration, 10, 1000) && within(c.approachSpeed, 5, 100) &&
    within(c.approachDistance, 1, 100);
}
//***************************************************************************************
// Valida la calibración de una rueda.
//
// Rangos: ppr 1..100000, radius 5..100 mm, kp y ki 0..100, kd 0..10; por sentido, start
// 0..maxPWM, sustain 0..start y feedforward 0..10.
//
// @param w Calibración de la rueda.
// @param maxPWM Tope de PWM del perfil, para acotar start.
//
// @return true si todos los campos están en rango.
//***************************************************************************************
inline bool validWheel(const WheelConfig& w, float maxPWM) {
  if (!within(w.ppr, 1, 100000) || !within(w.radius, 5, 100) ||
      !within(w.kp, 0, 100) || !within(w.ki, 0, 100) || !within(w.kd, 0, 10)) return false;
  for (const auto* d : {&w.forward, &w.reverse}) {
    if (!within(d->start, 0, maxPWM) || !within(d->sustain, 0, d->start) ||
        !within(d->feedforward, 0, 10)) return false;
  }
  return true;
}
//***************************************************************************************
// Valida el perfil de movimiento completo antes de usarlo o guardarlo.
//
// Rangos: maxPWM 1..255, track 40..400 mm, speed y turnSpeed 10..300 mm/s, rampas
// 10..1000 mm/s², syncGain 0..10, tolerance 0.1..5 mm, filterMs 0..200, stallMs 300..5000,
// startMs 0..500 y menor que stallMs; más validWheel para cada rueda.
//
// @param c Perfil de movimiento.
//
// @return true si se puede usar y guardar.
//***************************************************************************************
inline bool validConfig(const MotionConfig& c) {
  return c.version == 2 && within(c.maxPWM, 1, 255) && validWheel(c.right, c.maxPWM) &&
    validWheel(c.left, c.maxPWM) && within(c.track, 40, 400) &&
    within(c.speed, 10, 300) && within(c.turnSpeed, 10, 300) &&
    within(c.acceleration, 10, 1000) && within(c.deceleration, 10, 1000) &&
    within(c.syncGain, 0, 10) && within(c.tolerance, 0.1f, 5) &&
    within(c.filterMs, 0, 200) && within(c.stallMs, 300, 5000) &&
    within(c.startMs, 0, 500) && c.startMs < c.stallMs;
}
//***************************************************************************************
// Convierte las ganancias del firmware anterior a V2 (ganancias en segundos).
//
// El firmware viejo integraba y derivaba por muestra con un período de 0.01 s; V2 usa segundos
// con un período nominal de 0.025 s. kp no cambia, ki se multiplica por 0.4 y kd por 0.025.
// Es una conversión de unidades, no garantiza la misma respuesta: hay que validar en el robot.
//
// @param w Rueda cuyas ganancias se escriben.
// @param kp Ganancia proporcional anterior.
// @param ki Ganancia integral anterior.
// @param kd Ganancia derivativa anterior.
//***************************************************************************************
inline void migrateGains(WheelConfig& w, float kp, float ki, float kd) {
  w.kp = kp;
  w.ki = ki * 0.4f; // 0.01 s anterior / 0.025 s nominal
  w.kd = kd * 0.025f;
}
//***************************************************************************************
// Estado de una rueda durante una maniobra.
//
// origin es la cuenta del encoder al empezar y previous la de la muestra anterior: los
// contadores de las interrupciones nunca se reinician, cada maniobra toma un origen nuevo.
// lastProgress es la última vez que la rueda contó pulsos (para detectar traba). distance
// (mm desde origin), speed (mm/s filtrada), reference (mm/s pedida), integral (PWM acumulado
// del PI), pwm (salida), saturated (el PI pidió más de lo que se puede dar) y arrived (ya
// recorrió su distancia; queda en true hasta el final de la maniobra).
//***************************************************************************************
struct WheelState {
  uint32_t origin = 0, previous = 0, lastProgress = 0;
  float distance = 0, speed = 0, reference = 0, integral = 0, previousSpeed = 0;
  int pwm = 0;
  bool saturated = false, arrived = false;
};
//***************************************************************************************
// Calcula el PWM de una rueda para seguir su velocidad de referencia (PI con extras).
//
// PWM = feedforward·referencia + kp·error + integral + kd·derivada, donde error es
// referencia − velocidad medida y la derivada se toma de la medición (no salta al cambiar la
// referencia). El resultado se limita entre un piso y maxPWM: si la rueda va lenta, el piso es
// el PWM de arranque (start) o de sostén (sustain) para vencer la zona muerta del motor; si va
// rápida, 0. Anti-windup: la integral solo se actualiza si no empuja más hacia una saturación.
// Con referencia 0 devuelve 0 y vacía la integral.
//
// @param c Calibración de la rueda (ganancias).
// @param d Zona muerta del sentido en que gira la rueda ahora.
// @param s Estado de la rueda; actualiza integral, previousSpeed y saturated.
// @param dt Período de control en s.
// @param maxPWM Tope de PWM.
// @param starting true durante la ventana de arranque si la rueda aún no se movió.
//
// @return PWM entre 0 y maxPWM.
//***************************************************************************************
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
//***************************************************************************************
// Controlador de una maniobra (recta o giro) para las dos ruedas.
//
// Hay una sola instancia, motion, en MotionRuntime.h. Ciclo de vida: begin → update en cada
// vuelta de loop() hasta que active pasa a false → (si hubo fallo) clear antes de la próxima.
// Mientras fault no sea None, begin se niega a empezar otra maniobra.
//
// Banderas: turning (giro o recta), reverse (orden negativa), settling (giro terminado,
// observando que las ruedas se detengan), turnSettled/turnOvershoot (resultado del giro),
// rightAtCutoff/leftAtCutoff (recorrido al cortar el PWM, para medir cuánto se deslizó).
//***************************************************************************************
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

  //***************************************************************************************
  // Sentido físico de la rueda derecha: en los giros va al revés que la izquierda.
  //
  // Giro positivo (TURN 90) = derecha atrás e izquierda adelante: el robot gira a la derecha.
  //
  // @return true si la rueda derecha debe ir hacia atrás.
  //***************************************************************************************
  bool rightReverse() const { return turning ? !reverse : reverse; }
  //***************************************************************************************
  // Sentido de la rueda izquierda: atrás solo si la orden es negativa.
  //
  // @return true si la rueda izquierda debe ir hacia atrás.
  //***************************************************************************************
  bool leftReverse() const { return reverse; }

  //***************************************************************************************
  // Termina la maniobra: PWM, referencias e integrales a cero. No borra el fallo.
  //***************************************************************************************
  void stop() {
    active = false;
    settling = false;
    right.pwm = left.pwm = 0;
    right.integral = left.integral = 0;
    right.reference = left.reference = 0;
  }
  //***************************************************************************************
  // Aborta la maniobra dejando registrado el motivo.
  //
  // @param f Fallo que se informará.
  //***************************************************************************************
  void fail(Fault f) { fault = f; stop(); }
  //***************************************************************************************
  // Detiene y borra el fallo; lo usa el comando CLEAR y el reintento tras un fallo recuperable.
  //***************************************************************************************
  void clear() { stop(); fault = Fault::None; }
  //***************************************************************************************
  // Prepara una maniobra nueva a partir de la orden.
  //
  // En una recta el objetivo por rueda es |amount| mm. En un giro es el arco que recorre cada
  // rueda alrededor del centro: |amount|·pi·track/360 mm. El signo de amount solo define el
  // sentido (reverse). Calcula también el tiempo máximo: 5 s más 4 veces el tiempo nominal a
  // velocidad de crucero (en giros contando el tramo lento), entre 5 y 120 s.
  //
  // No arranca si hay un fallo sin despejar; si la configuración o la orden es inválida, deja
  // Fault::Config. Una orden menor que tolerance no mueve nada (active queda en false).
  //
  // @param amount Distancia en mm (recta) o ángulo en grados (giro); negativo = atrás/izquierda.
  // @param turn true para giro.
  // @param now millis() actual.
  // @param r Cuenta actual del encoder derecho (se toma como origen).
  // @param l Cuenta actual del encoder izquierdo.
  // @param c Perfil de movimiento.
  // @param turnConfig Perfil de giro.
  //
  // @return true si quedó una maniobra activa.
  //***************************************************************************************
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
  //***************************************************************************************
  // Mide una rueda: distancia desde el origen y velocidad filtrada.
  //
  // La diferencia de cuentas se resta en módulo 2^32, así que funciona aunque el contador
  // desborde. La velocidad pasa por un filtro paso bajo de primer orden con constante filterMs.
  // Si la rueda contó pulsos (o no tiene PWM) se actualiza lastProgress, que usa la detección de
  // traba.
  //
  // @param s Estado de la rueda a actualizar.
  // @param c Calibración de la rueda (ppr y radius → mm por cuenta).
  // @param ticks Cuenta actual del encoder.
  // @param now millis() actual.
  // @param dt Tiempo desde la muestra anterior, s.
  // @param filterMs Constante del filtro de velocidad, ms.
  //***************************************************************************************
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
  //***************************************************************************************
  // Un paso de control; se llama en cada vuelta de loop() y actúa cada 25 ms o más.
  //
  // Orden: revisa tiempos (más de 250 ms entre pasos → Timing; maniobra más larga que timeoutMs
  // → Timeout), mide las dos ruedas, marca las que llegaron y, cuando llegan las dos, termina
  // (recta) o pasa a asentamiento (giro). Si no, revisa trabas (stallMs sin pulsos → Stall),
  // reparte la velocidad entre las ruedas según cuál va adelantada (syncGain) y calcula el PWM
  // de cada una.
  //
  // Asentamiento de giros: con PWM en cero sigue midiendo hasta que pasen 500 ms y 150 ms sin
  // pulsos nuevos; entonces marca turnSettled y si alguna rueda pasó objetivo + tolerance,
  // turnOvershoot. Si en 2 s no se quedan quietas → Settling. Que no haya pulsos no prueba que
  // el chasis no se deslizó.
  //
  // @param now millis() actual.
  // @param r Cuenta actual del encoder derecho.
  // @param l Cuenta actual del encoder izquierdo.
  // @param c Perfil de movimiento.
  //
  // @return true si en esta llamada cambió algo (hay que aplicar right.pwm y left.pwm).
  //***************************************************************************************
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
  //***************************************************************************************
  // Calcula la velocidad de referencia de una rueda: perfil trapezoidal con frenado.
  //
  // La velocidad pedida se limita por la de frenado sqrt(2·decel·restante), para poder parar
  // justo en el objetivo, y en los giros además por la curva de aproximación: baja hasta
  // approachSpeed al entrar a los últimos approachDistance mm y dentro de ellos sigue bajando
  // con la raíz de lo que falta. El cambio respecto a la referencia anterior se limita a
  // accel·dt al subir y decel·dt al bajar. Rectas: rampas de MotionConfig; giros: de TurnConfig.
  //
  // @param s Estado de la rueda; escribe s.reference.
  // @param c Perfil de movimiento.
  // @param requested Velocidad pedida para esta rueda (crucero ± corrección de sync), mm/s.
  //***************************************************************************************
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

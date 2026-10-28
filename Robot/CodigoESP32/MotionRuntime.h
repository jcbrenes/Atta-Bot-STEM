//***************************************************************************************
// Capa de hardware del movimiento y consola de calibración por Serial.
//
// Conecta el controlador de MotionControl.h con el robot: lee los encoders, escribe el PWM del
// puente H, ejecuta las órdenes MOVE/TURN de la máquina de estados, informa fallos y
// telemetría, y atiende el modo desarrollador (DEV) del Monitor Serie con el que se calibra.
//
// Se incluye dentro de CodigoESP32.ino después de los pines y la máquina de estados, porque
// usa sus variables globales (estado, pines de motores, banderas del programa BLE).
// tests/runtime_test.cpp lo compila en PC con stubs de Arduino.
//
// Comandos de la consola: ver processSerialCommand y Guia_parametros_SET.md.
//***************************************************************************************
#pragma once
// Única instancia del controlador: la comparten MOVE/TURN de los programas, el modo DEV y MOTOR.
atta::Controller motion;
bool motorOutputsReady = false;
// true si el movimiento en curso lo pidió la consola (MOVE/TURN por Serial), no un programa BLE.
bool diagnosticMove = false;
float diagnosticAmount = 0;
bool telemetryEnabled = false;
uint32_t lastTelemetry = 0;
int appliedRightPWM = 0, appliedLeftPWM = 0;
// Prueba en lazo abierto del comando MOTOR: una rueda a PWM fijo durante motorTestDuration ms.
bool motorTestActive = false, motorTestRight = true;
uint32_t motorTestStart = 0, motorTestDuration = 0, motorTestProgress = 0, motorTestTicks = 0;

//***************************************************************************************
// Copia los dos contadores de encoder de forma coherente con las interrupciones.
//
// Los contadores son de 32 bits y los incrementan las ISR; se leen dentro de la sección
// crítica encoderMux para que derecha e izquierda correspondan al mismo instante.
//
// @param r Salida: cuenta del encoder derecho.
// @param l Salida: cuenta del encoder izquierdo.
//***************************************************************************************
void readEncoderCounts(uint32_t& r, uint32_t& l) {
  portENTER_CRITICAL(&encoderMux);
  r = rightEncoderPos; l = leftEncoderPos;
  portEXIT_CRITICAL(&encoderMux);
}

//***************************************************************************************
// Escribe el PWM y el sentido de las dos ruedas en el puente H.
//
// Cada motor tiene dos pines (M1 adelante, M2 atrás): primero se pone en 0 el pin del sentido
// contrario y después se escribe el PWM en el del sentido pedido, así nunca quedan los dos
// activos. Siempre se escriben las dos ruedas. Guarda lo aplicado para la telemetría.
//
// @param rightReverse true si la rueda derecha va hacia atrás.
// @param leftReverse true si la rueda izquierda va hacia atrás.
// @param r PWM derecho (se limita a 0..255).
// @param l PWM izquierdo (se limita a 0..255).
//***************************************************************************************
void applyMotorOutputs(bool rightReverse, bool leftReverse, int r, int l) {
  r = constrain(r, 0, 255); l = constrain(l, 0, 255);
  // Apagar el pin opuesto antes de activar el nuevo sentido.
  ledcWrite(rightReverse ? rightMotorM1 : rightMotorM2, 0);
  ledcWrite(leftReverse ? leftMotorM1 : leftMotorM2, 0);
  ledcWrite(rightReverse ? rightMotorM2 : rightMotorM1, r);
  ledcWrite(leftReverse ? leftMotorM2 : leftMotorM1, l);
  appliedRightPWM = r; appliedLeftPWM = l;
}

//***************************************************************************************
// Configura el PWM de los 4 pines de motores a motorPwmHz y 8 bits, y lo comprueba.
//
// Con la misma frecuencia y resolución el core asigna a los 4 pines un único temporizador
// LEDC, distinto del de los servos (50 Hz); por eso setup llama a esto después de reservar
// los servos. Lee la frecuencia real del temporizador (ledcTimerHz) y falla si se aleja más
// de 2 % de la pedida o si los pines quedaron en temporizadores distintos. Deja la frecuencia
// real en motorPwmActiveHz (la muestra SHOW).
//
// @return true si los 4 pines quedaron con la frecuencia pedida.
//***************************************************************************************
bool attachMotorPWM() {
  bool ok = true;
  motorPwmActiveHz = 0;
  for (int pin : {rightMotorM1, rightMotorM2, leftMotorM1, leftMotorM2}) {
    if (!ledcAttach(pin, motorPwmHz, motorPwmBits)) { ok = false; continue; }
    const uint32_t real = ledcTimerHz(pin);
    // El divisor del temporizador redondea; más del 2 % indica otra configuración.
    if (real == 0 || fabsf((float)real - motorPwmHz) > 0.02f * motorPwmHz) ok = false;
    if (!motorPwmActiveHz) motorPwmActiveHz = real;
    else if (real != motorPwmActiveHz) ok = false;
  }
  return ok;
}

//***************************************************************************************
// Detiene los motores ya: corta la maniobra, cancela la prueba MOTOR y pone PWM 0.
//
// No cambia el estado del programa; para un STOP completo está requestMotionStop.
//***************************************************************************************
void stopMotion() {
  motion.stop();
  motorTestActive = false;
  applyMotorOutputs(false, false, 0, 0);
}

//***************************************************************************************
// Dice si el robot está quieto y sin programa, condición para tocar la configuración.
//
// Se exige para SET, SHOW, MOVE, MOTOR, etc. (escribir en NVS o imprimir mucho mientras los
// motores actúan retrasaría el control) y para aceptar programas BLE nuevos.
//
// @return true si está en ESPERA, sin maniobra, sin prueba MOTOR, sin esperar la parada y sin
// recibir un programa.
//***************************************************************************************
bool calibrationIdle() {
  return estado == ESPERA && !motion.active && !motorTestActive && !waitingForStopSettle &&
    !recibeProgra && !flancoNegRecibeProgra;
}

//***************************************************************************************
// Reinicia el estado de flujo de un programa: ciclos, ramas IF/WHILE y detección de obstáculos.
//
// Un programa interrumpido (STOP u obstáculo) no llega a CIFIN/OBFIN; sin este reinicio el
// siguiente programa heredaría la detección activa y el contador de ciclos.
//***************************************************************************************
void resetProgramFlow() {
  primer_ciclo = true;
  obstaculos_activo = false;
  ignorarHastaIFFIN = ignorarHastaElse = ignorarHastaWHILEFIN = false;
  anidamientoWhile = anidamientoWhileIgnorar = anidamientoIF = anidamientoIFIgnorar = 0;
  for (int i = 0; i < 5; ++i) { indicesWhile[i] = 0; ejecutandoRamaIf[i] = false; }
}

//***************************************************************************************
// STOP completo: detiene motores y cancela el programa en curso.
//
// Lo usan PARAR por BLE, STOP por Serial, el fin de la prueba MOTOR y los fallos no
// recuperables. Marca paro_emergencia, borra el programa (inst_actual = inst_final = 0) y su
// flujo, y pasa a DETENERSE, que espera stopSettlingTime antes de volver a ESPERA.
//***************************************************************************************
void requestMotionStop() {
  stopMotion();
  paro_emergencia = true;
  obstaculo_detectado = false;
  flagParar = true;
  flagEjecucion = false;
  recibeProgra = flancoNegRecibeProgra = false;
  diagnosticMove = false;
  // Cancelar también bucles/bifurcaciones del programa interrumpido.
  resetProgramFlow();
  inst_actual = inst_final = 0;
  estado = DETENERSE;
}

//***************************************************************************************
// Informa un fallo del controlador por Serial (FAULT,<motivo>) y decide cómo seguir.
//
// Si el fallo es recuperable (rueda trabada, tiempo agotado, control atrasado o giro sin
// asentar) y viene de un programa BLE normal, se omite solo esa instrucción: se despeja el
// fallo, se pasa a DETENERSE y el programa sigue con la siguiente (PROGRAM_CONTINUE). Así un
// chico no pierde todo el programa porque una rueda rozó algo. En cualquier otro caso (fallo de
// configuración, movimiento de la consola, prueba MOTOR, STOP) se detiene todo con
// requestMotionStop y el fallo queda hasta un CLEAR.
//***************************************************************************************
void reportMotionFault() {
  Serial.printf("FAULT,%s\n", atta::faultName(motion.fault));
  const bool recoverable = motion.fault == atta::Fault::RightStall ||
    motion.fault == atta::Fault::LeftStall || motion.fault == atta::Fault::Timeout ||
    motion.fault == atta::Fault::Timing || motion.fault == atta::Fault::Settling;
  if (recoverable && (estado == MOVERSE || estado == GIRAR) &&
      !diagnosticMove && !motorTestActive && !paro_emergencia && !obstaculo_detectado &&
      configReady && motorOutputsReady) {
    // La instruccion ya fue consumida: conservar indices, ciclos y ramas.
    stopMotion();
    motion.clear();
    estado = DETENERSE; // el sketch espera asentamiento y vuelve a LEE_MEMORIA
    Serial.println("PROGRAM_CONTINUE: maniobra incompleta; se omite y sigue la siguiente instruccion.");
    return;
  }
  requestMotionStop();
}

//***************************************************************************************
// Con TELEMETRY ON, imprime una fila CSV del controlador cada 100 ms.
//
// Formato: T,ms,device,modo,reverse,dt,cuentas R y L,mm R y L,referencia R y L,velocidad R y L,
// PWM R y L,integral R y L,saturada R y L,fallo. modo es IDLE, MOVE, TURN, SETTLE o MOTOR.
// Las columnas están en COLUMNS de tools/capturar_movimiento.py, que la guarda en CSV.
// Si el buffer de Serial no tiene lugar se descarta la fila: nunca bloquea el control.
//***************************************************************************************
void emitTelemetry() {
  if (!telemetryEnabled || millis() - lastTelemetry < 100) return;
  lastTelemetry = millis();
  uint32_t r, l;
  readEncoderCounts(r, l);
  char row[384];
  const int length = snprintf(row, sizeof(row),
    "T,%lu,%s,%s,%d,%.4f,%lu,%lu,%.3f,%.3f,%.2f,%.2f,%.2f,%.2f,%d,%d,%.3f,%.3f,%d,%d,%s\n",
    (unsigned long)millis(), deviceName.c_str(), motorTestActive ? "MOTOR" :
      (motion.settling ? "SETTLE" : (motion.active ? (motion.turning ? "TURN" : "MOVE") : "IDLE")),
    motion.reverse, motion.dt, (unsigned long)r, (unsigned long)l,
    motion.right.distance, motion.left.distance, motion.right.reference, motion.left.reference,
    motion.right.speed, motion.left.speed, appliedRightPWM, appliedLeftPWM,
    motion.right.integral, motion.left.integral, motion.right.saturated, motion.left.saturated,
    atta::faultName(motion.fault));
  if (length > 0 && length < (int)sizeof(row) && Serial.availableForWrite() >= length)
    Serial.write((const uint8_t*)row, length); // descartar antes que bloquear el control
}

//***************************************************************************************
// Ejecuta una recta o un giro sin bloquear; la máquina de estados la llama en cada vuelta.
//
// En la primera llamada (sin maniobra activa) arranca la maniobra con motion.begin; en las
// siguientes avanza el control con motion.update y aplica el PWM. Al terminar un giro imprime
// TURN_RESULT (COMPLETE, OVERSHOOT o INCOMPLETE) con el ángulo estimado por los encoders, que
// no es una medición del chasis. Si hay paro_emergencia no hace nada; si la configuración no
// está lista o hay un fallo pendiente, lo informa con reportMotionFault.
//
// @param amount mm (recta) o grados (giro); negativo = atrás o a la izquierda.
// @param turning true para giro.
//
// @return true cuando la maniobra terminó (bien o con fallo) y se puede pasar a DETENERSE.
//***************************************************************************************
bool runMotion(float amount, bool turning) {
  if (paro_emergencia) return true;
  if (!configReady || !motorOutputsReady) { motion.fail(atta::Fault::Config); reportMotionFault(); return true; }
  if (motion.fault != atta::Fault::None) { reportMotionFault(); return true; }
  uint32_t r, l;
  readEncoderCounts(r, l);
  const uint32_t now = millis();
  if (!motion.active) {
    applyMotorOutputs(false, false, 0, 0);
    motion.begin(amount, turning, now, r, l, motionConfig, turnConfig);
    if (motion.fault != atta::Fault::None) reportMotionFault();
    return !motion.active;
  }
  if (motion.update(now, r, l, motionConfig)) {
    applyMotorOutputs(motion.rightReverse(), motion.leftReverse(), motion.right.pwm, motion.left.pwm);
    if (turning && !motion.active) {
      // Magnitud estimada por ruedas; no mide orientacion externa del chasis.
      const float angle = (motion.right.distance + motion.left.distance) * 180 / (atta::pi * motionConfig.track);
      Serial.printf("TURN_RESULT,%s,target_deg=%.3f,encoder_deg=%.3f,r_mm=%.3f,l_mm=%.3f,coast_r_mm=%.3f,coast_l_mm=%.3f,fault=%s\n",
        motion.fault != atta::Fault::None ? "INCOMPLETE" : (motion.turnOvershoot ? "OVERSHOOT" : "COMPLETE"),
        fabsf(amount), angle, motion.right.distance, motion.left.distance,
        motion.turnSettled || motion.fault == atta::Fault::Settling ? motion.right.distance - motion.rightAtCutoff : 0.f,
        motion.turnSettled || motion.fault == atta::Fault::Settling ? motion.left.distance - motion.leftAtCutoff : 0.f,
        atta::faultName(motion.fault));
    }
    if (motion.fault != atta::Fault::None) reportMotionFault();
  }
  return !motion.active;
}
//***************************************************************************************
// Recta de mm milímetros (negativo = atrás). Ver runMotion.
//
// @param mm Distancia.
//
// @return true al terminar.
//***************************************************************************************
bool advanceDesiredDistance(float mm) { return runMotion(mm, false); }
//***************************************************************************************
// Giro de degrees grados (positivo = derecha). Ver runMotion.
//
// @param degrees Ángulo.
//
// @return true al terminar.
//***************************************************************************************
bool turnDesiredAngle(float degrees) { return runMotion(degrees, true); }

//***************************************************************************************
// Avanza la prueba MOTOR en curso; se llama en cada vuelta de loop().
//
// Mide las ruedas cada 25 ms (para que la telemetría muestre la velocidad) sin ningún control:
// el PWM es fijo. Al cumplirse la duración imprime MOTOR_DONE con las cuentas y hace un STOP
// completo, para que la rueda se detenga antes de otra prueba o de invertir el sentido. Si la
// rueda probada no cuenta pulsos en stallMs, la declara trabada.
//***************************************************************************************
void updateMotorTest() {
  if (!motorTestActive) return;
  uint32_t r, l;
  readEncoderCounts(r, l);
  const uint32_t now = millis(), count = motorTestRight ? r : l;
  if (now - motion.previousTime >= 25) {
    motion.dt = (now - motion.previousTime) / 1000.0f;
    motion.previousTime = now;
    atta::Controller::sample(motion.right, motionConfig.right, r, now, motion.dt, motionConfig.filterMs);
    atta::Controller::sample(motion.left, motionConfig.left, l, now, motion.dt, motionConfig.filterMs);
  }
  if (count != motorTestTicks) { motorTestTicks = count; motorTestProgress = now; }
  if (now - motorTestStart >= motorTestDuration) {
    requestMotionStop(); // esperar asentamiento antes de otra prueba/inversión
    Serial.printf("MOTOR_DONE,%lu,%lu\n", (unsigned long)r, (unsigned long)l);
  } else if (now - motorTestProgress >= motionConfig.stallMs) {
    motion.fail(motorTestRight ? atta::Fault::RightStall : atta::Fault::LeftStall);
    reportMotionFault();
  }
}

//***************************************************************************************
// Arranca "MOTOR <R|L> <F|R> <PWM> <ms>": una rueda a PWM fijo, sin controlador.
//
// Sirve para calibrar la zona muerta: el menor PWM con el que la rueda arranca es el valor de
// SET ..start de esa rueda y sentido (ver DriveCalibration). Imprime MOTOR_BEGIN con las
// cuentas iniciales; restando las de MOTOR_DONE se obtienen las cuentas recorridas.
//
// @param command Línea en mayúsculas. Rueda R o L, sentido F (adelante) o R (atrás), PWM
// 0..maxPWM y duración 100..3000 ms.
//
// @return true si el formato y los rangos son válidos y la prueba arrancó.
//***************************************************************************************
bool startMotorTest(const String& command) {
  char wheel, direction, extra;
  int pwm, duration;
  if (sscanf(command.c_str(), "MOTOR %c %c %d %d %c", &wheel, &direction, &pwm, &duration, &extra) != 4 ||
      (wheel != 'R' && wheel != 'L') || (direction != 'F' && direction != 'R') ||
      pwm < 0 || pwm > motionConfig.maxPWM || duration < 100 || duration > 3000) return false;
  uint32_t r, l;
  readEncoderCounts(r, l);
  motion.clear();
  motorTestRight = wheel == 'R';
  motorTestTicks = motorTestRight ? r : l;
  motorTestStart = motorTestProgress = millis();
  motion.right = atta::WheelState{}; motion.left = atta::WheelState{};
  motion.right.origin = motion.right.previous = r;
  motion.left.origin = motion.left.previous = l;
  motion.previousTime = motorTestStart;
  motion.turning = false; motion.reverse = direction == 'R'; motion.dt = 0;
  motorTestDuration = duration;
  motorTestActive = true;
  Serial.printf("MOTOR_BEGIN,%lu,%lu\n", (unsigned long)r, (unsigned long)l);
  applyMotorOutputs(direction == 'R', direction == 'R', motorTestRight ? pwm : 0, motorTestRight ? 0 : pwm);
  return true;
}

//***************************************************************************************
// Imprime la lista corta de comandos del modo desarrollador (HELP o ?).
//***************************************************************************************
void printDeveloperHelp() {
  Serial.println("SHOW / VERIFY / SET <campo> <valor> / TEST <angulo> / EXIT");
  Serial.println("MOVE <mm> / TURN <grados> (signo negativo: retroceso/izquierda)");
  Serial.println("MOTOR <R|L> <F|R> <PWM> <100..3000 ms> / ENCODERS");
  Serial.println("TELEMETRY ON|OFF / STOP / CLEAR (fallo, estando detenido)");
  Serial.println("SHOW lista campos SET. Ganancias kp/ki/kd V2 afectan ambas ruedas.");
  Serial.println("SET pwmhz 200..30000 (8 bits): reiniciar y recalibrar start con MOTOR.");
}

//***************************************************************************************
// Atiende una línea de la consola de calibración (Monitor Serie, 115200, fin de línea \n).
//
// STOP funciona siempre. El resto exige entrar antes con "DEV <clave>" (developerPassword en
// RobotConfig.h); es protección contra cambios accidentales, no seguridad. Ya en modo DEV:
// TELEMETRY ON/OFF y EXIT funcionan siempre; los demás solo con el robot quieto
// (calibrationIdle) y si no, responde BUSY.
//
// Comandos: HELP, SHOW (configuración en RAM), VERIFY (RAM contra NVS), CLEAR (despejar fallo),
// ENCODERS (cuentas), SET <campo> <valor> (guardar; ver saveDeveloperValue), TEST <ángulo>
// (mover el servo del lápiz sin guardar), MOVE <mm> / TURN <grados> (maniobra con el
// controlador, hasta ±3000 mm o ±3600°; al terminar imprime MOVE_DONE) y MOTOR (ver
// startMotorTest).
//
// @param command Línea recibida, sin el salto de línea.
//***************************************************************************************
void processSerialCommand(String command) {
  command.trim();
  if (!command.length()) return;
  String upper = command; upper.toUpperCase();
  if (upper == "STOP") { requestMotionStop(); return; }
  if (!developerMode) {
    if (upper.startsWith("DEV ") && command.substring(4) == developerPassword) {
      developerMode = true;
      if (calibrationIdle()) printDeveloperHelp();
    } else if (calibrationIdle()) Serial.println("Acceso restringido. Use DEV <clave>.");
    return;
  }
  if (upper == "TELEMETRY ON") { telemetryEnabled = true; return; }
  if (upper == "TELEMETRY OFF") { telemetryEnabled = false; return; }
  if (upper == "EXIT") { developerMode = false; telemetryEnabled = false; return; }
  // Evitar escrituras NVS y respuestas largas mientras actúan los motores.
  if (!calibrationIdle()) {
    if (Serial.availableForWrite() >= 64) Serial.println("BUSY: espere la parada; STOP y TELEMETRY siguen disponibles.");
    return;
  }
  if (upper == "HELP" || upper == "?") printDeveloperHelp();
  else if (upper == "SHOW") printDeveloperConfig();
  else if (upper == "VERIFY") Serial.println(verifyConfig() ? "VERIFY OK" : "VERIFY ERROR");
  else if (upper == "CLEAR") {
    if (configReady) { motion.clear(); Serial.println("Fallo despejado."); }
    else Serial.println("Repare configuracion con SET antes de CLEAR.");
  } else if (upper == "ENCODERS") {
    uint32_t r, l; readEncoderCounts(r, l);
    Serial.printf("ENCODERS,%lu,%lu\n", (unsigned long)r, (unsigned long)l);
  } else if (upper.startsWith("SET ")) {
    const int split = command.indexOf(' ', 4);
    const bool ok = split > 4 && saveDeveloperValue(command.substring(4, split), command.substring(split + 1));
    Serial.println(ok ? "Guardado y verificado. device y pwmhz se aplican al reiniciar." : "SET invalido o error NVS. Revise rangos y VERIFY.");
  } else if (upper.startsWith("TEST ")) {
    float angle;
    if (parseFloatValue(command.substring(5), angle) && atta::within(angle, 0, 180) && angle == floorf(angle)) {
      myServo.write((int)angle); Serial.println("Servo temporal; use SET para guardar.");
    } else Serial.println("TEST requiere entero 0..180.");
  } else if (upper.startsWith("MOVE ") || upper.startsWith("TURN ")) {
    float amount;
    const bool turn = upper.startsWith("TURN ");
    if (!configReady || !motorOutputsReady || motion.fault != atta::Fault::None) { Serial.println("Movimiento bloqueado: revisar CONFIG/fallo y CLEAR."); return; }
    if (!parseFloatValue(command.substring(5), amount) || fabsf(amount) > (turn ? 3600 : 3000)) {
      Serial.println("MOVE: hasta +/-3000 mm. TURN: hasta +/-3600 grados."); return;
    }
    diagnosticMove = true; diagnosticAmount = amount;
    flagEjecucion = true;
    estado = turn ? GIRAR : MOVERSE;
  } else if (upper.startsWith("MOTOR ")) {
    if (!configReady || !motorOutputsReady || motion.fault != atta::Fault::None || !startMotorTest(upper))
      Serial.println("MOTOR invalido o bloqueado. HELP / SHOW / CLEAR.");
  } else Serial.println("Comando desconocido. HELP.");
}

//***************************************************************************************
// Lee la consola Serial sin bloquear y pasa cada línea completa a processSerialCommand.
//
// Atiende como máximo 64 caracteres por vuelta de loop() para que un flujo continuo no frene
// el control. Ignora \r. Una línea de más de 95 caracteres se descarta entera.
//***************************************************************************************
void readDeveloperSerial() {
  static bool overflow = false;
  for (int budget = 0; budget < 64 && Serial.available(); ++budget) {
    const char c = (char)Serial.read();
    if (c == '\r') continue;
    if (c == '\n') {
      if (!overflow) processSerialCommand(serialCommand);
      serialCommand = ""; overflow = false;
    } else if (!overflow && serialCommand.length() < 95) serialCommand += c;
    else { overflow = true; serialCommand = ""; }
  }
}

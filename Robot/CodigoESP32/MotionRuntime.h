#pragma once
// Se incluye después de los pines y la máquina de estados del sketch.
atta::Controller motion;
bool motorOutputsReady = false;
bool diagnosticMove = false;
float diagnosticAmount = 0;
bool telemetryEnabled = false;
uint32_t lastTelemetry = 0;
int appliedRightPWM = 0, appliedLeftPWM = 0;
bool motorTestActive = false, motorTestRight = true;
uint32_t motorTestStart = 0, motorTestDuration = 0, motorTestProgress = 0, motorTestTicks = 0;

void readEncoderCounts(uint32_t& r, uint32_t& l) {
  portENTER_CRITICAL(&encoderMux);
  r = rightEncoderPos; l = leftEncoderPos;
  portEXIT_CRITICAL(&encoderMux);
}

void applyMotorOutputs(bool rightReverse, bool leftReverse, int r, int l) {
  r = constrain(r, 0, 255); l = constrain(l, 0, 255);
  // Apagar el pin opuesto antes de activar el nuevo sentido.
  ledcWrite(rightReverse ? rightMotorM1 : rightMotorM2, 0);
  ledcWrite(leftReverse ? leftMotorM1 : leftMotorM2, 0);
  ledcWrite(rightReverse ? rightMotorM2 : rightMotorM1, r);
  ledcWrite(leftReverse ? leftMotorM2 : leftMotorM1, l);
  appliedRightPWM = r; appliedLeftPWM = l;
}

void stopMotion() {
  motion.stop();
  motorTestActive = false;
  applyMotorOutputs(false, false, 0, 0);
}

bool calibrationIdle() {
  return estado == ESPERA && !motion.active && !motorTestActive && !waitingForStopSettle &&
    !recibeProgra && !flancoNegRecibeProgra;
}

void requestMotionStop() {
  stopMotion();
  paro_emergencia = true;
  obstaculo_detectado = false;
  flagParar = true;
  flagEjecucion = false;
  recibeProgra = flancoNegRecibeProgra = false;
  diagnosticMove = false;
  // Cancelar también bucles/bifurcaciones del programa interrumpido.
  primer_ciclo = true;
  ignorarHastaIFFIN = ignorarHastaElse = ignorarHastaWHILEFIN = false;
  anidamientoWhile = anidamientoWhileIgnorar = anidamientoIF = anidamientoIFIgnorar = 0;
  for (int i = 0; i < 5; ++i) { indicesWhile[i] = 0; ejecutandoRamaIf[i] = false; }
  inst_actual = inst_final = 0;
  estado = DETENERSE;
}

void reportMotionFault() {
  Serial.printf("FAULT,%s\n", atta::faultName(motion.fault));
  requestMotionStop();
}

void emitTelemetry() {
  if (!telemetryEnabled || millis() - lastTelemetry < 100) return;
  lastTelemetry = millis();
  uint32_t r, l;
  readEncoderCounts(r, l);
  char row[384];
  const int length = snprintf(row, sizeof(row),
    "T,%lu,%s,%s,%d,%.4f,%lu,%lu,%.3f,%.3f,%.2f,%.2f,%.2f,%.2f,%d,%d,%.3f,%.3f,%d,%d,%s\n",
    (unsigned long)millis(), deviceName.c_str(), motorTestActive ? "MOTOR" :
      (motion.active ? (motion.turning ? "TURN" : "MOVE") : "IDLE"),
    motion.reverse, motion.dt, (unsigned long)r, (unsigned long)l,
    motion.right.distance, motion.left.distance, motion.right.reference, motion.left.reference,
    motion.right.speed, motion.left.speed, appliedRightPWM, appliedLeftPWM,
    motion.right.integral, motion.left.integral, motion.right.saturated, motion.left.saturated,
    atta::faultName(motion.fault));
  if (length > 0 && length < (int)sizeof(row) && Serial.availableForWrite() >= length)
    Serial.write((const uint8_t*)row, length); // descartar antes que bloquear el control
}

bool runMotion(float amount, bool turning) {
  if (paro_emergencia) return true;
  if (!configReady || !motorOutputsReady) { motion.fail(atta::Fault::Config); reportMotionFault(); return true; }
  if (motion.fault != atta::Fault::None) { reportMotionFault(); return true; }
  uint32_t r, l;
  readEncoderCounts(r, l);
  const uint32_t now = millis();
  if (!motion.active) {
    applyMotorOutputs(false, false, 0, 0);
    motion.begin(amount, turning, now, r, l, motionConfig);
    if (motion.fault != atta::Fault::None) reportMotionFault();
    return !motion.active;
  }
  if (motion.update(now, r, l, motionConfig)) {
    applyMotorOutputs(motion.rightReverse(), motion.leftReverse(), motion.right.pwm, motion.left.pwm);
    if (motion.fault != atta::Fault::None) reportMotionFault();
  }
  return !motion.active;
}
bool advanceDesiredDistance(float mm) { return runMotion(mm, false); }
bool turnDesiredAngle(float degrees) { return runMotion(degrees, true); }

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

void printDeveloperHelp() {
  Serial.println("SHOW / VERIFY / SET <campo> <valor> / TEST <angulo> / EXIT");
  Serial.println("MOVE <mm> / TURN <grados> (signo negativo: retroceso/izquierda)");
  Serial.println("MOTOR <R|L> <F|R> <PWM> <100..3000 ms> / ENCODERS");
  Serial.println("TELEMETRY ON|OFF / STOP / CLEAR (fallo, estando detenido)");
  Serial.println("SHOW lista campos SET. Ganancias kp/ki/kd V2 afectan ambas ruedas.");
}

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
    Serial.println(ok ? "Guardado y verificado. Device requiere reinicio para anunciar BLE." : "SET invalido o error NVS. Revise rangos y VERIFY.");
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

void readDeveloperSerial() {
  // Presupuesto por vuelta: un flujo Serial continuo no debe monopolizar loop().
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

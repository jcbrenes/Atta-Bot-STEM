#include "../CodigoESP32/RobotConfig.h"
#include <cassert>
#include <cstdio>
#include <iostream>

// Adaptador de pines/tiempo; se ejecuta el mismo MotionRuntime.h del firmware.
static uint32_t fakeNow = 0;
uint32_t millis() { return fakeNow; }
template<class T> T constrain(T x, T lo, T hi) { return x < lo ? lo : x > hi ? hi : x; }
int encoderMux = 0;
void portENTER_CRITICAL(int*) {}
void portEXIT_CRITICAL(int*) {}
uint32_t rightEncoderPos = 0, leftEncoderPos = 0;
const int rightMotorM1 = 14, rightMotorM2 = 12, leftMotorM1 = 13, leftMotorM2 = 15;
int pinPWM[40] = {};
bool ledcWrite(int pin, int pwm) { pinPWM[pin] = pwm; return true; }
enum State { ESPERA, DETENERSE, MOVERSE, GIRAR };
State estado = ESPERA;
bool waitingForStopSettle = false, recibeProgra = false, flancoNegRecibeProgra = false;
bool paro_emergencia = false, obstaculo_detectado = false, flagParar = false, flagEjecucion = false;
bool primer_ciclo = true, ignorarHastaIFFIN = false, ignorarHastaElse = false, ignorarHastaWHILEFIN = false;
int anidamientoWhile = 0, anidamientoWhileIgnorar = 0, anidamientoIF = 0, anidamientoIFIgnorar = 0;
int indicesWhile[5] = {}, inst_actual = 0, inst_final = 0;
bool ejecutandoRamaIf[5] = {};
struct ServoStub { void write(int) {} } myServo;
#include "../CodigoESP32/MotionRuntime.h"

void idle() { estado = ESPERA; paro_emergencia = false; waitingForStopSettle = false; }
void stoppedPins() { assert(pinPWM[14]==0 && pinPWM[12]==0 && pinPWM[13]==0 && pinPWM[15]==0); }

int main() {
  loadConfig(); motorOutputsReady = true;
  processSerialCommand("DEV AttaDev2026");
  processSerialCommand("MOVE 300");
  assert(estado == MOVERSE && diagnosticMove);
  assert(!advanceDesiredDistance(diagnosticAmount));
  fakeNow = 25; advanceDesiredDistance(diagnosticAmount);
  assert(pinPWM[14] > 0 && pinPWM[13] > 0 && pinPWM[12]==0 && pinPWM[15]==0);
  const auto writes = prefs.writes;
  processSerialCommand("SET rppr 900");
  assert(prefs.writes == writes && motionConfig.right.ppr == 820);
  processSerialCommand("STOP");
  stoppedPins(); assert(estado==DETENERSE && !motion.active && !diagnosticMove);
  idle(); fakeNow = 1000;
  // Cambio de dirección y PWM repetido: ambos pines deben actualizarse.
  processSerialCommand("TURN 90"); turnDesiredAngle(diagnosticAmount);
  fakeNow = 1025; turnDesiredAngle(diagnosticAmount);
  assert(pinPWM[12]>0 && pinPWM[13]>0 && pinPWM[14]==0 && pinPWM[15]==0);
  processSerialCommand("STOP"); idle(); fakeNow=2000;
  processSerialCommand("TURN -90"); turnDesiredAngle(diagnosticAmount);
  fakeNow=2025; turnDesiredAngle(diagnosticAmount);
  assert(pinPWM[14]>0 && pinPWM[15]>0 && pinPWM[12]==0 && pinPWM[13]==0);
  processSerialCommand("STOP"); idle();
  processSerialCommand("SET rppr nan"); assert(motionConfig.right.ppr==820);
  processSerialCommand("SET rppr 900"); assert(motionConfig.right.ppr==900 && verifyConfig());
  processSerialCommand("MOTOR R F 80 100");
  assert(motorTestActive && pinPWM[14]==80 && pinPWM[13]==0);
  fakeNow += 100; updateMotorTest();
  stoppedPins(); assert(!motorTestActive && estado==DETENERSE);
  idle(); processSerialCommand("MOVE 100"); advanceDesiredDistance(100);
  fakeNow+=25; advanceDesiredDistance(100);
  fakeNow+=300; advanceDesiredDistance(100);
  stoppedPins(); assert(motion.fault==atta::Fault::Timing && estado==DETENERSE);
  idle(); processSerialCommand("MOVE 100"); assert(estado==ESPERA);
  processSerialCommand("CLEAR"); assert(motion.fault==atta::Fault::None);
  processSerialCommand("MOVE 0"); assert(advanceDesiredDistance(0)); stoppedPins();
  diagnosticMove = false;
  // Los fallos recuperables de la app conservan el programa y su flujo.
  for (auto fault : {atta::Fault::RightStall, atta::Fault::LeftStall,
                     atta::Fault::Timeout, atta::Fault::Timing, atta::Fault::Settling}) {
    for (auto state : {MOVERSE, GIRAR}) {
      idle(); estado = state; flagEjecucion = true;
      inst_actual = 3; inst_final = 8; primer_ciclo = false;
      anidamientoWhile = 1; indicesWhile[0] = 2;
      anidamientoIF = 1; ejecutandoRamaIf[1] = true;
      applyMotorOutputs(false, false, 80, 80);
      motion.fail(fault); reportMotionFault();
      stoppedPins();
      assert(estado == DETENERSE && !paro_emergencia && flagEjecucion);
      assert(motion.fault == atta::Fault::None && !motion.active);
      assert(inst_actual == 3 && inst_final == 8 && !primer_ciclo);
      assert(anidamientoWhile == 1 && indicesWhile[0] == 2);
      assert(anidamientoIF == 1 && ejecutandoRamaIf[1]);
      // Despues del asentamiento, la siguiente maniobra puede arrancar sin CLEAR.
      estado = MOVERSE;
      assert(!advanceDesiredDistance(100));
      fakeNow += 25; assert(!advanceDesiredDistance(100));
      assert(pinPWM[14] > 0 && pinPWM[13] > 0);
      // STOP conserva la cancelacion completa aun despues de una recuperacion.
      processSerialCommand("STOP"); stoppedPins();
      assert(paro_emergencia && inst_actual == 0 && inst_final == 0);
      assert(anidamientoWhile == 0 && anidamientoIF == 0 && !flagEjecucion);
    }
  }
  // Fallo real de temporizacion en una maniobra de la app.
  idle(); estado = MOVERSE; inst_actual = 1; inst_final = 4;
  assert(!advanceDesiredDistance(100));
  fakeNow += 300; assert(advanceDesiredDistance(100));
  stoppedPins(); assert(!paro_emergencia && inst_final == 4 && estado == DETENERSE);
  // Perfil persistente usado por runtime y resultado de giro tras observar reposo.
  idle(); processSerialCommand("SET turnaccel 80"); processSerialCommand("TURN 90");
  assert(!turnDesiredAngle(90)); fakeNow += 25; turnDesiredAngle(90);
  assert(motion.right.reference <= 2.001f);
  rightEncoderPos += uint32_t(std::ceil(motion.target * motionConfig.right.ppr / (2*atta::pi*motionConfig.right.radius))) + 5;
  leftEncoderPos += uint32_t(std::ceil(motion.target * motionConfig.left.ppr / (2*atta::pi*motionConfig.left.radius)));
  fakeNow += 25; assert(!turnDesiredAngle(90));
  stoppedPins(); assert(motion.settling);
  telemetryEnabled = true; Serial.output.clear(); fakeNow += 100; emitTelemetry();
  assert(Serial.output.find(",SETTLE,") != std::string::npos);
  for (int i=0; i<16; ++i) { fakeNow += 25; turnDesiredAngle(90); }
  assert(!motion.active && motion.turnSettled && motion.turnOvershoot);
  assert(Serial.output.find("TURN_RESULT,OVERSHOOT") != std::string::npos);
  // STOP durante el asentamiento no deja continuar la secuencia.
  idle(); diagnosticMove=false; estado=GIRAR; inst_actual=2; inst_final=8;
  turnDesiredAngle(90);
  rightEncoderPos += uint32_t(std::ceil(motion.target * motionConfig.right.ppr / (2*atta::pi*motionConfig.right.radius)));
  leftEncoderPos += uint32_t(std::ceil(motion.target * motionConfig.left.ppr / (2*atta::pi*motionConfig.left.radius)));
  fakeNow+=25; turnDesiredAngle(90); assert(motion.settling);
  processSerialCommand("STOP"); stoppedPins();
  assert(!motion.active && !motion.settling && paro_emergencia && inst_final==0);
  // CONFIG sigue cancelando y bloqueando, aunque sea una secuencia de la app.
  idle(); estado = MOVERSE; motorOutputsReady = false;
  assert(advanceDesiredDistance(100)); stoppedPins();
  assert(motion.fault == atta::Fault::Config && paro_emergencia && inst_final == 0);
  std::cout << "runtime_test: OK\n";
}

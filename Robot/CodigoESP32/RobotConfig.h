//***************************************************************************************
// Configuración persistente del Atta: lee, valida y guarda en la NVS del ESP32
// (namespace "Atta-Creds") todo lo que se calibra robot por robot.
//
// Hay cuatro grupos de valores:
// - nombre Bluetooth ("deviceName") y frecuencia PWM de motores ("pwmHz");
// - ángulos de los servos, una clave entera por campo (servoFields);
// - perfil de movimiento "motionV2": el struct atta::MotionConfig completo, guardado como
//   un solo bloque binario (PPR, radios, ganancias, start/hold/ff, track, velocidades...);
// - perfil de giro "turnV1": el struct atta::TurnConfig (rampas y aproximación de los giros),
//   separado para no cambiar el formato binario de motionV2 ya instalado en los robots.
//
// Cada campo que se puede cambiar con "SET <campo> <valor>" está en una de las tablas
// servoFields, turnFields o motionFields (nombre del campo → variable en RAM), más los casos
// especiales device, pwmhz y los alias kp/ki/kd de saveDeveloperValue. Para agregar un
// parámetro nuevo basta con sumarlo a la tabla y al struct; SHOW y SET lo toman solos.
// Qué significa cada campo y cuándo tocarlo: Guia_parametros_SET.md.
//
// Se compila tanto en el ESP32 como en PC (tests/config_test.cpp usa un Preferences falso
// de tests/stubs), por eso no depende de nada del sketch.
//***************************************************************************************
#pragma once
#include <Preferences.h>
#include "MotionControl.h"

Preferences prefs;
atta::MotionConfig motionConfig;
atta::TurnConfig turnConfig;
bool configReady = false;
String deviceName = "Atta-V-02";
const char* developerPassword = "AttaDev2026";
bool developerMode = false;
String serialCommand;
int neutralAngle = 75, activateAngle = 85, deactivateAngle = 50;
int velocidadPositiva = 170, velocidadNegativa = 135, velocidadNeutra = 145;
// PWM de motores: resolución fija de 8 bits para que maxpwm, start y las
// ganancias conserven su significado (0..255) con cualquier frecuencia.
const int motorPwmBits = 8, motorPwmMinHz = 200, motorPwmMaxHz = 30000;
int motorPwmHz = 20000;      // guardado en NVS; se aplica al arrancar
uint32_t motorPwmActiveHz = 0; // frecuencia real leída del periférico

//***************************************************************************************
// Campo entero guardado en su propia clave NVS: los ángulos de los servos.
//
// name es lo que se escribe en SET, key la clave en NVS y value la variable global que usa el
// firmware. Las claves son las mismas que usaba el firmware anterior a V2, así que un cambio
// de servo hecho aquí se ve también en ese firmware.
//***************************************************************************************
struct ServoField { const char* name; const char* key; int* value; };
ServoField servoFields[] = {
  {"neutral", "servoNeutral", &neutralAngle}, {"active", "servoActive", &activateAngle},
  {"inactive", "servoInactive", &deactivateAngle}, {"forward", "servoForward", &velocidadPositiva},
  {"reverse", "servoReverse", &velocidadNegativa}, {"stop", "servoStop", &velocidadNeutra}
};
//***************************************************************************************
// Campo float de un perfil binario (motionV2 o turnV1): nombre de SET → miembro del struct.
//
// No tiene clave propia: al cambiar uno se reescribe el perfil entero (writeMotionProfile o
// writeTurnProfile).
//***************************************************************************************
struct MotionField { const char* name; float* value; };
MotionField turnFields[] = {
  {"turnaccel", &turnConfig.acceleration}, {"turndecel", &turnConfig.deceleration},
  {"turnapproach", &turnConfig.approachSpeed}, {"turnzone", &turnConfig.approachDistance}
};
// Los punteros siguen válidos al asignar una configuración completa.
MotionField motionFields[] = {
  {"rppr", &motionConfig.right.ppr}, {"lppr", &motionConfig.left.ppr},
  {"rradius", &motionConfig.right.radius}, {"lradius", &motionConfig.left.radius},
  {"rkp", &motionConfig.right.kp}, {"rki", &motionConfig.right.ki}, {"rkd", &motionConfig.right.kd},
  {"lkp", &motionConfig.left.kp}, {"lki", &motionConfig.left.ki}, {"lkd", &motionConfig.left.kd},
  {"rfstart", &motionConfig.right.forward.start}, {"rfhold", &motionConfig.right.forward.sustain},
  {"rfff", &motionConfig.right.forward.feedforward},
  {"rrstart", &motionConfig.right.reverse.start}, {"rrhold", &motionConfig.right.reverse.sustain},
  {"rrff", &motionConfig.right.reverse.feedforward},
  {"lfstart", &motionConfig.left.forward.start}, {"lfhold", &motionConfig.left.forward.sustain},
  {"lfff", &motionConfig.left.forward.feedforward},
  {"lrstart", &motionConfig.left.reverse.start}, {"lrhold", &motionConfig.left.reverse.sustain},
  {"lrff", &motionConfig.left.reverse.feedforward},
  {"track", &motionConfig.track}, {"speed", &motionConfig.speed}, {"turnspeed", &motionConfig.turnSpeed},
  {"accel", &motionConfig.acceleration}, {"decel", &motionConfig.deceleration},
  {"sync", &motionConfig.syncGain}, {"maxpwm", &motionConfig.maxPWM},
  {"tolerance", &motionConfig.tolerance}, {"filterms", &motionConfig.filterMs},
  {"stallms", &motionConfig.stallMs}, {"startms", &motionConfig.startMs}
};

//***************************************************************************************
// Convierte el texto de un SET a número, rechazando basura.
//
// A diferencia de toFloat(), falla si sobra texto ("12xyz"), si no hay número o si el
// resultado es nan/inf; así un error de tipeo no se guarda como 0.
//
// @param text Texto del valor, ya sin espacios alrededor.
// @param value Salida: el número leído (solo válido si devuelve true).
//
// @return true si el texto completo es un número finito.
//***************************************************************************************
bool parseFloatValue(const String& text, float& value) {
  char* end;
  value = strtof(text.c_str(), &end);
  return end != text.c_str() && *end == '\0' && std::isfinite(value);
}

//***************************************************************************************
// Guarda el perfil de movimiento completo en la clave "motionV2" y lo relee para verificarlo.
//
// El namespace NVS lo abre el llamador. Una sola escritura del bloque entero evita que un
// corte de alimentación deje combinadas ganancias de dos calibraciones distintas. No escribe
// nada si el perfil no pasa atta::validConfig.
//
// @param candidate Perfil a guardar.
//
// @return true si quedó guardado y lo leído coincide byte por byte.
//***************************************************************************************
bool writeMotionProfile(const atta::MotionConfig& candidate) {
  if (!atta::validConfig(candidate)) return false;
  if (prefs.putBytes("motionV2", &candidate, sizeof(candidate)) != sizeof(candidate)) return false;
  atta::MotionConfig check;
  return prefs.getBytesLength("motionV2") == sizeof(check) &&
    prefs.getBytes("motionV2", &check, sizeof(check)) == sizeof(check) &&
    memcmp(&candidate, &check, sizeof(check)) == 0;
}

//***************************************************************************************
// Guarda el perfil de giro en la clave "turnV1" y lo relee para verificarlo.
//
// Igual que writeMotionProfile, pero para atta::TurnConfig. El namespace lo abre el llamador.
//
// @param candidate Perfil de giro a guardar.
//
// @return true si quedó guardado y lo leído coincide byte por byte.
//***************************************************************************************
bool writeTurnProfile(const atta::TurnConfig& candidate) {
  if (!atta::validTurnConfig(candidate)) return false;
  if (prefs.putBytes("turnV1", &candidate, sizeof(candidate)) != sizeof(candidate)) return false;
  atta::TurnConfig check;
  return prefs.getBytesLength("turnV1") == sizeof(check) &&
    prefs.getBytes("turnV1", &check, sizeof(check)) == sizeof(check) &&
    memcmp(&candidate, &check, sizeof(check)) == 0;
}

//***************************************************************************************
// Carga la configuración desde NVS al arrancar; crea una sola vez lo que falte.
//
// Un Atta recién cargado no tiene claves: se guardan los valores por defecto del firmware
// (nombre Atta-V-02, ángulos, 20 kHz). Si no existe motionV2 pero sí las claves del firmware
// anterior (Rppr, Lppr, kp, ki, kd), se migra: el PPR se conserva y las ganancias se
// convierten a segundos con atta::migrateGains. Si no existe turnV1 se crea con los valores
// por defecto de atta::TurnConfig, sin tocar motionV2.
//
// Un perfil guardado pero inválido o de otro tamaño NO se reemplaza por valores por defecto:
// se deja como está y configReady queda en false, lo que bloquea el movimiento hasta
// corregirlo con SET (así no se pierde en silencio la calibración de un robot).
//
// Deja configReady en true solo si todo quedó cargado y válido, y lo informa por Serial.
//***************************************************************************************
void loadConfig() {
  configReady = false;
  if (!prefs.begin("Atta-Creds", false)) {
    Serial.println("ERROR CONFIG: no se pudo abrir NVS; movimiento bloqueado."); return;
  }
  bool ok = true;
  if (!prefs.isKey("deviceName")) ok &= prefs.putString("deviceName", deviceName) > 0;
  deviceName = prefs.getString("deviceName", "");
  ok &= deviceName.length() > 0 && deviceName.length() <= 31;
  for (auto& f : servoFields) {
    if (!prefs.isKey(f.key)) ok &= prefs.putInt(f.key, *f.value) == sizeof(int32_t);
    const int angle = prefs.getInt(f.key, -1);
    if (angle < 0 || angle > 180) ok = false;
    else *f.value = angle;
  }
  if (!prefs.isKey("pwmHz")) ok &= prefs.putInt("pwmHz", motorPwmHz) == sizeof(int32_t);
  const int hz = prefs.getInt("pwmHz", -1);
  if (hz < motorPwmMinHz || hz > motorPwmMaxHz) ok = false;
  else motorPwmHz = hz;
  if (prefs.isKey("motionV2")) {
    atta::MotionConfig saved;
    const bool valid = prefs.getBytesLength("motionV2") == sizeof(saved) &&
      prefs.getBytes("motionV2", &saved, sizeof(saved)) == sizeof(saved) && atta::validConfig(saved);
    if (valid) motionConfig = saved;
    else ok = false; // no sobrescribir un perfil inválido con valores por defecto
  } else {
    atta::MotionConfig migrated;
    migrated.right.ppr = prefs.getFloat("Rppr", 822); // PPR más repetidos entre los Attas
    migrated.left.ppr = prefs.getFloat("Lppr", 828);
    const float kp = prefs.getFloat("kp", 2), ki = prefs.getFloat("ki", 2), kd = prefs.getFloat("kd", 0);
    atta::migrateGains(migrated.right, kp, ki, kd);
    atta::migrateGains(migrated.left, kp, ki, kd);
    if (atta::validConfig(migrated) && writeMotionProfile(migrated)) {
      motionConfig = migrated;
      Serial.println("Perfil V2 creado: PPR conservado; Ki anterior x0.4, Kd x0.025. Validar en robot.");
    } else ok = false;
  }
  if (prefs.isKey("turnV1")) {
    atta::TurnConfig saved;
    const bool valid = prefs.getBytesLength("turnV1") == sizeof(saved) &&
      prefs.getBytes("turnV1", &saved, sizeof(saved)) == sizeof(saved) && atta::validTurnConfig(saved);
    if (valid) turnConfig = saved;
    else ok = false; // no sustituir silenciosamente un perfil corrupto
  } else if (ok) {
    const atta::TurnConfig initial;
    if (writeTurnProfile(initial)) {
      turnConfig = initial;
      Serial.println("Perfil turnV1 creado; calibracion motionV2 conservada.");
    } else ok = false;
  }
  prefs.end();
  configReady = ok;
  if (!ok) Serial.println("ERROR CONFIG: valores invalidos o fallo NVS; revisar SHOW y SET antes de mover.");
}

//***************************************************************************************
// Responde al comando SHOW: imprime toda la configuración en RAM como líneas SET.
//
// La salida se puede guardar como respaldo y volver a pegar en el Monitor Serie para
// restaurar el robot (cargar_firmware_attas.sh guarda una en Respaldos_SHOW/). La primera
// línea dice las versiones de los perfiles (schema, turn_schema, controller) y la frecuencia
// PWM que el periférico aplicó de verdad. Muestra la RAM, no la NVS: para comparar con lo
// guardado está VERIFY.
//***************************************************************************************
void printDeveloperConfig() {
  Serial.printf("CONFIG schema=2 turn_schema=1 controller=3 ready=%d device=%s pwm_activo=%luHz\n",
    configReady, deviceName.c_str(), (unsigned long)motorPwmActiveHz);
  for (const auto& f : motionFields) Serial.printf("SET %s %.6f\n", f.name, *f.value);
  for (const auto& f : turnFields) Serial.printf("SET %s %.6f\n", f.name, *f.value);
  for (const auto& f : servoFields) Serial.printf("SET %s %d\n", f.name, *f.value);
  Serial.printf("SET pwmhz %d\n", motorPwmHz);
  Serial.println("Ganancias V2 en segundos. SHOW muestra RAM; VERIFY compara contra NVS.");
  if (motorPwmActiveHz && motorPwmActiveHz != (uint32_t)motorPwmHz)
    Serial.println("pwmhz guardado distinto del activo: reinicie para aplicarlo.");
}

//***************************************************************************************
// Responde a VERIFY: compara la configuración en RAM con la guardada en NVS.
//
// Revisa nombre, servos, pwmHz y los dos perfiles binarios byte por byte, y que ambos
// perfiles sigan dentro de rango. También la usa saveDeveloperValue después de cada SET para
// detectar una escritura que falló a medias.
//
// @return true si RAM y NVS coinciden y la configuración es válida.
//***************************************************************************************
bool verifyConfig() {
  if (!prefs.begin("Atta-Creds", true)) return false;
  atta::MotionConfig saved;
  bool ok = prefs.getBytesLength("motionV2") == sizeof(saved) &&
    prefs.getBytes("motionV2", &saved, sizeof(saved)) == sizeof(saved) &&
    memcmp(&saved, &motionConfig, sizeof(saved)) == 0 &&
    prefs.getString("deviceName", "") == deviceName;
  for (const auto& f : servoFields) ok &= prefs.getInt(f.key, -1) == *f.value;
  ok &= prefs.getInt("pwmHz", -1) == motorPwmHz;
  atta::TurnConfig savedTurn;
  ok &= prefs.getBytesLength("turnV1") == sizeof(savedTurn) &&
    prefs.getBytes("turnV1", &savedTurn, sizeof(savedTurn)) == sizeof(savedTurn) &&
    memcmp(&savedTurn, &turnConfig, sizeof(savedTurn)) == 0 && atta::validTurnConfig(turnConfig);
  prefs.end();
  return ok && atta::validConfig(motionConfig);
}

//***************************************************************************************
// Atiende "SET <campo> <valor>": valida, guarda en NVS y verifica un campo.
//
// Busca el campo en este orden: device (texto, máx. 31 caracteres, sin comas), servoFields
// (entero 0..180), pwmhz (entero motorPwmMinHz..motorPwmMaxHz), turnFields, motionFields y
// los alias kp/ki/kd, que escriben la misma ganancia en las dos ruedas. Para los campos de
// perfil se cambia la RAM, se reescribe el perfil entero y, si no pasa la validación o falla
// la escritura, la RAM vuelve al valor anterior: un SET inválido no deja nada a medias.
//
// device y pwmhz se guardan pero recién se aplican al reiniciar (el nombre BLE y el PWM se
// configuran en setup). Al final recalcula configReady con verifyConfig.
//
// @param field Nombre del campo, sin importar mayúsculas.
// @param value Texto del valor.
//
// @return true si el valor se guardó y toda la configuración quedó verificada.
//***************************************************************************************
bool saveDeveloperValue(String field, String value) {
  field.toLowerCase(); value.trim();
  if (!prefs.begin("Atta-Creds", false)) return false;
  bool ok = false;
  if (field == "device") {
    if (value.length() > 0 && value.length() <= 31 && value.indexOf(',') < 0) {
      ok = prefs.putString("deviceName", value) > 0 && prefs.getString("deviceName", "") == value;
      if (ok) deviceName = value;
    }
  } else {
    float number;
    if (parseFloatValue(value, number)) {
      bool servo = false;
      for (auto& f : servoFields) {
        if (field != f.name) continue;
        servo = true;
        if (number >= 0 && number <= 180 && number == floorf(number)) {
          ok = prefs.putInt(f.key, (int)number) == sizeof(int32_t) && prefs.getInt(f.key, -1) == (int)number;
          if (ok) *f.value = (int)number;
        }
      }
      if (field == "pwmhz") {
        servo = true; // entero guardado aparte, como los servos
        if (number >= motorPwmMinHz && number <= motorPwmMaxHz && number == floorf(number)) {
          ok = prefs.putInt("pwmHz", (int)number) == sizeof(int32_t) && prefs.getInt("pwmHz", -1) == (int)number;
          if (ok) motorPwmHz = (int)number;
        }
      }
      if (!servo) {
        bool turnField = false;
        const atta::TurnConfig previousTurn = turnConfig;
        for (auto& f : turnFields) {
          if (field == f.name) { *f.value = number; turnField = true; }
        }
        if (turnField) {
          ok = writeTurnProfile(turnConfig);
          if (!ok) turnConfig = previousTurn;
        } else {
          const atta::MotionConfig previous = motionConfig;
          bool known = false;
          for (auto& f : motionFields) {
            if (field == f.name) { *f.value = number; known = true; }
          }
          // Alias antiguos: ahora representan ganancias V2 para AMBAS ruedas.
          if (field == "kp") { motionConfig.right.kp = motionConfig.left.kp = number; known = true; }
          if (field == "ki") { motionConfig.right.ki = motionConfig.left.ki = number; known = true; }
          if (field == "kd") { motionConfig.right.kd = motionConfig.left.kd = number; known = true; }
          ok = known && writeMotionProfile(motionConfig);
          if (!ok) motionConfig = previous;
        }
      }
    }
  }
  prefs.end();
  // Verificación completa detecta también un fallo parcial de almacenamiento.
  configReady = verifyConfig();
  return ok && configReady;
}

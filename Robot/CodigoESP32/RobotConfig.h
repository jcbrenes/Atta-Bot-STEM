#pragma once
#include <Preferences.h>
#include "MotionControl.h"

Preferences prefs;
atta::MotionConfig motionConfig;
bool configReady = false;
String deviceName = "Atta-V-02";
const char* developerPassword = "AttaDev2026";
bool developerMode = false;
String serialCommand;
int neutralAngle = 75, activateAngle = 85, deactivateAngle = 50;
int velocidadPositiva = 170, velocidadNegativa = 135, velocidadNeutra = 145;

struct ServoField { const char* name; const char* key; int* value; };
ServoField servoFields[] = {
  {"neutral", "servoNeutral", &neutralAngle}, {"active", "servoActive", &activateAngle},
  {"inactive", "servoInactive", &deactivateAngle}, {"forward", "servoForward", &velocidadPositiva},
  {"reverse", "servoReverse", &velocidadNegativa}, {"stop", "servoStop", &velocidadNeutra}
};
struct MotionField { const char* name; float* value; };
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

bool parseFloatValue(const String& text, float& value) {
  char* end;
  value = strtof(text.c_str(), &end);
  return end != text.c_str() && *end == '\0' && std::isfinite(value);
}

// Namespace abierto por el llamador. Una sola escritura del perfil evita
// combinaciones de ganancias de dos calibraciones tras un corte de alimentación.
bool writeMotionProfile(const atta::MotionConfig& candidate) {
  if (!atta::validConfig(candidate)) return false;
  if (prefs.putBytes("motionV2", &candidate, sizeof(candidate)) != sizeof(candidate)) return false;
  atta::MotionConfig check;
  return prefs.getBytesLength("motionV2") == sizeof(check) &&
    prefs.getBytes("motionV2", &check, sizeof(check)) == sizeof(check) &&
    memcmp(&candidate, &check, sizeof(check)) == 0;
}

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
  if (prefs.isKey("motionV2")) {
    atta::MotionConfig saved;
    const bool valid = prefs.getBytesLength("motionV2") == sizeof(saved) &&
      prefs.getBytes("motionV2", &saved, sizeof(saved)) == sizeof(saved) && atta::validConfig(saved);
    if (valid) motionConfig = saved;
    else ok = false; // no sobrescribir un perfil inválido con valores por defecto
  } else {
    atta::MotionConfig migrated;
    migrated.right.ppr = prefs.getFloat("Rppr", 820);
    migrated.left.ppr = prefs.getFloat("Lppr", 820);
    const float kp = prefs.getFloat("kp", 2), ki = prefs.getFloat("ki", 2), kd = prefs.getFloat("kd", 0);
    atta::migrateGains(migrated.right, kp, ki, kd);
    atta::migrateGains(migrated.left, kp, ki, kd);
    if (atta::validConfig(migrated) && writeMotionProfile(migrated)) {
      motionConfig = migrated;
      Serial.println("Perfil V2 creado: PPR conservado; Ki anterior x0.4, Kd x0.025. Validar en robot.");
    } else ok = false;
  }
  prefs.end();
  configReady = ok;
  if (!ok) Serial.println("ERROR CONFIG: valores invalidos o fallo NVS; revisar SHOW y SET antes de mover.");
}

void printDeveloperConfig() {
  Serial.printf("CONFIG schema=2 controller=2 ready=%d device=%s\n", configReady, deviceName.c_str());
  for (const auto& f : motionFields) Serial.printf("SET %s %.6f\n", f.name, *f.value);
  for (const auto& f : servoFields) Serial.printf("SET %s %d\n", f.name, *f.value);
  Serial.println("Ganancias V2 en segundos. SHOW muestra RAM; VERIFY compara contra NVS.");
}

bool verifyConfig() {
  if (!prefs.begin("Atta-Creds", true)) return false;
  atta::MotionConfig saved;
  bool ok = prefs.getBytesLength("motionV2") == sizeof(saved) &&
    prefs.getBytes("motionV2", &saved, sizeof(saved)) == sizeof(saved) &&
    memcmp(&saved, &motionConfig, sizeof(saved)) == 0 &&
    prefs.getString("deviceName", "") == deviceName;
  for (const auto& f : servoFields) ok &= prefs.getInt(f.key, -1) == *f.value;
  prefs.end();
  return ok && atta::validConfig(motionConfig);
}

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
      if (!servo) {
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
  prefs.end();
  // Verificación completa detecta también un fallo parcial de almacenamiento.
  configReady = verifyConfig();
  return ok && configReady;
}

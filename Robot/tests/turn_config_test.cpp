#include "../CodigoESP32/RobotConfig.h"
#include <cassert>
#include <iostream>
#include <cstddef>
static_assert(sizeof(atta::MotionConfig) == 136, "No cambiar el formato motionV2 sin migracion");
static_assert(offsetof(atta::MotionConfig, track) == 92, "Geometria V2 incompatible");
int main() {
  // Preparar NVS exactamente como un robot V2 ya calibrado (sin turnV1).
  atta::MotionConfig old;
  old.right.ppr=822; old.left.ppr=808; old.speed=110; old.turnSpeed=90;
  old.acceleration=250; old.deceleration=300; old.maxPWM=230;
  old.right.reverse.feedforward=.7f; old.left.kp=1.7f;
  prefs.begin("Atta-Creds", false);
  prefs.putBytes("motionV2", &old, sizeof(old)); prefs.putString("deviceName", "Atta-A-02");
  for (const auto& f : servoFields) prefs.putInt(f.key, *f.value);
  prefs.putInt("servoActive", 80); prefs.end();
  const auto before = prefs.writes;
  loadConfig(); assert(configReady && verifyConfig());
  assert(prefs.writes == before+2); // solo crea turnV1 y pwmHz (1 kHz, como antes)
  assert(motorPwmHz == 1000);
  assert(memcmp(&old, &motionConfig, sizeof(old)) == 0 && activateAngle == 80);
  atta::MotionConfig saved; prefs.begin("Atta-Creds", true);
  prefs.getBytes("motionV2", &saved, sizeof(saved)); prefs.end();
  assert(memcmp(&saved, &old, sizeof(old)) == 0);
  assert(saveDeveloperValue("turnaccel", "160"));
  assert(saveDeveloperValue("turndecel", "100"));
  assert(saveDeveloperValue("turnapproach", "15"));
  assert(saveDeveloperValue("turnzone", "25"));
  assert(!saveDeveloperValue("turnzone", "nan"));
  assert(!saveDeveloperValue("turnapproach", "0"));
  prefs.failWrites=true; assert(!saveDeveloperValue("turnaccel", "200"));
  assert(turnConfig.acceleration == 160 && verifyConfig()); prefs.failWrites=false;
  auto writes = prefs.writes;
  turnConfig = atta::TurnConfig{}; loadConfig();
  assert(configReady && prefs.writes == writes && turnConfig.acceleration == 160);
  assert(turnConfig.deceleration == 100 && turnConfig.approachSpeed == 15 && turnConfig.approachDistance == 25);
  assert(memcmp(&old, &motionConfig, sizeof(old)) == 0);
  // Corrupcion y fallo de creacion no se ocultan con valores por defecto.
  prefs.begin("Atta-Creds", false); uint32_t bad=99;
  prefs.putBytes("turnV1", &bad, sizeof(bad)); prefs.end(); writes=prefs.writes;
  loadConfig(); assert(!configReady && prefs.writes == writes && !verifyConfig());
  prefs = Preferences{}; prefs.begin("Atta-Creds", false);
  prefs.putBytes("motionV2", &old, sizeof(old)); prefs.putString("deviceName", "Atta-A-02");
  for (const auto& f : servoFields) prefs.putInt(f.key, *f.value);
  prefs.end(); prefs.failWrites=true; loadConfig(); assert(!configReady);
  prefs.failWrites=false; loadConfig(); assert(configReady && verifyConfig());
  std::cout << "turn_config_test: OK\n";
}

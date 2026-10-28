#include "../CodigoESP32/RobotConfig.h"
#include <cassert>
#include <iostream>
int main() {
  prefs.begin("Atta-Creds", false);
  prefs.putString("deviceName", "Atta-13");
  prefs.putFloat("Rppr", 834); prefs.putFloat("Lppr", 810);
  prefs.putFloat("kp", 1.5); prefs.putFloat("ki", 3); prefs.putFloat("kd", .2);
  prefs.putInt("servoActive", 93);
  prefs.end();
  loadConfig();
  assert(configReady && verifyConfig());
  assert(deviceName == "Atta-13" && activateAngle == 93);
  assert(motionConfig.right.ppr == 834 && motionConfig.left.ppr == 810);
  assert(std::fabs(motionConfig.right.ki - 1.2f) < 1e-6f);
  assert(std::fabs(motionConfig.left.kd - .005f) < 1e-6f);
  const unsigned initialWrites = prefs.writes;
  loadConfig();
  assert(prefs.writes == initialWrites); // ni remigrar ni reescribir en cada arranque
  assert(std::fabs(motionConfig.right.ki - 1.2f) < 1e-6f);
  for (const char* invalid : {"nan", "inf", "-inf", "0", "-20", "999999", "12xyz"})
    assert(!saveDeveloperValue("rppr", invalid));
  assert(motionConfig.right.ppr == 834 && verifyConfig());
  assert(saveDeveloperValue("rki", "0.7"));
  assert(std::fabs(motionConfig.left.ki - 1.2f) < 1e-6f);
  assert(saveDeveloperValue("active", "88"));
  assert(!saveDeveloperValue("active", "88.5"));
  assert(saveDeveloperValue("maxpwm", "100"));
  assert(!saveDeveloperValue("rfstart", "101"));
  prefs.failWrites = true;
  assert(!saveDeveloperValue("rki", "4"));
  assert(motionConfig.right.ki == .7f && verifyConfig());
  prefs.failWrites = false;
  motionConfig = atta::MotionConfig{}; activateAngle = 75; // reinicio
  loadConfig();
  assert(configReady && motionConfig.right.ki == .7f && activateAngle == 88);
  prefs.begin("Atta-Creds", true);
  assert(prefs.getFloat("ki", 0) == 3); // rollback conserva las claves anteriores
  prefs.end();
  prefs.failOpen = true; loadConfig(); assert(!configReady);
  prefs.failOpen = false;
  prefs.begin("Atta-Creds", false);
  atta::MotionConfig invalid; invalid.right.ppr = 0;
  prefs.putBytes("motionV2", &invalid, sizeof(invalid)); prefs.end();
  loadConfig(); assert(!configReady); // perfil corrupto no se sustituye silenciosamente
  assert(!verifyConfig());
  std::cout << "config_test: OK\n";
}

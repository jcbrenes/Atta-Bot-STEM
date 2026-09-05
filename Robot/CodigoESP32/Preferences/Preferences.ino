/*
  Rui Santos
  Complete project details at https://RandomNerdTutorials.com/esp32-save-data-permanently-preferences/
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files.
  
  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.
*/

#include <Preferences.h>

Preferences prefs;

// Global declarations - remove 'const' since these load at runtime
float rightPulsesPerRev = 0;
float leftPulsesPerRev = 0;
float kpSpeed = 0;
float kiSpeed = 0;
float kdSpeed = 0.0;
String deviceName = "";

void loadConfig() {
  prefs.begin("Atta-Creds", true); // true = read-only
  deviceName = prefs.getString("deviceName", "");
  rightPulsesPerRev = prefs.getFloat("Rppr", 0.0);
  leftPulsesPerRev = prefs.getFloat("Lppr", 0.0);
  kpSpeed = prefs.getFloat("kp", 0.0);
  kiSpeed = prefs.getFloat("ki", 0.0);
  kdSpeed = prefs.getFloat("kd", 0.0);
  prefs.end();
}

void saveConfig(const char * name, float Rppr, float Lppr, float kp, float ki, float kd) {
  prefs.begin("Atta-Creds", false); // false = read/write
  prefs.putString("deviceName", name);
  prefs.putFloat("Rppr", Rppr);
  prefs.putFloat("Lppr", Lppr);
  prefs.putFloat("kp", kp);
  prefs.putFloat("ki", ki);
  prefs.putFloat("kd", kd);
  prefs.end();
}

void setup() {
  Serial.begin(115200);
  Serial.println();

    saveConfig("Atta-Amarillo-01", 849.6, 853.0, 2.0, 2.0, 0.0);
  Serial.println("Atta Credentials Saved using Preferences");


  loadConfig();

  Serial.print("Loaded device name: [");
  Serial.print(deviceName);
  Serial.println("]");

}

void loop() {
  // Intentionally empty.
  // This sketch only needs to run once at startup to write the credentials.
}


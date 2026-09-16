// Simple full-speed motor test
// Drives both motors continuously at maximum PWM in one direction.

const int rightMotorM1 = 14;
const int rightMotorM2 = 12;

const int leftMotorM1 = 15;
const int leftMotorM2 = 13;

const int maxPWM = 255; // full duty cycle

void setup() {
  pinMode(rightMotorM1, OUTPUT);
  pinMode(rightMotorM2, OUTPUT);
  pinMode(leftMotorM1, OUTPUT);
  pinMode(leftMotorM2, OUTPUT);
}

void loop() {
  // One direction: M1 = PWM, M2 = 0.
  // Swap which pin gets maxPWM to reverse direction if needed.
  analogWrite(rightMotorM1, maxPWM);
  analogWrite(rightMotorM2, 0);

  analogWrite(leftMotorM1, 0);
  analogWrite(leftMotorM2, maxPWM);
}

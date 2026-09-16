// Minimal encoder test
// Purpose: count pulses on both N20 encoders while the wheel/arrow is moved BY HAND.
// No motor driving involved. This isolates the sensing/interrupt logic from the
// motor-control state machine so you can verify the encoders themselves are reliable.

// ---------- Pin definitions (same as your original wiring) ----------
const int rightEncoderA = 27;
const int rightEncoderB = 33;

const int leftEncoderA = 32;
const int leftEncoderB = 35;

// ---------- Encoder state ----------
// We use full quadrature decoding (4x): every edge on A or B updates the count.
// A lookup table maps (previous 2-bit state, current 2-bit state) -> -1, 0, +1.

volatile long rightCount = 0;
volatile long leftCount = 0;

volatile uint8_t rightPrevState = 0;
volatile uint8_t leftPrevState = 0;

// ---------- Debounce (refractory period) ----------
// Based on measured PPR (~820) and the motor's max no-load speed at 5V,
// real transitions cannot happen closer than ~175 us apart. We ignore any
// interrupt firing sooner than this after the last ACCEPTED transition for
// that encoder, treating it as electrical noise rather than a real edge.
const unsigned long debounceMicros = 75;

volatile unsigned long rightLastAcceptedMicros = 0;
volatile unsigned long leftLastAcceptedMicros = 0;

// Quadrature lookup table indexed by (prevState << 2 | newState).
// Valid transitions give +1 or -1, invalid/no-change transitions give 0.
const int8_t quadTable[16] = {
   0, -1,  1,  0,
   1,  0,  0, -1,
  -1,  0,  0,  1,
   0,  1, -1,  0
};

//======================================================================
// Right encoder ISR: triggered on CHANGE of either channel.
// Reads both pins to build the 2-bit state, compares to previous state.
//======================================================================
void IRAM_ATTR rightEncoderISR() {
  unsigned long now = micros();
  // Reject this interrupt entirely if it came too soon after the last accepted
  // one. We do NOT update rightPrevState here, since we're assuming the pin
  // never actually changed state (it was noise), so the state table stays
  // consistent for the next real transition.
  if (now - rightLastAcceptedMicros < debounceMicros) {
    return;
  }

  uint8_t a = digitalRead(rightEncoderA);
  uint8_t b = digitalRead(rightEncoderB);
  uint8_t newState = (a << 1) | b;
  uint8_t index = (rightPrevState << 2) | newState;
  rightCount += quadTable[index];
  rightPrevState = newState;
  rightLastAcceptedMicros = now;
}

//======================================================================
// Left encoder ISR: same logic as right.
//======================================================================
void IRAM_ATTR leftEncoderISR() {
  unsigned long now = micros();
  if (now - leftLastAcceptedMicros < debounceMicros) {
    return;
  }

  uint8_t a = digitalRead(leftEncoderA);
  uint8_t b = digitalRead(leftEncoderB);
  uint8_t newState = (a << 1) | b;
  uint8_t index = (leftPrevState << 2) | newState;
  leftCount += quadTable[index];
  leftPrevState = newState;
  leftLastAcceptedMicros = now;
}

unsigned long lastPrint = 0;
const unsigned long printInterval = 200; // ms, how often we print counts

void setup() {
  Serial.begin(115200);

  pinMode(rightEncoderA, INPUT);
  pinMode(rightEncoderB, INPUT);
  pinMode(leftEncoderA, INPUT);
  pinMode(leftEncoderB, INPUT);

  // Initialize previous state so the first ISR call has a valid reference
  rightPrevState = (digitalRead(rightEncoderA) << 1) | digitalRead(rightEncoderB);
  leftPrevState  = (digitalRead(leftEncoderA) << 1) | digitalRead(leftEncoderB);

  attachInterrupt(digitalPinToInterrupt(rightEncoderA), rightEncoderISR, CHANGE);
  attachInterrupt(digitalPinToInterrupt(rightEncoderB), rightEncoderISR, CHANGE);
  attachInterrupt(digitalPinToInterrupt(leftEncoderA), leftEncoderISR, CHANGE);
  attachInterrupt(digitalPinToInterrupt(leftEncoderB), leftEncoderISR, CHANGE);

  Serial.println("Encoder test ready. Move the wheels by hand.");
  Serial.println("Format: Right | Left");
}

void loop() {
  // Serial command to reset counts to zero, useful between manual test runs
  if (Serial.available() > 0) {
    String cmd = Serial.readString();
    cmd.trim();
    if (cmd == "reset") {
      noInterrupts();
      rightCount = 0;
      leftCount = 0;
      interrupts();
      Serial.println("Counts reset.");
    }
  }

  if (millis() - lastPrint >= printInterval) {
    lastPrint = millis();

    // Copy volatile values quickly to avoid them changing mid-read
    noInterrupts();
    long r = rightCount;
    long l = leftCount;
    interrupts();

    Serial.print("Right: ");
    Serial.print(r);
    Serial.print(" | Left: ");
    Serial.println(l);
  }
}

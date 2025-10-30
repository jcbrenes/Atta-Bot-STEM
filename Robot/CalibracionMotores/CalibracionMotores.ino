/*
 * Encoder example sketch
 * by Andrew Kramer
 * 1/1/2016
 *
 * Records encoder ticks for each wheel
 * and prints the number of ticks for
 * each encoder every 500ms
 *
 */


// Define the encoder pins
const int rightEncoderA = 27; // Pin for the right encoder's channel A
const int rightEncoderB = 33; // Pin for the right encoder's channel B

const int leftEncoderA = 32; // Pin for the left encoder's channel A
const int leftEncoderB = 35; // Pin for the left encoder's channel B

// Motor control pins
const int rightMotorM1 = 14; //14  // Direction control pin 1 for the right motor
const int rightMotorM2 = 12;  //12 // Direction control pin 2 for the right motor

const int leftMotorM1 = 15;   // Direction control pin 1 for the left motor
const int leftMotorM2 = 13;   // Direction control pin 1 for the left motor

int motorM1 = rightMotorM1; // Variable a la que se le envía el PWM, depende del motor que se esté calibrando
int motorM2 = rightMotorM2; 


// variables to store the number of encoder pulses
// for each motor
volatile unsigned long leftCount = 0;
volatile unsigned long pulsosAntesArranque = 0;
volatile unsigned long rightCount = 0;
volatile unsigned long pulsesCount = 0;

int estado = 0;

int seleccionMotor = 1; // 1 para motor derecho y 2 para izquierdo

const int pwmMinimo = 55; //pwm mínimo para mantener cualquier motor en movimiento
const int velArranqueInicial = 40; // pwm mínimo que podría arrancar algún motor

int pwmMotores = 40;
unsigned long waitTime = 1000; //1000

unsigned long tUltimaLecturaDerecha;
unsigned long tUltimaLecturaIzquierda;
unsigned long tUltimaLectura;

float PPR = 0;

int velArranque = 40;
bool flagArranque = 0;

void setup() {
  pinMode(rightEncoderB, INPUT);
  pinMode(rightEncoderA, INPUT);
  pinMode(leftEncoderB, INPUT);
  pinMode(leftEncoderA, INPUT);
  
  // initialize hardware interrupts
  attachInterrupt(digitalPinToInterrupt(rightEncoderA), rightEncoderEvent, CHANGE);
  attachInterrupt(digitalPinToInterrupt(rightEncoderB), rightEncoderEvent, CHANGE);
  attachInterrupt(digitalPinToInterrupt(leftEncoderA), leftEncoderEvent, CHANGE);
  attachInterrupt(digitalPinToInterrupt(leftEncoderB), leftEncoderEvent, CHANGE);

  pinMode(rightMotorM1, OUTPUT);
  pinMode(rightMotorM2, OUTPUT);
  pinMode(leftMotorM1, OUTPUT);
  pinMode(leftMotorM2, OUTPUT);
  
  Serial.begin(115200);
}

void loop() {
  if (Serial.available() > 0) {

    // read the incoming byte:

    String comando = Serial.readString();  //read until timeout

    comando.trim();   

    if (comando == "medirDerecho") {
      estado = 1;
      seleccionMotor = 1;
      motorM1 = rightMotorM1;
      motorM2 = rightMotorM2;
      tUltimaLecturaDerecha = millis();
      pulsosAntesArranque = rightCount;
      velArranque = velArranqueInicial;

    } else if (comando == "medirIzquierdo") {
      estado = 1;
      seleccionMotor = 2;
      motorM1 = leftMotorM1;
      motorM2 = leftMotorM2;
      tUltimaLecturaIzquierda = millis();
      pulsosAntesArranque = leftCount;
      velArranque = velArranqueInicial;

    } else if (comando == "reset") {
      rightCount = 0;
      leftCount = 0;
      estado = 0;
    } 

  }

  if (seleccionMotor == 1) {
    pulsesCount = rightCount;
    tUltimaLectura = tUltimaLecturaDerecha;
  } else {
    pulsesCount = leftCount;
    tUltimaLectura = tUltimaLecturaIzquierda;
  }
  

  switch (estado) {
    case 0:
      analogWrite(motorM1, 0); 
      analogWrite(motorM2, 0);
      rightCount = 0;
      leftCount = 0;
      break;
    case 1:
      // Calibración de final de carrera inicio
      if (arranque(2)) {
        analogWrite(motorM1, 0); 
        analogWrite(motorM2, pwmMotores);
      }
      
      if (millis() > tUltimaLectura + waitTime && flagArranque) {
        
        analogWrite(motorM1, 0);
        analogWrite(motorM2, 0);
        delay(500); // se espera a que todo movimiento se detenga
        rightCount = 0;
        leftCount = 0;
        estado = 2;
        velArranque = velArranqueInicial;
        pulsosAntesArranque = 0; // era rightCount
        tUltimaLecturaDerecha = millis();
        tUltimaLecturaIzquierda = millis();
      }
      break;
    case 2: 
      // Medición de PPR
      if (arranque(1)) {
        analogWrite(motorM1, pwmMotores); 
        analogWrite(motorM2, 0);
      }
      
      if (millis() > tUltimaLectura + waitTime && flagArranque) {
        
        analogWrite(motorM1, 0);
        analogWrite(motorM2, 0);
        PPR = pulsesCount * 2;
        Serial.print("El PPR es de: ");
        Serial.println(PPR);
        Serial.print("velMedicion");
        Serial.println(pwmMotores);
        rightCount = 0;
        leftCount = 0;
        estado = 0;
      }
      break;
    default:
      estado = 0;
      break;
  }
  // Serial.print("Right Count: ");
  // Serial.println(estado);
  // Serial.println();
  delay(50);
}



// encoder event for the interrupt call
void rightEncoderEvent() {
  // if (digitalRead(rightEncoderA) == HIGH) {
  //   if (digitalRead(rightEncoderB) == LOW) {
  //     rightCount++;
  //   } else {
  //     rightCount--;
  //   }
  // } else {
  //   if (digitalRead(rightEncoderB) == LOW) {
  //     rightCount--;
  //   } else {
  //     rightCount++;
  //   }
  // }
  rightCount++;
  tUltimaLecturaDerecha = millis();
}

// encoder event for the interrupt call
void leftEncoderEvent() {
  // if (digitalRead(rightEncoderA) == HIGH) {
  //   if (digitalRead(rightEncoderB) == LOW) {
  //     rightCount++;
  //   } else {
  //     rightCount--;
  //   }
  // } else {
  //   if (digitalRead(rightEncoderB) == LOW) {
  //     rightCount--;
  //   } else {
  //     rightCount++;
  //   }
  // }
  leftCount++;
  tUltimaLecturaIzquierda = millis();
}

bool arranque(int direccion) {
  if (direccion == 1) {
    analogWrite(motorM1, velArranque); 
    analogWrite(motorM2, 0);
  } else {
    analogWrite(motorM1, 0); 
    analogWrite(motorM2, velArranque);
  }

  if (pulsesCount > pulsosAntesArranque + 5) {
    if (estado == 1) {
      pwmMotores = velArranque *0.7; //0.7}
      // No se permite un valor menor al necesario para mantener en movimiento cualquier motor
      if (pwmMotores < pwmMinimo) {
        pwmMotores = pwmMinimo;
      }
    }
    Serial.print("vel arranque");
    Serial.println(velArranque);
    flagArranque = 1;
    return 1;
  }
  velArranque++;
  flagArranque = 0;
  return 0;
}
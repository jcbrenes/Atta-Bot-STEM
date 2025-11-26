// Proyecto Atta-bot-STEM del Tecnológico de Costa Rica
// Código para la calibración del PPR de los motores N20

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

const int PPRminimo = 100; // una medicion que resulte menor o igual a esto será descartada

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

int pwmMinimo = 40; //pwm mínimo para mantener cualquier motor en movimiento 40
const int velArranqueInicial = 35; // pwm mínimo que podría arrancar algún motor
const int numMedicionesPorRealizar = 10;

int numMedicion = 0;
int mediciones[numMedicionesPorRealizar];

int pwmMotores = 30;
unsigned long waitTime = 1000; //1000

unsigned long tUltimaLecturaDerecha;
unsigned long tUltimaLecturaIzquierda;
unsigned long tUltimaLectura;
unsigned long tUltimoAumentoVel;

volatile bool dirMotorDerecho = 1;
volatile bool dirMotorIzquierdo = 1;
bool dirMotorEnArranque = 1;
bool ultimaDirMotorDerecho = 1;
bool ultimaDirMotorIzquierdo = 1;
bool cambioDir = 0;
float PPR = 0;

int velArranque = velArranqueInicial;
bool flagArranque = 0;

float factorVel = 0.7;

// encoder event for the interrupt call
// void IRAM_ATTR rightEncoderAEvent() {
//   int estado = digitalRead(rightEncoderA);
//   if (estado == HIGH) {
//     // Evento RISING
//     dirMotorDerecho = digitalRead(rightEncoderB);
//   } 
//   rightCount++;
//   tUltimaLecturaDerecha = millis();
// }

#include "driver/gpio.h"

//******************************************************************************************************************
// Función para el registro de un pulso del encoder A del motor derecho y la dirección de movimiento de este motor
//
// Se utiliza la lectura de los pines de los encoder para determinar la dirección de movimiento.
//******************************************************************************************************************
void IRAM_ATTR rightEncoderAEvent() {
  if (gpio_get_level((gpio_num_t) rightEncoderA)) {
    dirMotorDerecho = gpio_get_level((gpio_num_t) rightEncoderB);
    
  }
  rightCount++;
  tUltimaLecturaDerecha = micros();
}

//******************************************************************************************************************
// Función para el registro de un pulso del encoder B del motor derecho
//
// Esta función solo registra el pulso notado en el encoder.
//******************************************************************************************************************
void IRAM_ATTR rightEncoderBEvent() {
  rightCount++;
  tUltimaLecturaDerecha = micros();
}

//******************************************************************************************************************
// Función para el registro de un pulso del encoder A del motor izquierdo y la dirección de movimiento de este motor
//
// Se utiliza la lectura de los pines de los encoder para determinar la dirección de movimiento.
//******************************************************************************************************************
void IRAM_ATTR leftEncoderAEvent() {
  if (gpio_get_level((gpio_num_t) leftEncoderA)) {
    dirMotorIzquierdo = gpio_get_level((gpio_num_t) leftEncoderB);
    
  }
  leftCount++;
  tUltimaLecturaIzquierda = micros();
}

//******************************************************************************************************************
// Función para el registro de un pulso del encoder B del motor izquierdo
//
// Esta función solo registra el pulso notado en el encoder.
//******************************************************************************************************************
void IRAM_ATTR leftEncoderBEvent() {
  leftCount++;
  tUltimaLecturaIzquierda = micros();
}

// // encoder event for the interrupt call
// void IRAM_ATTR rightEncoderRising() {
//   dirMotorDerecho = digitalRead(rightEncoderB);
//   rightCount++;
//   tUltimaLecturaDerecha = millis();
//   // rightEncoderEvent();
// }



// // encoder event for the interrupt call
// void IRAM_ATTR leftEncoderRising() {
//   dirMotorIzquierdo = digitalRead(leftEncoderB);
//   leftEncoderEvent();
// }

void setup() {
  pinMode(rightEncoderB, INPUT);
  pinMode(rightEncoderA, INPUT);
  pinMode(leftEncoderB, INPUT);
  pinMode(leftEncoderA, INPUT);
  
  // initialize hardware interrupts
  attachInterrupt(digitalPinToInterrupt(rightEncoderA), rightEncoderAEvent, CHANGE);
  attachInterrupt(digitalPinToInterrupt(rightEncoderB), rightEncoderBEvent, CHANGE);
  attachInterrupt(digitalPinToInterrupt(leftEncoderA), leftEncoderAEvent, CHANGE);
  attachInterrupt(digitalPinToInterrupt(leftEncoderB), leftEncoderBEvent, CHANGE);
  // attachInterrupt(digitalPinToInterrupt(rightEncoderA), rightEncoderEvent, FALLING);
  // // // attachInterrupt(digitalPinToInterrupt(rightEncoderB), rightEncoderEvent, FALLING);
  // attachInterrupt(digitalPinToInterrupt(leftEncoderA), leftEncoderEvent, FALLING);
  // // attachInterrupt(digitalPinToInterrupt(leftEncoderB), leftEncoderEvent, FALLING);

  pinMode(rightMotorM1, OUTPUT);
  pinMode(rightMotorM2, OUTPUT);
  pinMode(leftMotorM1, OUTPUT);
  pinMode(leftMotorM2, OUTPUT);

  // Inicialización del arreglo donde se guardará el valor de cada medición de PPR realizada
  for (int i = 0; i < numMedicionesPorRealizar; i++) {
    mediciones[i] = 0;
  }
  
  Serial.begin(115200);
}

void loop() {
  // La comunicación de inicio de una prueba y el resultado de la medición se reciben por comunicación serial
  if (Serial.available() > 0) {

    String comando = Serial.readString();  //lectura de lo escrito en el monitor serial

    comando.trim(); // se elimina el caracter especial del final del string

    // Antes de realizar una medición, es necesario que se coloque el acrílico de calibración en el eje del motor por analizar

    if (comando == "medirDerecho") { //medición del PPR del motor  derecho
      estado = 1;
      seleccionMotor = 1;
      motorM1 = rightMotorM1;
      motorM2 = rightMotorM2;
      tUltimaLecturaDerecha = micros();
      pulsosAntesArranque = rightCount;
      velArranque = velArranqueInicial;
      numMedicion = 0;

    } else if (comando == "medirIzquierdo") { //medición del PPR del motor izquierdo
      estado = 1;
      seleccionMotor = 2;
      motorM1 = leftMotorM1;
      motorM2 = leftMotorM2;
      tUltimaLecturaIzquierda = micros();
      pulsosAntesArranque = leftCount;
      velArranque = velArranqueInicial;
      numMedicion = 0;

    } else if (comando == "reset") { // detiene el procedimiento y el motor
      rightCount = 0;
      leftCount = 0;
      estado = 0;
    } 

  }

  // Permite asignar a una sola variable la cantidad de pulsos que sea relevante según si se mide el motor der o izq
  if (seleccionMotor == 1) {
    pulsesCount = rightCount;
    tUltimaLectura = tUltimaLecturaDerecha;
  } else {
    pulsesCount = leftCount;
    tUltimaLectura = tUltimaLecturaIzquierda;
  }
  
  // Máquina de estados
  // estado = 0 (reposo): el motor se apaga y las cuentas de PPR se reinician constantemente
  // estado = 1 (preparación): se mueve el brazo de calibración hasta el tope de uno de los lados, y se determina la velocidad más adecuada para la medición si es la primera vez que se da este estado
  // estado = 2 (medición): el brazo gira lentamente hasta topar con el límite, se mide durante este tiempo la cantidad de pulsos detectados
  switch (estado) {
    case 0: // Reposo
      analogWrite(motorM1, 0); 
      analogWrite(motorM2, 0);
      rightCount = 0;
      leftCount = 0;
      break;
    case 1: // Preparación
      // Calibración de final de carrera inicio

      // Si el motor ya arrancó, se mueve a una velocidad reducida
      if (arranque(2)) {
        analogWrite(motorM1, 0); 
        analogWrite(motorM2, pwmMotores);
        
      }
      
      // Si el motor ya había arrancado y ahora ha permanecido detenido por un tiempo waitTime, se detiene el movimiento y se avanza al estado 2
      if (millis() > tUltimaLectura/1000 + waitTime && flagArranque) {
        
        analogWrite(motorM1, 0);
        analogWrite(motorM2, 0);
        delay(500); // se espera a que todo movimiento se detenga
        PPR = pulsesCount * 2;
        // Para los motores de alrededor de 800 PPR se utilizan estas variables que permiten mejor medicion
        if (numMedicion == 0 & PPR > 700) {
          factorVel = 0.5;
          pwmMinimo = 34;
          Serial.println("hi");
        }
        rightCount = 0;
        leftCount = 0;

        estado = 2;
        velArranque = velArranqueInicial;
        pulsosAntesArranque = 0; 
        tUltimaLecturaDerecha = micros();
        tUltimaLecturaIzquierda = micros();
        flagArranque = 0;
      }
      break;
    case 2: // Medición de PPR
      // Si no se ha arrancado se llama a la función, si ya se arrancó se envía un movimiento más lento
      if (!flagArranque) {
        arranque(1);
      } else {
        analogWrite(motorM1, pwmMotores); 
        analogWrite(motorM2, 0);
        
      }
      // Se evalúa si el motor cambió de dirección, esto significaría un rebote del brazo de calibración por lo que se desea terminar inmediatamente la medición en ese punto
      if (seleccionMotor == 1){
        cambioDir = dirMotorDerecho == dirMotorEnArranque;
      }
      else if (seleccionMotor == 2){
        cambioDir = dirMotorIzquierdo == dirMotorEnArranque;
      }
      
      // Si el motor ha estado activo por waitTime sin que haya habido pulso ninguno en los encoder, o si se cambió de dirección, se detiene la medición
      if ((millis() > tUltimaLectura/1000 + waitTime || cambioDir) && flagArranque) {
        
        analogWrite(motorM1, 0);
        analogWrite(motorM2, 0);
        PPR = pulsesCount * 2; // debido a que solo se está midiendo media revolución, el PPR será el doble de lo detectado
        mediciones[numMedicion] = PPR;
        Serial.print("Valor de medición ");
        Serial.print(numMedicion+1);
        Serial.print(" de PPR: ");
        Serial.print(PPR);
      
        rightCount = 0;
        leftCount = 0;

        // Se evalúa si es necesario hacer más mediciones o si esta era la última
        if (numMedicion < numMedicionesPorRealizar - 1 || PPR <= PPRminimo) { // si faltan todavía mediciones, o si una medicion es mala, se vuelve al estado 1 (preparación)
          estado = 1;
          pulsosAntesArranque = pulsesCount;
          velArranque = velArranqueInicial;
          tUltimaLecturaDerecha = micros();
          tUltimaLecturaIzquierda = micros();
          // pwmMotores = velArranqueInicial;
          if (PPR > PPRminimo) {
            numMedicion++;
            Serial.println();
          } else {
            Serial.println(" ---- Medicion descartada");
          }
        } else { // si esta era la última medición
          // Se calcula el promedio de las mediciones de PPR
          float suma = 0;
          for (int i = 0; i < numMedicionesPorRealizar; i++) {
            suma = suma + mediciones[i];
          }
          float promedio = suma / numMedicionesPorRealizar;
          Serial.println();
          Serial.print("El promedio de PPR es: ");
          Serial.println(promedio);
          estado = 0;
        }
        flagArranque = 0;
      }
      break;
    default:
      estado = 0;
      break;
  }
  // Serial.print("Right Count: ");
  // Serial.println(dirMotorEnArranque);
  // Serial.println();
  delay(1);
}

//******************************************************************************************************************
// Función para arranque del motor
//
// Esta función envía un PWM cada vez mayor al motor, hasta que se detecte suficiente avance en los encoders.
//
// @param direccion La dirección en la que se debe mover el motor: 2 para la preparación y 1 para la medición.
//
// @return true si el motor ya arrancó.
//******************************************************************************************************************
bool arranque(int direccion) {
  // Mientras el motor no haya arrancado, se envía un PWM 
  if (!flagArranque) {
    if (direccion == 1) {
      analogWrite(motorM1, velArranque); 
      analogWrite(motorM2, 0);
    } else {
      analogWrite(motorM1, 0); 
      analogWrite(motorM2, velArranque);
    }

    // Si se detectan más de 10 pulsos en el motor, se determina que el motor ya arrancó
    if (pulsesCount > 10 && !flagArranque) {
      if (estado == 1 && numMedicion == 0) { // si se está en el estado 1 y es la primera medición
        // Se define la velocidad (PWM) que se utilizará para las mediciones
        pwmMotores = velArranque *factorVel; //0.7
        // No se permite un valor menor al necesario para mantener en movimiento cualquier motor
        if (pwmMotores < pwmMinimo) {
          pwmMotores = pwmMinimo;
        }
        if (seleccionMotor == 1){
          dirMotorEnArranque = dirMotorDerecho;
        } else{
          dirMotorEnArranque = dirMotorIzquierdo;
        }
      }
      // Serial.print("vel arranque");
      // Serial.println(pwmMotores);
      flagArranque = 1;
      return 1;
    }
    // Se aumenta gradualmente el PWM usado para el arranque
    if (millis() > tUltimoAumentoVel + 1000) {
      velArranque = velArranque + 5;
      tUltimoAumentoVel = millis();
    }
  }
  
  
  //flagArranque = 0;
  return 0;
}
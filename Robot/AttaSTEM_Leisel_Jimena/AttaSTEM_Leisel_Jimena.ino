#include <ESP32Servo.h>
#include <ArduinoBLE.h>
#include <string>
using namespace std;

// Robot constants
const int samplingTime = 25; // units: miliseconds
const float pulsesPerRev = 574; // number of pulses from a single encoder output
const float wheelRadius = 22.5; // Wheel circumference = 139.5mm
const float distanceWheelToWheel = 104;
const float distanceCenterToWheel = distanceWheelToWheel / 2 ; // Turning radius of the robot, distance in mm between the center and one wheel

// Constants for PID control with samplingTime = 25ms
const float targetSpeed = 120.0; // Target speed for the robot in mm/s
const float kpSpeed = 0.75; // Proportional constant for speed control
const float kiSpeed = 2; // Integral constant for speed control
const float kdSpeed = 0.0; // Derivative constant for speed control (set to zero for no derivative action)

// Constants for PID control implementation
const int minIntegralErrorSpeed = -255; // Minimum value for integral error to avoid windup
const int maxIntegralErrorSpeed = 255; // Maximum value for integral error to avoid windup

const int upperDutyCycleLimitSpeed = 200; // Maximum allowed PWM value for speed control
const int lowerDutyCycleLimitSpeed = 60; // Minimum allowed PWM value for speed control

// Error accumulation for speed PID control
float sumErrorVelRight = 0; // Accumulated integral error for the right wheel
float prevErrorVelRight = 0; // Previous error value for the right wheel (used for derivative calculation)
float sumErrorVelLeft = 0; // Accumulated integral error for the left wheel
float prevErrorVelLeft = 0; // Previous error value for the left wheel (used for derivative calculation)

int distanceTraveled = 0; // Variable to track the total distance traveled by the robot
const float correctionFactorLines = 0.92; 


int prevPWMRight = 0;
int prevPWMLeft = 0;

// For speed sampling
unsigned long previousTime = 0;

// Variables to keep track of the encoder state
volatile long leftEncoderPos = 0; // Current position of the left encoder (in ticks)
long leftTicksForSpeed = 0; // Number of encoder ticks counted for left wheel speed calculation
long leftPrevTicks = 0; // Previous encoder tick count for the left wheel (used to calculate speed) 
volatile long rightEncoderPos = 0; // Current position of the right encoder (in ticks)
long rightTicksForSpeed = 0; // Number of encoder ticks counted for right wheel speed calculation
long rightPrevTicks = 0; // Previous encoder tick count for the right wheel (used to calculate speed)

// Variables to store the servo position
const int activateAngle = 115;  // Activated Tool
const int deactivateAngle = 180; // Deactivated Tool
int set = 0;


// Create a Servo object to control the MG90S
Servo myServo;


// Define pin for the servo signal
const int servoPin = 26;

// Define the encoder pins
const int rightEncoderA = 27; // Pin for the right encoder's channel A
const int rightEncoderB = 33; // Pin for the right encoder's channel B

const int leftEncoderA = 32; // Pin for the left encoder's channel A
const int leftEncoderB = 35; // Pin for the left encoder's channel B

// Motor control pins
const int rightMotorM1 = 13;   // Direction control pin 1 for the right motor
const int rightMotorM2 = 15;   // Direction control pin 2 for the right motor


const int leftMotorM1 = 14;   // Direction control pin 1 for the left motor
const int leftMotorM2 = 12;   // Direction control pin 1 for the left motor

// Obstacle sensors setup
const int rightInfraredSensor = 4; // Pin for the right infrared obstacle sensor
const int leftInfraredSensor = 34;  // Pin for the right infrared obstacle sensor

// Tracker sensors setup
const int rightTrackerSensor = 36;  // Pin for the right tracker sensor
const int leftTrackerSensor = 39;   // Pin for the left tracker sensor

// Buttons setup
const int startButtonPin = 25;      // Pin for the start button
const int stopButtonPin = 23;       // Pin for the stop button

int currentStep = 0; // Variable to keep track of the current step
unsigned long stepStartTime = 0; // Variable to track the start time of each step


//variables máquina de estados
enum posibles_Estados {ESPERA=0, LEE_MEMORIA, MOVERSE, GIRAR, DETENERSE, CICLO, OBSTACULOS, MOVIMIENTO_OBSTACULO, HERRAMIENTA, NADA};
posibles_Estados estado = ESPERA;
bool giro_listo = false;
bool movimiento_listo = true; 
bool obstaculos_activo = false;
bool primer_ciclo = true;
bool retroceso_listo = true;
bool obstaculo_detectado=false;
bool paro_emergencia=false;

//variables para comunicación Bluetooth
string mensajeBLE="ATINIAV020GD030CI003RE010GI090CIFINATFIN";  
BLEService servicio("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
BLEStringCharacteristic caracteristico("beb5483e-36e1-4688-b7f5-ea07361b26a8", BLERead | BLEWrite, 512);
//char nombreBLErobot= "AttaBotSTEM";

//apuntadores y variables para la lista de instrucciones
enum posibles_Instrucciones {inst_Avanzar=1, inst_Retroceder, inst_GiroIzquierdo, inst_GiroDerecho, inst_CicloInicia, inst_CicloFin, inst_ObstaculoInicia, inst_ObstaculoFin, inst_HerramientaInicia, inst_HerramientaFin, inst_FinalMsg};
short lista_instrucciones[100][2];
short inst_final = 0;
short inst_actual = 0;
short instruccion = 0;
short valor_instruccion = 0;
short inst_inicio_ciclo = 0;
short cantidad_ciclos = 0;



//******************************************************************************************************************
// Function that updates the position of the right wheel encoder.
//
// This function increments the encoder position counter for the right wheel each time it is called. The counter 
// reflects the accumulated encoder pulses, allowing for the calculation of distance or speed based on pulses.
//
//******************************************************************************************************************
void rightUpdateEncoder() {
  // Update encoder positions based on direction
  rightEncoderPos ++;

}

//******************************************************************************************************************
// Function that updates the position of the left wheel encoder.
//
// This function increments the encoder position counter for the left wheel each time it is called. The counter 
// reflects the accumulated encoder pulses, which can be used to determine distance or speed based on pulse count.
//
//******************************************************************************************************************
void leftUpdateEncoder() {
  // Update encoder positions based on direction
  leftEncoderPos ++;
}


void setup() {

  // Set the PWM properties (50 Hz is typical for servos)
  myServo.setPeriodHertz(50);    // Standard 50Hz servo
  myServo.attach(servoPin, 500, 2400);  // Attach the servo on the pin with min/max pulse widths

  // Set encoder pins as inputs
  pinMode(rightEncoderA, INPUT_PULLUP);
  pinMode(rightEncoderB, INPUT_PULLUP);

  pinMode(leftEncoderA, INPUT_PULLUP);
  pinMode(leftEncoderB, INPUT_PULLUP);

  pinMode(rightMotorM1, OUTPUT);
  pinMode(rightMotorM2, OUTPUT);

  pinMode(leftMotorM1, OUTPUT);
  pinMode(leftMotorM2, OUTPUT);

  //Obstacle sensors set up
  pinMode(rightInfraredSensor, INPUT);
  pinMode(leftInfraredSensor, INPUT);

  // Tracker sensors set up
  pinMode(rightTrackerSensor, INPUT);
  pinMode(leftTrackerSensor, INPUT);

  //Buttons set up
  pinMode(startButtonPin, INPUT_PULLUP);
  pinMode(stopButtonPin, INPUT_PULLUP);

  // Attach interrupts to encoder pins
  attachInterrupt(digitalPinToInterrupt(rightEncoderA), rightUpdateEncoder, CHANGE);
  attachInterrupt(digitalPinToInterrupt(rightEncoderB), rightUpdateEncoder, CHANGE);

  attachInterrupt(digitalPinToInterrupt(leftEncoderA), leftUpdateEncoder, CHANGE);
  attachInterrupt(digitalPinToInterrupt(leftEncoderB), leftUpdateEncoder, CHANGE);

  Serial.begin(115200);
  //Inicialización comunicación bluetooth BLE
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
    while (1);
  }
  BLE.setLocalName("AttaBotSTEM");
  BLE.setAdvertisedService(servicio);
  servicio.addCharacteristic(caracteristico);
  BLE.addService(servicio);
  BLE.advertise();

}


void loop() {
 
  BLEDevice central = BLE.central();

  bool lecturaBotonStart=digitalRead( startButtonPin );
  bool lecturaBotonStop=digitalRead( stopButtonPin );
  bool lecturaInfrarrojoDerecho=digitalRead(rightInfraredSensor);
  bool lecturaInfrarrojoIzquierdo=digitalRead(leftInfraredSensor);
  bool lecturaSensorTrackerDerecho=digitalRead(rightTrackerSensor);
  bool lecturaSensorTrackerIzquierdo=digitalRead(leftTrackerSensor);

  //Máquina de estados principal
  switch (estado) {

    case ESPERA:  { 
      //Leer comunicación por BLE
      if (central) {

        if (central.connected()) {//era un while
          if (caracteristico.written()) {
            mensajeBLE = string( caracteristico.value().c_str() );
            caracteristico.writeValue("");
          }
        }
      }
      //Lógica de estado siguiente
      if (!lecturaBotonStart ) { 
          Interpreta_mensajeBLE(mensajeBLE); 
          delay (1000);
          estado = LEE_MEMORIA;
          inst_actual = 0;
          
      }
      break;
    }

    case LEE_MEMORIA:  { 
      if ( inst_actual != inst_final ){
        instruccion = lista_instrucciones[inst_actual][0];
        valor_instruccion = lista_instrucciones[inst_actual][1];
        if ( inst_actual == inst_final ){ //Si esta en la instruccion de final, deja el apuntador en cero
        inst_actual = 0;
        }else {
        inst_actual++;
        }
      }
      //Lógica estado siguiente
      if (!lecturaBotonStop  ||  inst_actual == inst_final) { 
        estado = ESPERA;

      }else if (instruccion == inst_Avanzar) {
        estado = MOVERSE;

      }else if (instruccion == inst_Retroceder) {
        estado = MOVERSE;
        valor_instruccion = valor_instruccion * -1;

      }else if (instruccion == inst_GiroIzquierdo) {
        estado = GIRAR;
        valor_instruccion = valor_instruccion * -1;

      }else if (instruccion == inst_GiroDerecho) {
        estado = GIRAR;
      
      }else if (instruccion == inst_CicloInicia  ||  instruccion == inst_CicloFin) {
        estado = CICLO;

      }else if (instruccion == inst_ObstaculoInicia  ||  instruccion == inst_ObstaculoFin) {
        estado = OBSTACULOS;
      
      }else if (instruccion == inst_HerramientaInicia  ||  instruccion == inst_HerramientaFin) {
        estado = HERRAMIENTA;
      }

      break; 
    }
    
    case MOVERSE: {

      //Ejecuta el estado de avanzar o retroceder
      //(es el mismo pero con distancia negativa)
      movimiento_listo= advanceDesiredDistance(valor_instruccion*10);

      //Lógica estado siguiente
      if (!lecturaBotonStop) { 
        paro_emergencia=true;
        estado = DETENERSE;

      }else if ( movimiento_listo ) {
        estado = DETENERSE;
      }
      else if (obstaculos_activo) {
        if (!lecturaInfrarrojoDerecho||!lecturaInfrarrojoIzquierdo||lecturaSensorTrackerDerecho||lecturaSensorTrackerIzquierdo){
          obstaculo_detectado=true;
          estado=DETENERSE;
        }
      }
      break;
    }

    case GIRAR: {

      //Ejecuta el estado de girar derecha o izquierda
      //(es el mismo pero con ángulo negativo)

      //giro
      movimiento_listo= turnDesiredAngle(valor_instruccion);

      //Lógica estado siguiente
      if (!lecturaBotonStop) {
        paro_emergencia=true; 
        estado = DETENERSE;

      }else if ( movimiento_listo ) {
        //movimiento_listo = false;
        estado = DETENERSE;
      }
      else if (obstaculos_activo) {
        if (!lecturaInfrarrojoDerecho||!lecturaInfrarrojoIzquierdo||lecturaSensorTrackerDerecho||lecturaSensorTrackerIzquierdo){
          obstaculo_detectado=true;
          estado=DETENERSE;
        }
      }
      break;
    }

    case DETENERSE: {

      if (!lecturaBotonStop || paro_emergencia || obstaculo_detectado) { //en caso de apretar STOP o detectar obstaculo
        configureHBridge(false, 3, 0, 0); //Detiene el robot 
      } // Ojo que la funcion avanzar y girar ya detiene el robot al final
        //configureHBridgeTurn(false, 3, 0, 0);
      delay(500);
            
      //Lógica estado siguiente
      if (paro_emergencia){
        paro_emergencia=false;
        estado= ESPERA;     
      } else if (obstaculo_detectado){
        estado = MOVIMIENTO_OBSTACULO;
      } else {
        estado = LEE_MEMORIA;
      }
      break;
    }

    case CICLO: {

      if ( instruccion == inst_CicloInicia  &&  primer_ciclo ){ //inicio ciclo, primera vez
        cantidad_ciclos = valor_instruccion;  //guarda cantidad de ciclos, primero 
        primer_ciclo = false;
        inst_inicio_ciclo = inst_actual-1;  //almacena apuntador a inicio de ciclo
        cantidad_ciclos--; //resta el primer ciclo que se va a ejecutar

      }else if ( instruccion == inst_CicloInicia  &&  !primer_ciclo ) { //inicio de ciclo, resto de veces
        cantidad_ciclos--;  //resta 1 a la cantidad de ciclos

      }else if ( instruccion == inst_CicloFin  &&  cantidad_ciclos != 0 ) { //final de ciclo, ciclos pendientes
        inst_actual = inst_inicio_ciclo; //devuelve el apuntador al inicio del ciclo

      }else if ( instruccion == inst_CicloFin  &&  cantidad_ciclos == 0 ) { //final de ciclo, última vez
        primer_ciclo = true; //reset de variable
      }


      //Lógica estado siguiente
      if (!lecturaBotonStop) { 
        estado = ESPERA;
      } else {
        estado = LEE_MEMORIA;
      } 
      break;
    }

    case OBSTACULOS: {

      //*Activa la bandera de si detectar obstáculos y luego la desactiva
      if ( instruccion == inst_ObstaculoInicia ){
        obstaculos_activo = true;
      }else if ( instruccion == inst_ObstaculoFin ) {
        obstaculos_activo = false;
      }

      //Lógica estado siguiente
      if (!lecturaBotonStop) { 
        estado = ESPERA;
      } else {
        estado = LEE_MEMORIA;
      } 
      break;
    }

    case MOVIMIENTO_OBSTACULO: {
      // *Genera el movimiento despues que un obstaculo se detectó, el cual corresponde a un retroceso
      retroceso_listo=advanceDesiredDistance(-50);
      obstaculo_detectado=false;
      
      // Lógica estado siguiente
      if (!lecturaBotonStop) { 
        paro_emergencia=true;
        estado = DETENERSE;
      } else if (retroceso_listo){
        estado = ESPERA;
      } 
      break;
    }

    case HERRAMIENTA: {

      //*Activa la bandera de si detectar obstáculos y luego la desactiva
      if ( instruccion == inst_HerramientaInicia ){
        controlServo(true);
      }else if ( instruccion == inst_HerramientaFin ) {
        controlServo(false);
      }

      //Lógica estado siguiente
      if (!lecturaBotonStop) { 
        estado = ESPERA;
      } else {
        estado = LEE_MEMORIA;
      } 
      break;
    }

    case NADA: {
      break;
    }
  }

}



//FUNCIONES DE INTERPRETACION DE MENSAJES

//***************************************************************************************
//Función que interpreta el mensaje recibido de la app de programación
//
//Revisa el mensaje que se recibió por Bluetooth BLE y revisa de 5 en 5 
//los caracteres. Los guarda en un array global luego de interpretar que 
//instrucción es y que valor tienen
//
//@param mensaje Cadena de 512 caracteres máximo recibidos
// 
//***************************************************************************************
void Interpreta_mensajeBLE (string mensaje) {

  for (int i = 0; i < mensaje.length(); i=i+5 ) { 
        
        string comando = mensaje.substr(i, 5);
        string instruccion = mensaje.substr(i, 2);
        string valor_instruccion =  mensaje.substr(i+2, 3);

        
        //if (comando.compare("ATINI")==0) {
        if (comando == "ATINI"){
          inst_actual = 0;
        
        }else if (comando == "ATFIN"){
          inst_final = i/5;
        
        }else if (comando == "OBINI"){
          lista_instrucciones[inst_actual][0] = inst_ObstaculoInicia;
          lista_instrucciones[inst_actual][1] = 0;
          inst_actual++;

        }else if (comando == "OBFIN"){
          lista_instrucciones[inst_actual][0] = inst_ObstaculoFin;
          lista_instrucciones[inst_actual][1] = 0;
          inst_actual++;

        }else if (comando == "CIFIN"){
          lista_instrucciones[inst_actual][0] = inst_CicloFin;
          lista_instrucciones[inst_actual][1] = 0;
          inst_actual++;  

        }else if (instruccion == "CI" && comando != "CIFIN"){
          short valor = stoi (valor_instruccion);
          lista_instrucciones[inst_actual][0] = inst_CicloInicia;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;

        }else if (instruccion == "AV"){
          short valor = stoi (valor_instruccion);
          lista_instrucciones[inst_actual][0] = inst_Avanzar;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;

        }else if (instruccion == "RE"){
          short valor = stoi (valor_instruccion);
          lista_instrucciones[inst_actual][0] = inst_Retroceder;
          lista_instrucciones[inst_actual][1]= valor;
          inst_actual++;

        }else if (instruccion == "GI"){
          short valor = stoi (valor_instruccion);
          lista_instrucciones[inst_actual][0] = inst_GiroIzquierdo;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;

        }else if (instruccion == "GD"){
          short valor = stoi (valor_instruccion);
          lista_instrucciones[inst_actual][0] = inst_GiroDerecho;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;
        
        }else if (comando == "HEINI"){
          lista_instrucciones[inst_actual][0] = inst_HerramientaInicia;
          lista_instrucciones[inst_actual][1] = 0;
          inst_actual++;

        }else if (comando == "HEFIN"){
          lista_instrucciones[inst_actual][0] = inst_HerramientaFin;
          lista_instrucciones[inst_actual][1] = 0;
          inst_actual++;
        }
  }
  inst_actual = 0; 
}



//******************************************************************************************************************
// Function that controls the servo based on the variable `set`. If `set` is 1, the tool is activated; otherwise, it is deactivated.
//
// This function adjusts the servo angle to activate or deactivate the tool based on the `set` value.
//
// @param set Value that determines whether the tool is activated (1) or deactivated (0).
//
// @return true Returns true upon successful action.
//******************************************************************************************************************
bool controlServo(bool set) {
  if (set) {
    // Activate the tool by setting it to 110 degrees
    myServo.write(activateAngle);
  } else { //Deactivate the tool by setting it to 180 degrees
    myServo.write(deactivateAngle);
  }
  return true;  // Action completed
}

//******************************************************************************************************************
// Function that controls the speed of the wheels using a PID controller based on the reference and actual speeds.
//
// This function calculates a PWM output for the motors by applying a PID control loop to match the actual speed to a setpoint.
//
// @param refSpeed The target speed for the motor.
// @param actualSpeed The current speed of the motor.
// @param sumErrorSpeed Accumulated integral error for the speed PID.
// @param prevErrorSpeed Previous speed error for the derivative calculation.
//
// @return The computed PWM signal as an integer to control the motor speed.
//******************************************************************************************************************
int controlWheelSpeed(float refSpeed, float actualSpeed, float& sumErrorSpeed, float& prevErrorSpeed) {
  
  // Calculate the error between the reference speed and the actual speed
  float errorSpeed = refSpeed - actualSpeed;

  // Update the integral error by accumulating the current error over time
  // Multiply by 0.01 to scale the contribution of the error (based on sampling time)
  sumErrorSpeed += errorSpeed * 0.01;

  // Constrain the integral error to avoid windup
  sumErrorSpeed = constrain(sumErrorSpeed, minIntegralErrorSpeed , maxIntegralErrorSpeed);

  // Calculate the derivative of the error (difference between current and previous error)
  float diffErrorSpeed = (errorSpeed - prevErrorSpeed);

  // PID control equation to calculate the control output
  float pidOutput = (kpSpeed * errorSpeed) + (kiSpeed * sumErrorSpeed) + (kdSpeed * diffErrorSpeed);

  // Constrain the PID output to avoid saturation and ensure it stays within motor PWM limits
  pidOutput = constrain((int)pidOutput, lowerDutyCycleLimitSpeed, upperDutyCycleLimitSpeed);

  // Update the previous error for the next iteration of the control loop
  prevErrorSpeed = errorSpeed;
  
  // Return the calculated PWM value as an integer
  return (int)pidOutput;
}

//******************************************************************************************************************
// Function that moves the robot a desired linear distance using PID control to maintain speed and direction.
//
// This function continuously calculates the speed of each wheel, adjusts the motor PWM values, and checks if the robot has reached the desired distance.
//
// @param desiredDistance The target distance in mm that the robot should travel.
//
// @return true if the desired distance is reached; false otherwise.
//******************************************************************************************************************
bool advanceDesiredDistance(int desiredDistance) {

  // Flag to indicate if the robot should move in reverse
  bool reverse = false;

  // Create a time condition using millis to apply a sampling time without delays
  unsigned long currentTime = millis(); // Get the current time in milliseconds
  unsigned long deltaTime = currentTime - previousTime; // Time elapsed since the last sample

  // Check if the elapsed time has reached the sampling time (10 ms)
  if (deltaTime >= samplingTime) {
    previousTime = currentTime; // Reset previous time for the next sample

    // Convert deltaTime to seconds
    float deltaTimeSec = deltaTime / 1000.0;


    // Calculate the number of encoder ticks since the last sample
    rightTicksForSpeed = rightEncoderPos - rightPrevTicks;
    leftTicksForSpeed = leftEncoderPos - leftPrevTicks;

    
    // Calculate the current speeds of both wheels based on the encoder ticks
    float actualSpeedLeft = calculateSpeed(leftTicksForSpeed, deltaTimeSec); // Speed of the left wheel in mm/s
    float actualSpeedRight = calculateSpeed(rightTicksForSpeed, deltaTimeSec); // Speed of the right wheel in mm/s

    // Update the previous encoder tick counts
    rightPrevTicks = rightEncoderPos;
    leftPrevTicks = leftEncoderPos;


    // Set desired speeds

    if (desiredDistance < 0) { // If the desired distance is negative, move in reverse
        reverse = true;
    }

    float speedSetPoint = targetSpeed; // Define the target speed for both wheels (in mm/s)

    // PID control loop for speed to calculate PWM values for both wheel
    int pwmRightWheel = controlWheelSpeed(speedSetPoint, actualSpeedRight, sumErrorVelRight, prevErrorVelRight);
    int pwmLeftWheel = controlWheelSpeed(speedSetPoint, actualSpeedLeft, sumErrorVelLeft, prevErrorVelLeft);



    // Determine if the PWM values for the right and left wheels have changed
    bool rightChanged = (prevPWMRight != pwmRightWheel); // Check if right wheel needs to be updated
    bool leftChanged = (prevPWMLeft != pwmLeftWheel); // Check if left wheel needs to be updated

    // Update the H-Bridge configuration if there are changes in the PWM values
    if (rightChanged) {
      configureHBridge(reverse, 1, pwmRightWheel, pwmLeftWheel);// Update the right motor control
    }
    if (leftChanged) {
      configureHBridge(reverse, 2, pwmRightWheel, pwmLeftWheel);// Update the left motor control
    }
    if (rightChanged && leftChanged) {
      configureHBridge(reverse, 3, pwmRightWheel, pwmLeftWheel); // Update both motors if both values changed
    }

    // Store the current PWM values for comparison in the next iteration
    prevPWMRight = pwmRightWheel;
    prevPWMLeft = pwmLeftWheel;

    
    // Calculate the distance traveled by the robot using encoder data
    float distanceTraveled = calculateLinearDistanceTraveled(leftEncoderPos, rightEncoderPos);

    // Check if the robot has traveled the desired distance
    if (abs(distanceTraveled) >= correctionFactorLines * abs(desiredDistance)) {

      // If the desired distance is reached, stop the robot
      configureHBridge(reverse, 3, 0, 0);

      // Reset PID control values
      sumErrorVelRight = 0;
      prevErrorVelRight = 0;
      sumErrorVelLeft = 0;
      prevErrorVelLeft = 0;

      // Reset encoder tick counts
      rightPrevTicks = 0;
      leftPrevTicks = 0;

      rightEncoderPos = 0;
      leftEncoderPos = 0;

      return true; // Return true to indicate that the desired distance has been reached
    }

  }
  return false; // Return false if the robot has not yet reached the desired distance
}

//******************************************************************************************************************
// Function that turns the robot to a specified angle using PID control for each wheel's speed.
//
// This function calculates the speed of each wheel, updates the H-Bridge configuration to turn, and checks if the robot has turned to the desired angle.
//
// @param desiredAngle The target angle in degrees for the robot to turn.
//
// @return true if the desired angle is reached; false otherwise.
//******************************************************************************************************************
bool turnDesiredAngle (int desiredAngle) {

  // Flag to indicate if the robot should turn in counterClockwise
  bool counterClockwise = false;

  if (desiredAngle < 0) { // If the desired angle is negative, move in counterClockwise
    counterClockwise = true;
  }

  // Create a time condition using millis to apply a sampling time without delays
  unsigned long currentTime = millis(); // Get the current time in milliseconds
  unsigned long deltaTime = currentTime - previousTime; // Time elapsed since the last sample


  // Calculate the linear distance required for the given angle
  float desiredDistance = calculateLinearDistanceDesired(desiredAngle);

  // Check if the elapsed time has reached the sampling time (10 ms)
  if (deltaTime >= samplingTime) {
    previousTime = currentTime; // Reset previous time for the next sample

    // Convert deltaTime to seconds
    float deltaTimeSec = deltaTime / 1000.0;


    // Calculate the number of encoder ticks since the last sample
    rightTicksForSpeed = rightEncoderPos - rightPrevTicks;
    leftTicksForSpeed = leftEncoderPos - leftPrevTicks;

    
    // Calculate the current speeds of both wheels based on the encoder ticks
    float actualSpeedLeft = calculateSpeed(leftTicksForSpeed, deltaTimeSec); // Speed of the left wheel in mm/s
    float actualSpeedRight = calculateSpeed(rightTicksForSpeed, deltaTimeSec); // Speed of the right wheel in mm/s

    // Update the previous encoder tick counts
    rightPrevTicks = rightEncoderPos;
    leftPrevTicks = leftEncoderPos;


    // Set desired speeds

    float speedSetPoint = targetSpeed; // Define the target speed for both wheels (in mm/s)

    // PID control loop for speed to calculate PWM values for both wheel
    int pwmRightWheel = controlWheelSpeed(speedSetPoint, actualSpeedRight, sumErrorVelRight, prevErrorVelRight);
    int pwmLeftWheel = controlWheelSpeed(speedSetPoint, actualSpeedLeft, sumErrorVelLeft, prevErrorVelLeft);

    // Determine if the PWM values for the right and left wheels have changed
    bool rightChanged = (prevPWMRight != pwmRightWheel); // Check if right wheel needs to be updated
    bool leftChanged = (prevPWMLeft != pwmLeftWheel); // Check if left wheel needs to be updated

    // Update the H-Bridge configuration if there are changes in the PWM values
    if (rightChanged) {
      configureHBridgeTurn(counterClockwise, 1, pwmRightWheel, pwmLeftWheel);// Update the right motor control
    }
    if (leftChanged) {
      configureHBridgeTurn(counterClockwise, 2, pwmRightWheel, pwmLeftWheel);// Update the left motor control
    }
    if (rightChanged && leftChanged) {
      configureHBridgeTurn(counterClockwise, 3, pwmRightWheel, pwmLeftWheel); // Update both motors if both values changed
    }

    // Store the current PWM values for comparison in the next iteration
    prevPWMRight = pwmRightWheel;
    prevPWMLeft = pwmLeftWheel;

    // Calculate the distance traveled by the robot using encoder data
    float distanceTraveled = calculateLinearDistanceTraveled(leftEncoderPos, rightEncoderPos);

    // Check if the robot has traveled the desired distance
    if (abs(distanceTraveled) >= abs(desiredDistance)) {

      // If the desired distance is reached, stop the robot
      configureHBridgeTurn(counterClockwise, 3, 0, 0);

      // Reset PID control values
      sumErrorVelRight = 0;
      prevErrorVelRight = 0;
      sumErrorVelLeft = 0;
      prevErrorVelLeft = 0;

      // Reset encoder tick counts
      rightPrevTicks = 0;
      leftPrevTicks = 0;

      rightEncoderPos = 0;
      leftEncoderPos = 0;

      return true; // Return true to indicate that the desired distance has been reached
    }

  }
  return false; // Return false if the robot has not yet reached the desired distance
}

//******************************************************************************************************************
// Function that calculates the speed of a wheel based on encoder pulses and elapsed time.
//
// The function converts the number of pulses into a linear distance, then calculates the speed in mm/s based on the time interval.
//
// @param pulses The number of encoder pulses detected.
// @param deltaTime The time interval in seconds.
//
// @return The calculated speed in mm/s.
//******************************************************************************************************************
float calculateSpeed(long pulses, float deltaTime) {
    // Wheel circumference in mm
    float wheelCircumference = 2 * 3.1416 * wheelRadius;

    // Full revolutions based on the number of pulses
    float revolutions = pulses / pulsesPerRev;

    // Distance traveled in mm
    float distance = revolutions * wheelCircumference;

    //Speed mm/s

    float vel = distance / deltaTime;
    
    return vel;
}

//******************************************************************************************************************
// Function that configures the H-Bridge to control forward or reverse motion of each wheel based on PWM values and direction.
//
// This function sets the PWM for each motor pin depending on the motion direction and update mode.
//
// @param reverse Boolean indicating whether to move in reverse (true) or forward (false).
// @param update Mode to update specific wheels: 1 for right, 2 for left, 3 for both.
// @param pwmRightWheel PWM value for the right wheel.
// @param pwmLeftWheel PWM value for the left wheel.
//******************************************************************************************************************
void configureHBridge(bool reverse, int update, int pwmRightWheel, int pwmLeftWheel){

    // Check if right wheel should be updated (update == 1 or update == 3)
    if (update == 1 || update == 3) {
        if (!reverse) { // Set right wheel for forward direction
            analogWrite(rightMotorM1, pwmRightWheel); // Apply PWM to right motor for forward motion
            analogWrite(rightMotorM2, 0);             // Set right motor reverse pin to 0 (off)
        } else { // Set right wheel for reverse direction
            analogWrite(rightMotorM1, 0);             // Set right motor forward pin to 0 (off)
            analogWrite(rightMotorM2, pwmRightWheel); // Apply PWM to right motor for reverse motion
        }
    }

    // Check if left wheel should be updated (update == 2 or update == 3)
    if (update == 2 || update == 3) {
        if (!reverse) { // Set left wheel for forward direction
            analogWrite(leftMotorM1, pwmLeftWheel); // Apply PWM to left motor for forward motion
            analogWrite(leftMotorM2, 0);            // Set left motor reverse pin to 0 (off)
        } else { // Set left wheel for reverse direction
            analogWrite(leftMotorM1, 0);            // Set left motor forward pin to 0 (off)
            analogWrite(leftMotorM2, pwmLeftWheel); // Apply PWM to left motor for reverse motion
        }
    }
}


//******************************************************************************************************************
// Function that configures the H-Bridge for turning based on the specified direction and update mode.
//
// This function sets PWM values for each wheel's motor pins to achieve a clockwise or counterclockwise turn.
//
// @param counterClockwise Boolean indicating if the turn is counterclockwise (true) or clockwise (false).
// @param update Mode to update specific wheels: 1 for right, 2 for left, 3 for both.
// @param pwmRightWheel PWM value for the right wheel.
// @param pwmLeftWheel PWM value for the left wheel.
//******************************************************************************************************************
void configureHBridgeTurn(bool counterClockwise, int update, int pwmRightWheel, int pwmLeftWheel){

    // Check if right wheel should be updated (update == 1 or update == 3)
    if (update == 1 || update == 3) {
        if (!counterClockwise) { // Set right wheel for clockwise turn
            analogWrite(rightMotorM1, 0);  // Right motor pin M1 set to 0
            analogWrite(rightMotorM2, pwmRightWheel); // Right motor pin M2 set to PWM value
        } else { // Set right wheel for counterclockwise turn
            analogWrite(rightMotorM1, pwmRightWheel); // Right motor pin M1 set to PWM value
            analogWrite(rightMotorM2, 0);  // Right motor pin M2 set to 0
        }
    }

    // Check if left wheel should be updated (update == 2 or update == 3)
    if (update == 2 || update == 3) {
        if (!counterClockwise) { // Set left wheel for clockwise turn
            analogWrite(leftMotorM1, pwmLeftWheel); // Left motor pin M1 set to PWM value
            analogWrite(leftMotorM2, 0);  // Left motor pin M2 set to 0
        } else { // Set left wheel for counterclockwise turn
            analogWrite(leftMotorM1, 0);  // Left motor pin M1 set to 0
            analogWrite(leftMotorM2, pwmLeftWheel); // Left motor pin M2 set to PWM value
        }
    }
}

//******************************************************************************************************************
// Function that calculates the average linear distance traveled by the robot based on encoder pulses.
//
// This function converts the pulse count from both wheels to a linear distance, then averages both distances.
//
// @param leftPulseCount Pulse count for the left wheel encoder.
// @param rightPulseCount Pulse count for the right wheel encoder.
//
// @return The average distance traveled in mm.
//******************************************************************************************************************
float calculateLinearDistanceTraveled(long leftPulseCount, long rightPulseCount) {

  // Wheel circumference in mm
  float wheelCircumference = 2 * PI * wheelRadius;

  // Full revolutions based on the number of pulses
  float rightRevolutions = (float) rightPulseCount / pulsesPerRev;
  float leftRevolutions = (float) leftPulseCount / pulsesPerRev;

  // Distance traveled in mm
  float rightDistance = rightRevolutions * wheelCircumference;
  float leftDistance = rightRevolutions * wheelCircumference;

  // Calculate the average linear distance
  float linearDistance = (rightDistance + leftDistance) / 2.0;

  return linearDistance;
}


//******************************************************************************************************************
// Function that calculates the linear distance required for the robot to achieve a desired turning angle.
//
// This function computes the distance based on the angle input, assuming a circular path defined by the distance 
// between the wheels.
//
// @param desiredAngle The angle in degrees that the robot needs to turn.
//
// @return The calculated linear distance in mm required to achieve the desired turn.
//******************************************************************************************************************
float calculateLinearDistanceDesired(int desiredAngle) {

  // Calculate the linear distance based on the desired angle, assuming a circular path
  // Formula: (desiredAngle / 360) * π * distanceWheelToWheel
  float linearDesiredDistance = (desiredAngle / 360.0) * PI * distanceWheelToWheel;

  // Return the calculated linear distance
  return linearDesiredDistance;
}




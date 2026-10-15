#include <ESP32Servo.h> //3.0.2
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <string>
#include "esp32-hal-periman.h" // perimanGetPinBus: temporizador LEDC de cada pin
#include "driver/ledc.h"
#include <Preferences.h> // Librería de almacenamiento de preferencias/credenciales para ESP32

// LED WS2812B interno (IO02) con el driver RMT del core; FastLED ocupaba ~107 KB de flash.
#define LED_PIN     2   // IO02, connected to DIN


using namespace std;

// Solo escribe cuando cambia el color: la función de estado corre en cada loop().
void ledInterno(uint8_t r, uint8_t g, uint8_t b) {
  static int32_t anterior = -1;
  const int32_t color = (int32_t(r) << 16) | (int32_t(g) << 8) | b;
  if (color == anterior) return;
  anterior = color;
  rgbLedWriteOrdered(LED_PIN, LED_COLOR_ORDER_GRB, r, g, b);
}

// Robot constants

#include "RobotConfig.h"

// Constants for RGB LED configuration
const int duracionParpadeoLed = 500;
const int duracionIndicadorRecibeProgra = 100;//2000;

// Constants for Bluetooth connection
const int esperaBT = 500;
unsigned long tiempoPasadaLecturaBT = 0;

// Constante para determinar cuánto tiempo esperar a la hora de desactivar/activar el lápiz
const int esperaMovimientoServo = 100;

// Constante para evasión de obstáculos
const int distRetrocesoObstaculo = 50;

// Constante para tener siempre activos (o no) los sensores inferiores (trackers)
const bool trackersSiempreActivos = false;

// Cambio del delay
// Keeping it explicit makes it safe to tune from measurements without blocking the loop.
const unsigned long stopSettlingTime = 500;
unsigned long stopStartTime = 0;
bool waitingForStopSettle = false;

// Contadores acumulativos x4; snapshot coherente compartido con las ISR.
portMUX_TYPE encoderMux = portMUX_INITIALIZER_UNLOCKED;
volatile uint32_t rightEncoderPos = 0, leftEncoderPos = 0;

// Variables to store the servo position (loaded from Preferences at startup)
int set = 0;

//Variables del servomotor 360 del set de herramientas
const int pinServo360 = 23;

// Create a Servo object to control the MG90S
Servo myServo;
Servo servoHerramientaSet;


// Define pin for the servo signal
const int servoPin = 26;

// Define the encoder pins
const int rightEncoderA = 27; // Pin for the right encoder's channel A
const int rightEncoderB = 33; // Pin for the right encoder's channel B

const int leftEncoderA = 32; // Pin for the left encoder's channel A
const int leftEncoderB = 35; // Pin for the left encoder's channel B

// Motor control pins
const int rightMotorM1 = 14;   // Direction control pin 1 for the right motor
const int rightMotorM2 = 12;   // Direction control pin 2 for the right motor


const int leftMotorM1 = 13;   // Direction control pin 1 for the left motor
const int leftMotorM2 = 15;   // Direction control pin 1 for the left motor

// Obstacle sensors setup
const int rightInfraredSensor = 4; // Pin for the right infrared obstacle sensor
const int leftInfraredSensor = 25;  // Pin for the left infrared obstacle sensor

// Tracker sensors setup
const int rightTrackerSensor = 34;  // Pin for the right tracker sensor
const int leftTrackerSensor = 39;   // Pin for the left tracker sensor

// LED RGB setup
const int pinLedRgbRojo = 5; 
const int pinLedRgbVerde = 18; 
const int pinLedRgbAzul = 19;
const int pinBateriaBaja = 21;

unsigned long tiempoDeEncendidoDeLed = 0; // Variable para llevar los tiempos de parpadeo/cambio en led RGB

int currentStep = 0; // Variable to keep track of the current step
unsigned long stepStartTime = 0; // Variable to track the start time of each step


//variables máquina de estados
enum posibles_Estados {ESPERA=0, LEE_MEMORIA, MOVERSE, GIRAR, DETENERSE, CICLO, OBSTACULOS, MOVIMIENTO_OBSTACULO, HERRAMIENTA, HERRAMIENTA_SET, IF, WHILE, NADA};
posibles_Estados estado = ESPERA;
bool giro_listo = false;
bool movimiento_listo = true; 
bool obstaculos_activo = false;
bool primer_ciclo = true;
bool retroceso_listo = false;
bool obstaculo_detectado=false;
bool paro_emergencia=false;



//variables para comunicación Bluetooth
string mensajeBLE="ATINIAV020GD030CI003RE010GI090CIFINATFIN";  

//***************************************************************************************
// Global variables and callback classes for native ESP32 BLE (BLEDevice library)
//***************************************************************************************

BLEServer *pServer = NULL;               // Represents this ESP32 acting as a BLE server
BLECharacteristic *pCharacteristic = NULL; // Pointer to the read/write characteristic 

volatile bool deviceConnected = false;   // true while a central (the App) is connected
volatile bool nuevoMensajeBLE = false;   // true when a new write has arrived and hasn't been processed yet
char mensajeBLEBuffer[501] = {};
portMUX_TYPE bleMux = portMUX_INITIALIZER_UNLOCKED;
volatile bool bleStopPending = false;

//***************************************************************************************
// Callback class for connection/disconnection events.
// onConnect/onDisconnect are called automatically by the BLE stack 
//***************************************************************************************
class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    }

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      // IMPORTANT: native ESP32 BLE does NOT restart advertising automatically
      // after a disconnect. Without this, the device becomes invisible to new
      // connections after the first disconnect. We'll call this here so a phone
      // can always find and reconnect to the robot.
      pServer->getAdvertising()->start();
    }
};

//***************************************************************************************
// Callback class for write events on the characteristic.
// onWrite is called automatically the moment the App writes a new value 
//***************************************************************************************
class MyCharacteristicCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      String valorRecibido = pCharacteristic->getValue();
      if (valorRecibido.length() == 0 || valorRecibido.length() > 500) return;
      // STOP tiene prioridad y no puede perderse por otro mensaje posterior.
      bool stopRequested = false;
      for (unsigned int i = 0; i + 5 <= valorRecibido.length(); i += 5)
        if (valorRecibido.substring(i, i + 5) == "PARAR") stopRequested = true;
      portENTER_CRITICAL(&bleMux);
      if (stopRequested) bleStopPending = true;
      else {
        memcpy(mensajeBLEBuffer, valorRecibido.c_str(), valorRecibido.length() + 1);
        nuevoMensajeBLE = true;
      }
      portEXIT_CRITICAL(&bleMux);
    }
};

//apuntadores y variables para la lista de instrucciones
enum posibles_Instrucciones {inst_Avanzar=1, inst_Retroceder, inst_GiroIzquierdo, inst_GiroDerecho, 
inst_CicloInicia, inst_CicloFin, inst_ObstaculoInicia, inst_ObstaculoFin, inst_HerramientaInicia, inst_HerramientaFin, inst_FinalMsg,
inst_HerramientaSet, inst_IfInicia,inst_Else, inst_IfFinal, inst_WhileInicia, inst_WhileFinal};
short lista_instrucciones[100][2];
short inst_final = 0;
short inst_actual = 0;
short instruccion = 0;
short valor_instruccion = 0;
short inst_inicio_ciclo = 0;
short cantidad_ciclos = 0;

//Variables para las flags para los estados del LED RGB
bool flagBluetooth = 0;
bool flagEjecucion = 0;
bool flagObstaculo = 0;
bool flagParar = 0;
bool recibeProgra = 0;
bool flancoNegRecibeProgra = 0;
unsigned long recibePrograTiempo0 = 0;

//Variables de control del flujo de bifurcaciones
// banderas de control de bifurcaciones
bool ignorarHastaIFFIN = false;
bool ignorarHastaElse = false;
bool ignorarHastaWHILEFIN = false;
// registros de anidacion WHILE
short indicesWhile[5] = {};
short anidamientoWhile = 0;
short anidamientoWhileIgnorar=0;
// registros de anidacion IF
short anidamientoIF=0;
short anidamientoIFIgnorar=0;

// Funciones de control de flujo 
bool ejecutandoRamaIf[5] = {};
const short sensorIzquierdoSobreNegro = 0;
const short sensorIzquierdoSobreBlanco = 10;

const short sensorDerechoSobreNegro = 0;
const short sensorDerechoSobreBlanco = 1;

const short sensorNoImporta = 999; // Else sin condicion
// traker son los del suelo
const short mientras = 0;
const short mientrasNo = 100; 

// saqué los bool de lectura a globales

  bool lecturaInfrarrojoDerecho;
  bool lecturaInfrarrojoIzquierdo;
  bool lecturaSensorTrackerDerecho;
  bool lecturaSensorTrackerIzquierdo;

// Constantes del set de herramientas
const short garraAbrir = 101; 
const short garraCerrar = 1;
const short gruaSubir = 102;
const short gruaBajar = 2;

const short posicionHerramientaPositiva = 1; // Garra abierta, Grua arriba
const short posicionHerramientaNegativa = 2; // Garra cerrada, grua abajo
short posicionHerramienta = 0; // al prender el robot no se conoce la posicion de la herramienta. La primera ejecución se confía en el usuario, para la segunda ejecución ya se conoce la posicion

const short tiempoGarra = 700;//###;
const short tiempoGrua = 4000;//###;

short tiempoDeAccion=0;
short velocidad=velocidadNeutra; 

// Frecuencia real del temporizador LEDC de un pin. ledcReadFreq() del core 3.x
// devuelve 0 mientras el duty sea 0 (siempre al arrancar), así que no sirve
// para verificar la configuración de los motores.
uint32_t ledcTimerHz(uint8_t pin) {
  auto* bus = (ledc_channel_handle_t*)perimanGetPinBus(pin, ESP32_BUS_TYPE_LEDC);
  if (!bus) return 0;
  return ledc_get_freq((ledc_mode_t)(bus->channel / SOC_LEDC_CHANNEL_NUM), (ledc_timer_t)bus->timer_num);
}

#include "MotionRuntime.h"

void ARDUINO_ISR_ATTR rightUpdateEncoder() {
  portENTER_CRITICAL_ISR(&encoderMux);
  ++rightEncoderPos;
  portEXIT_CRITICAL_ISR(&encoderMux);
}
void ARDUINO_ISR_ATTR leftUpdateEncoder() {
  portENTER_CRITICAL_ISR(&encoderMux);
  ++leftEncoderPos;
  portEXIT_CRITICAL_ISR(&encoderMux);
}

void setup() {
  Serial.setTxBufferSize(1024);
  Serial.begin(115200);
  loadConfig(); // Lee (o inicializa una vez) la configuracion persistente.

  Serial.print("Loaded device name: [");
  Serial.print(deviceName);
  Serial.println("]");
  Serial.println("Serial listo. Para configurar: DEV <clave>");

  ledInterno(0, 0, 0);

  // Set the PWM properties (50 Hz is typical for servos)
  myServo.setPeriodHertz(50);    // Standard 50Hz servo
  myServo.attach(servoPin, 500, 2400);  // Attach the servo on the pin with min/max pulse widths
  myServo.write(neutralAngle);   // Lleva el lápiz a neutral al encender el Atta

  // Set encoder pins as inputs
  pinMode(rightEncoderA, INPUT_PULLUP);
  pinMode(rightEncoderB, INPUT_PULLUP);

  pinMode(leftEncoderA, INPUT_PULLUP);
  pinMode(leftEncoderB, INPUT); // GPIO35 no tiene pull-up interno; verificar circuito externo.

  pinMode(rightMotorM1, OUTPUT);
  pinMode(rightMotorM2, OUTPUT);

  pinMode(leftMotorM1, OUTPUT);
  pinMode(leftMotorM2, OUTPUT);

  //Obstacle sensors set up
  pinMode(rightInfraredSensor, INPUT);
  pinMode(leftInfraredSensor, INPUT);

  // Tracker sensors set up
  // GPIO 34 y 39 son solo de entrada y no tienen pulldown interno.
  pinMode(rightTrackerSensor, INPUT);
  pinMode(leftTrackerSensor, INPUT);

  // LED RGB set up
  pinMode(pinLedRgbRojo, OUTPUT);
  pinMode(pinLedRgbAzul, OUTPUT);
  pinMode(pinLedRgbVerde, OUTPUT);

  // Setup servo360
  pinMode(pinServo360, OUTPUT);
  servoHerramientaSet.setPeriodHertz(50);
  servoHerramientaSet.attach(pinServo360);
  servoHerramientaSet.write(velocidadNeutra);

  // Reservar ambos servos ANTES de que LEDC asigne canales para motores/LED.
  // Frecuencia configurable (SET pwmhz, por defecto 20 kHz); resolución fija de 8 bits.
  motorOutputsReady = myServo.attached() && servoHerramientaSet.attached();
  motorOutputsReady = attachMotorPWM() && motorOutputsReady;
  stopMotion();
  Serial.printf("PWM motores: %lu Hz, %d bits\n", (unsigned long)motorPwmActiveHz, motorPwmBits);
  if (!motorOutputsReady) Serial.println("ERROR PWM: canales o frecuencia no aplicados; movimiento bloqueado.");

  // Señal de batería baja set up
  pinMode(pinBateriaBaja, INPUT_PULLUP);

  // Attach interrupts to encoder pins
  attachInterrupt(digitalPinToInterrupt(rightEncoderA), rightUpdateEncoder, CHANGE);
  attachInterrupt(digitalPinToInterrupt(rightEncoderB), rightUpdateEncoder, CHANGE);

  attachInterrupt(digitalPinToInterrupt(leftEncoderA), leftUpdateEncoder, CHANGE);
  attachInterrupt(digitalPinToInterrupt(leftEncoderB), leftUpdateEncoder, CHANGE);

    //Inicialización comunicación bluetooth BLE

  //***************************************************************************************
  // Inicialización nativa de BLE para ESP32 
  //***************************************************************************************

  // Establece el nombre que se anuncia del dispositivo 
  //BLEDevice::init(deviceName.c_str()); // Use the device name loaded from preferences
  BLEDevice::init(deviceName);
  // Crea el objeto servidor y registra los callbacks de conexión/desconexión
  // para que deviceConnected se actualice automáticamente
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks()); // Callback es cuando un dispositivo se conecta al server

  // Crea el servicio usando el UUID. Este número es un acuerdo entre la APP y el robot. Se puede cambiar a otro UUID, pero se debe cambiar también en la APP.
  BLEService *pService = pServer->createService("4fafc201-1fb5-459e-8fcc-c5c9c331914b");

  // Crea el característico usando el UUID y permisos de
  // Lectura/Escritura 
  pCharacteristic = pService->createCharacteristic(
                      "beb5483e-36e1-4688-b7f5-ea07361b26a8", //Este número es un acuerdo entre la APP y el robot. Se puede cambiar a otro UUID, pero se debe cambiar también en la APP.
                      BLECharacteristic::PROPERTY_READ |
                      BLECharacteristic::PROPERTY_WRITE
                    );

  // Registra el callback onWrite  para que nuevoMensajeBLE se active
  // automáticamente 
  pCharacteristic->setCallbacks(new MyCharacteristicCallbacks());

  // Inicia el servicio — debe ocurrir después de crear todos los característicos
  pService->start();

  // Hace que el servicio sea detectable, y luego inicia el anuncio (advertising)
  pServer->getAdvertising()->addServiceUUID("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  pServer->getAdvertising()->start(); 

  tiempoDeEncendidoDeLed = millis();
}



void loop() {
  readDeveloperSerial();
  // Procesar STOP también durante reposo de parada y retroceso por obstáculo.
  if (bleStopPending || nuevoMensajeBLE || millis() - tiempoPasadaLecturaBT >= 50) {
    leerBluetooth();
    tiempoPasadaLecturaBT = millis();
  }
  updateMotorTest();
  

  lecturaInfrarrojoDerecho=digitalRead(rightInfraredSensor);
  lecturaInfrarrojoIzquierdo=digitalRead(leftInfraredSensor);
  lecturaSensorTrackerDerecho=digitalRead(rightTrackerSensor);
  lecturaSensorTrackerIzquierdo=digitalRead(leftTrackerSensor);
  int flagBateriaBaja = digitalRead(pinBateriaBaja);


  //Máquina de estados principal
  switch (estado) {

    case ESPERA:  { 
      // Leer la conexión BLE periódicamente
      if (millis() >= tiempoPasadaLecturaBT + esperaBT) {
        leerBluetooth();
        tiempoPasadaLecturaBT = millis();
      }

      //Lógica de estado siguiente
      if (flancoNegRecibeProgra) {
          flagEjecucion = 1;
          estado = LEE_MEMORIA;
          inst_actual = 0;
          resetProgramFlow(); // cada programa arranca sin detección ni ciclos heredados
      } else if (paro_emergencia) { // si se recibe un comando de detener mientras está en ESPERA, se ignora
        flagParar = 0; 
        paro_emergencia = 0;
      }
      break;
    }

    case LEE_MEMORIA:  { 
      if ( inst_actual != inst_final ){ // avanza en memoria de instrucciones
        instruccion = lista_instrucciones[inst_actual][0];
        valor_instruccion = lista_instrucciones[inst_actual][1];
        inst_actual++;         

      } 
      
      //Lógica de estado siguiente
      if (inst_actual == inst_final) { 
        estado = ESPERA;
        inst_actual = 0;
        flagEjecucion = 0;

      } else if (ignorarHastaIFFIN || ignorarHastaElse || ignorarHastaWHILEFIN){ //se leen e ignoran segmentos de instrucciones hasta marcas de ramas
        //if
          if ((ignorarHastaIFFIN || ignorarHastaElse) && (instruccion == inst_IfInicia)){
            anidamientoIFIgnorar++; // debe ignorar un "fin" extra

          } else if ((ignorarHastaIFFIN || ignorarHastaElse) && (instruccion == inst_IfFinal)){            
            if (anidamientoIFIgnorar == anidamientoIF){ // se llegó al fin de una rama
              ignorarHastaIFFIN = false;
              ignorarHastaElse = false;
              estado = IF;
              } else {
                anidamientoIFIgnorar--;
              }

          } else if (ignorarHastaElse && (instruccion == inst_Else)){
            ignorarHastaElse = false; // se llegó al inicio de una nueva rama
            estado = IF;

          } else if (ignorarHastaWHILEFIN){ // Whiles
            if (instruccion == inst_WhileInicia){
              anidamientoWhileIgnorar++; // se debe ignorar un fin extra

            } else if (instruccion == inst_WhileFinal){
              if(anidamientoWhileIgnorar == anidamientoWhile){
                ignorarHastaWHILEFIN = false; //se llegó al fin del ciclo
              } else {
                anidamientoWhileIgnorar--;
              }
            }
          }  // estado se mantiene igual, se salta el resto de comparaciones y lee nueva instruccion   
      
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

      } else if (instruccion == inst_HerramientaSet) {
        estado = HERRAMIENTA_SET;

      } else if (instruccion == inst_IfInicia || instruccion == inst_Else || instruccion == inst_IfFinal){
        estado = IF;

      } else if (instruccion == inst_WhileInicia || instruccion == inst_WhileFinal){
        estado = WHILE;
      }

      break; 
    }
    
    case MOVERSE: {

      //Ejecuta el estado de avanzar o retroceder
      //(es el mismo pero con distancia negativa)
      movimiento_listo= advanceDesiredDistance(diagnosticMove ? diagnosticAmount : valor_instruccion*10);

      // Leer la conexión BLE periódicamente
      if (millis() >= tiempoPasadaLecturaBT + esperaBT) {
        leerBluetooth();
        tiempoPasadaLecturaBT = millis();
      }

      //Lógica estado siguiente
      if (paro_emergencia) { 
        estado = DETENERSE;

      } else if ( movimiento_listo ) {
        estado = DETENERSE;
        
      } else if ((trackersSiempreActivos || obstaculos_activo) && (lecturaSensorTrackerDerecho||lecturaSensorTrackerIzquierdo)) {
        obstaculo_detectado=true;
        flagObstaculo = 1;
        estado=DETENERSE;

      } else if (obstaculos_activo) {
        if (!lecturaInfrarrojoDerecho||!lecturaInfrarrojoIzquierdo){
          obstaculo_detectado=true;
          flagObstaculo = 1;
          estado=DETENERSE;
        }
      }
      break;
    }

    case GIRAR: {

      //Ejecuta el estado de girar derecha o izquierda
      //(es el mismo pero con ángulo negativo)

      //giro
      movimiento_listo= turnDesiredAngle(diagnosticMove ? diagnosticAmount : valor_instruccion);

      // Leer la conexión BLE periódicamente
      if (millis() >= tiempoPasadaLecturaBT + esperaBT) {
        leerBluetooth();
        tiempoPasadaLecturaBT = millis();
      }

      //Lógica estado siguiente
      if (paro_emergencia) {
        estado = DETENERSE;

      }else if ( movimiento_listo ) {
        //movimiento_listo = false;
        estado = DETENERSE;

      } else if ((trackersSiempreActivos || obstaculos_activo) && (lecturaSensorTrackerDerecho||lecturaSensorTrackerIzquierdo)) {
        obstaculo_detectado=true;
        flagObstaculo = 1;
        estado=DETENERSE;

      } else if (obstaculos_activo) {
        if (!lecturaInfrarrojoDerecho||!lecturaInfrarrojoIzquierdo){
          obstaculo_detectado=true;
          flagObstaculo = 1;
          estado=DETENERSE;
        }
      }
      
      break;
    }

    case DETENERSE: {
      if (!waitingForStopSettle) {
        if (paro_emergencia || obstaculo_detectado) { //en caso de apretar STOP o detectar obstaculo
          flagEjecucion = 0;
          stopMotion(); // mismo reinicio para STOP y obstáculo
        } // Ojo que la funcion avanzar y girar ya detiene el robot al final

        stopStartTime = millis();
        waitingForStopSettle = true;
        flagParar = 0;
      }

      // Keep the firmware responsive while the chassis settles after stopping.
      const bool turnAlreadySettled = motion.turning && motion.turnSettled &&
        motion.fault == atta::Fault::None && !paro_emergencia && !obstaculo_detectado;
      if (!turnAlreadySettled && millis() - stopStartTime < stopSettlingTime) {
        break;
      }

      waitingForStopSettle = false;

      //Lógica estado siguiente
      if (paro_emergencia){
        paro_emergencia=false;
        estado = ESPERA;
      } else if (obstaculo_detectado){
        // El controlador toma nuevos orígenes al iniciar el retroceso.
        estado = MOVIMIENTO_OBSTACULO;
      } else if (diagnosticMove) {
        diagnosticMove = false;
        flagEjecucion = false;
        estado = ESPERA;
        Serial.println("MOVE_DONE");
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
      estado = LEE_MEMORIA;
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
      estado = LEE_MEMORIA;
      break;
    }

    case MOVIMIENTO_OBSTACULO: {
      // *Genera el movimiento despues que un obstaculo se detectó, el cual corresponde a un retroceso
      retroceso_listo=advanceDesiredDistance(-1* distRetrocesoObstaculo);
      obstaculo_detectado=false;
      flagObstaculo = 0;
      
      // Lógica estado siguiente
      if (paro_emergencia) {
        estado = DETENERSE;
      } else if (retroceso_listo) {
        diagnosticMove = false;
        flagEjecucion = false;
        resetProgramFlow(); // el programa termina aquí: no se llega a OBFIN/CIFIN
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

      delay(esperaMovimientoServo); // para que el servo tenga tiempo de moverse antes de que el robot avance a la siguiente instrucción

      //Lógica estado siguiente
      estado = LEE_MEMORIA;
      break;
    }

    case NADA: {
      break;
    }

    case IF: {
      verSernsores();
      bifurcacionIF();
      estado = LEE_MEMORIA;
      break;
    }

    case WHILE: {
      // Leer la conexión BLE periódicamente por si se requiere salir de un loop infinito
      if (millis() >= tiempoPasadaLecturaBT + esperaBT) {
        leerBluetooth();
        tiempoPasadaLecturaBT = millis();
      }

      verSernsores();
      bifurcacionWHILE();
      estado = LEE_MEMORIA;
      break;
    }

    case HERRAMIENTA_SET: {
      accionarHerramientaSet();
      estado = LEE_MEMORIA;
      break;
    }


  }

  emitTelemetry();
  flancoNegRecibeProgra = 0;
  // Reseteo de la señal de recibeProgra
  if (recibeProgra && millis() > recibePrograTiempo0 + duracionIndicadorRecibeProgra) {
    recibePrograTiempo0 = millis();
    recibeProgra = 0;
    flancoNegRecibeProgra = 1;
  }

  // Se asigna el color del LED RGB
  ConfigurarEstadoLedRgb(flagBateriaBaja, flagBluetooth, flagEjecucion, flagObstaculo, recibeProgra, flagParar);

}

//*****************************************************************
// Procedimiento para observar las lecturas de los sensores inferiores
//******************************************************************************************************************

void verSernsores(){
  Serial.println("****************************");
  Serial.println(lecturaSensorTrackerIzquierdo);
  Serial.println(lecturaSensorTrackerDerecho);
}



//******************************************************************************************************************
// Procedimiento que realiza la comparación de las lectura de los sensores para determinar si se salta o ejecuta la rama IF
//
// @param {bool} condicionSensorIzquierdo - Booleano que indica si se busca que la lectura del sensor sea alta o baja
// @param {bool} condicionSensorDerecho - Booleano que indica si se busca que la lectura del sensor sea alta o baja
//******************************************************************************************************************

void validacionIf(bool condicionSensorIzquierdo, bool condicionSensorDerecho){
if (condicionSensorIzquierdo && condicionSensorDerecho){
    ejecutandoRamaIf[anidamientoIF] = true;    
  } else {
    ignorarHastaElse = true;
    anidamientoIFIgnorar = anidamientoIF;
  }
};

//******************************************************************************************************************
// Procedimiento de asignación de las condiciones de los sensores para los condicionales IF
// 
//******************************************************************************************************************

void condicionesIF(){
  // inicios de ramas segun condicionales
  switch (valor_instruccion) {
    case (sensorIzquierdoSobreNegro + sensorDerechoSobreNegro): {
      validacionIf (lecturaSensorTrackerIzquierdo, lecturaSensorTrackerDerecho );
      break;
    }

    case (sensorIzquierdoSobreNegro + sensorDerechoSobreBlanco): {
      validacionIf (lecturaSensorTrackerIzquierdo, !lecturaSensorTrackerDerecho );
      break;
    }

    case (sensorIzquierdoSobreBlanco + sensorDerechoSobreNegro): {
      validacionIf (!lecturaSensorTrackerIzquierdo, lecturaSensorTrackerDerecho );
      break;
    }      

    case (sensorIzquierdoSobreBlanco + sensorDerechoSobreBlanco): {
      validacionIf (!lecturaSensorTrackerIzquierdo, !lecturaSensorTrackerDerecho );
      break;
    }

    case (sensorNoImporta): {
      validacionIf(true, true);
      break;
    }
    
  }

}

//******************************************************************************************************************
// Procedimiento de ejecución de la lógica del flujo de las bifurcaciones IF
// 
//******************************************************************************************************************

void bifurcacionIF(){

  switch (instruccion){
    case (inst_IfInicia) : {
      anidamientoIF++;  
      condicionesIF();        
      break;
    }
    case (inst_Else) : {
        if (ejecutandoRamaIf[anidamientoIF]){
          ignorarHastaIFFIN = true;
          anidamientoIFIgnorar = anidamientoIF;
        } else {
          condicionesIF();
        }
      break;
    }
    case (inst_IfFinal) : {      
      ejecutandoRamaIf[anidamientoIF] = false;
      anidamientoIF--;
      break;
    }

  
  }

};



//******************************************************************************************************************
// Procedimiento que realiza la comparación de las lectura de los sensores para determinar si se salta o ejecuta la rama While
//
// @param {bool} condicionSensorIzquierdo - Booleano que indica si se busca que la lectura del sensor sea alta o baja
// @param {bool} condicionSensorDerecho - Booleano que indica si se busca que la lectura del sensor sea alta o baja
//******************************************************************************************************************


void validacionWhile(bool condicionSensorIzquierdo, bool condicionSensorDerecho){
  if (condicionSensorIzquierdo && condicionSensorDerecho){
    indicesWhile[anidamientoWhile]=inst_actual-1;
    anidamientoWhile++;
  } else {
    ignorarHastaWHILEFIN = true;
    anidamientoWhileIgnorar = anidamientoWhile;
  }
};

//******************************************************************************************************************
// Procedimiento que realiza la comparación de las lectura de los sensores para determinar si se salta o ejecuta la rama WhileNot
//
// @param {bool} condicionSensorIzquierdo - Booleano que indica si se busca que la lectura del sensor sea alta o baja
// @param {bool} condicionSensorDerecho - Booleano que indica si se busca que la lectura del sensor sea alta o baja
//******************************************************************************************************************

void validacionNotWhile(bool condicionSensorIzquierdo, bool condicionSensorDerecho){
  if (!(condicionSensorIzquierdo && condicionSensorDerecho)){
    indicesWhile[anidamientoWhile]=inst_actual-1;
    anidamientoWhile++;
  } else {
    ignorarHastaWHILEFIN = true;
    anidamientoWhileIgnorar = anidamientoWhile;
  }
};

//******************************************************************************************************************
// Procedimiento de ejecución de la lógica de las banderas de flujo de bifurcaciones While y WhileNot
// 
//******************************************************************************************************************

void bifurcacionWHILE(){
  if (instruccion == inst_WhileFinal){
    anidamientoWhile--;
    inst_actual = indicesWhile[anidamientoWhile];
    

  }else {

    switch (valor_instruccion){
      case (mientras + sensorIzquierdoSobreNegro + sensorDerechoSobreNegro): {
        validacionWhile(lecturaSensorTrackerIzquierdo,lecturaSensorTrackerDerecho);
        break;
      }

      case (mientras + sensorIzquierdoSobreNegro + sensorDerechoSobreBlanco): {
        validacionWhile(lecturaSensorTrackerIzquierdo,!lecturaSensorTrackerDerecho);
        break;
      }

      case (mientras + sensorIzquierdoSobreBlanco + sensorDerechoSobreNegro): {
        validacionWhile(!lecturaSensorTrackerIzquierdo,lecturaSensorTrackerDerecho);
        break;
      }      

      case (mientras + sensorIzquierdoSobreBlanco + sensorDerechoSobreBlanco): {
        validacionWhile(!lecturaSensorTrackerIzquierdo,!lecturaSensorTrackerDerecho);
        break;
      }

      case (mientrasNo + sensorIzquierdoSobreNegro + sensorDerechoSobreNegro): {
        validacionNotWhile(lecturaSensorTrackerIzquierdo,lecturaSensorTrackerDerecho);
        break;
      }

      case (mientrasNo + sensorIzquierdoSobreNegro + sensorDerechoSobreBlanco): {
        validacionNotWhile(lecturaSensorTrackerIzquierdo,!lecturaSensorTrackerDerecho);
        break;
      }

      case (mientrasNo + sensorIzquierdoSobreBlanco + sensorDerechoSobreNegro): {
        validacionNotWhile(!lecturaSensorTrackerIzquierdo,lecturaSensorTrackerDerecho);
        break;
      }      

      case (mientrasNo + sensorIzquierdoSobreBlanco + sensorDerechoSobreBlanco): {
        validacionNotWhile(!lecturaSensorTrackerIzquierdo,!lecturaSensorTrackerDerecho);
        break;
      }    

    }

  }

};


//******************************************************************************************************************
// Procedimiento que mueve la herramienta la velocidad y tiempo indicados por el tipo de acción de la herramienta
// 
//******************************************************************************************************************

void accionarMotorHerramientaSet(){
  servoHerramientaSet.write(velocidad);
  delay(tiempoDeAccion);
  servoHerramientaSet.write(velocidadNeutra);
  delay(100);
};

//******************************************************************************************************************
// Procedimiento que asigna la velocidad y tiempo de ejecución de la herramienta según el valor del comando
// 
//******************************************************************************************************************

void accionarHerramientaSet(){
  tiempoDeAccion=0;
  velocidad=velocidadNeutra;
  switch (valor_instruccion){
    case (garraAbrir) : {
      if (!(posicionHerramienta == posicionHerramientaPositiva)){
        tiempoDeAccion = tiempoGarra;
        velocidad = velocidadPositiva;
        accionarMotorHerramientaSet();
        posicionHerramienta=posicionHerramientaPositiva;
      };
      break;
    };

    case (garraCerrar) : {
      if (!(posicionHerramienta == posicionHerramientaNegativa)){
        tiempoDeAccion = tiempoGarra;
        velocidad = velocidadNegativa;
        accionarMotorHerramientaSet();
        posicionHerramienta=posicionHerramientaNegativa;
      };
      break;
    };

    case (gruaSubir) : {
      if (!(posicionHerramienta == posicionHerramientaPositiva)){
        tiempoDeAccion = tiempoGrua;
        velocidad = velocidadPositiva;
        accionarMotorHerramientaSet();
        posicionHerramienta=posicionHerramientaPositiva;
      };
      break;
    };
    
    case (gruaBajar) : {
      if (!(posicionHerramienta == posicionHerramientaNegativa)){
        tiempoDeAccion = tiempoGrua ;
        velocidad = velocidadNegativa;
        accionarMotorHerramientaSet();
        posicionHerramienta=posicionHerramientaNegativa;
      };
      break;
    };    

  };

};



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

        if (comando=="ATCOI") {
          //inst_actual = 0;
        
        } else if (comando == "ATCOF") {
          //inst_final = i/5;

        } else if (comando == "PARAR") {
          paro_emergencia = true;
          flagParar = 1;

        } else if (comando == "EJECU") {
          inst_actual = 0;
         
        } else if (comando == "ATINI") {
          inst_actual = 0;
        
        } else if (comando == "ATFIN") {
          inst_final = i/5;
        
        } else if (comando == "OBINI") {
          lista_instrucciones[inst_actual][0] = inst_ObstaculoInicia;
          lista_instrucciones[inst_actual][1] = 0;
          inst_actual++;

        } else if (comando == "OBFIN") {
          lista_instrucciones[inst_actual][0] = inst_ObstaculoFin;
          lista_instrucciones[inst_actual][1] = 0;
          inst_actual++;

        } else if (comando == "CIFIN"){
          lista_instrucciones[inst_actual][0] = inst_CicloFin;
          lista_instrucciones[inst_actual][1] = 0;
          inst_actual++;  

        } else if (instruccion == "CI" && comando != "CIFIN") {
          short valor = stoi (valor_instruccion);
          lista_instrucciones[inst_actual][0] = inst_CicloInicia;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;

        } else if (instruccion == "AV") {
          short valor = stoi (valor_instruccion);
          lista_instrucciones[inst_actual][0] = inst_Avanzar;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;

        } else if (instruccion == "RE") {
          short valor = stoi (valor_instruccion);
          lista_instrucciones[inst_actual][0] = inst_Retroceder;
          lista_instrucciones[inst_actual][1]= valor;
          inst_actual++;

        } else if (instruccion == "GI") {
          short valor = stoi (valor_instruccion);
          lista_instrucciones[inst_actual][0] = inst_GiroIzquierdo;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;

        } else if (instruccion == "GD") {
          short valor = stoi (valor_instruccion);
          lista_instrucciones[inst_actual][0] = inst_GiroDerecho;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;
        
        } else if (comando == "HEINI") {
          lista_instrucciones[inst_actual][0] = inst_HerramientaInicia;
          lista_instrucciones[inst_actual][1] = 0;
          inst_actual++;

        } else if (comando == "HEFIN") {
          lista_instrucciones[inst_actual][0] = inst_HerramientaFin;
          lista_instrucciones[inst_actual][1] = 0;
          inst_actual++;

        } else if (comando == "IFFIN"){
          lista_instrucciones[inst_actual][0] = inst_IfFinal;
          lista_instrucciones[inst_actual][1] = 0;
          inst_actual++;

        } else if (instruccion == "IF"){
          short valor = stoi (valor_instruccion);
          lista_instrucciones[inst_actual][0] = inst_IfInicia;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;

        } else if (instruccion == "EL"){
          short valor = stoi (valor_instruccion);
          lista_instrucciones[inst_actual][0] = inst_Else;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;

        } else if (comando == "WHFIN"){
          lista_instrucciones[inst_actual][0] = inst_WhileFinal;
          lista_instrucciones[inst_actual][1] = 0;
          inst_actual++;

        } else if (instruccion == "WH"){
          short valor = stoi (valor_instruccion);
          lista_instrucciones[inst_actual][0] = inst_WhileInicia;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;

        } else if (instruccion == "HE"){
          short valor = stoi (valor_instruccion);
          lista_instrucciones[inst_actual][0] = inst_HerramientaSet;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;
        }
  }
  inst_actual = 0; 
}

//***************************************************************************************
//Función que lee la conexión Bluetooth BLE
//
//Determina si el robot está conectado a alguna App, y en caso de estarlo verifica
//si llegó un mensaje nuevo. En tal caso, llama a la interpretación del nuevo mensaje.
//También determina si se trata de una instrucción para la que se debería parpadear el
//led en azul.
//***************************************************************************************
void leerBluetooth() {
  flagBluetooth = deviceConnected;
  char incoming[501];
  bool pending, stopRequested;
  portENTER_CRITICAL(&bleMux);
  stopRequested = bleStopPending;
  bleStopPending = false;
  pending = nuevoMensajeBLE;
  if (pending) memcpy(incoming, mensajeBLEBuffer, sizeof(incoming));
  nuevoMensajeBLE = false;
  portEXIT_CRITICAL(&bleMux);
  if (stopRequested) { requestMotionStop(); return; }
  if (!deviceConnected || !pending) return;
  mensajeBLE = incoming;
  if (mensajeBLE.size() % 5 != 0) return;
  // No reemplazar un programa ni su geometría durante una maniobra.
  if (!calibrationIdle() || !configReady || motion.fault != atta::Fault::None) return;
  Interpreta_mensajeBLE(mensajeBLE);
  if (paro_emergencia) { requestMotionStop(); return; }
  recibeProgra = 1;
  recibePrograTiempo0 = millis();
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
  delay(500); // so that the next action does not start before the servo stops moving
  return true;  // Action completed
}

//******************************************************************************************************************
//Función que basado en ciertas flags determina el estado del robot y lo muestra en un LED RGB.
//
//Utiliza flags relacionadas a si la bateria está baja, si se detecta un obstáculo, si el bluetooth no se ha conectado al dispositivo,
//si el robot está recibiendo un código, si el robot está ejecutando un código, y si el bluetooth está conectado con un dispositivo.
//El orden en el que se mencionaron los estados es el orden de prioridad.
//
//@param flagBateriaBaja Variable asociada a la señal de batería baja del powerboost, es LOW cuando batería baja.
//@param flagBluetooth Variable que dicta si hay conexión Bluetooth del robot con la App.
//@param flagEjecucion Variable que informa si se está ejecutando una programación.
//@param flagObstaculo Variable asociada a los sensores infrarrojos, informa cuando hay un obstáculo frente al robot
//@param recibeProgra Variable que es un pulso que se recibe cuando se está recibiendo/recibió una progra desde la App
//******************************************************************************************************************
void ConfigurarEstadoLedRgb(int flagBateriaBaja, bool flagBluetooth, bool flagEjecucion, bool flagObstaculo, bool recibeProgra, bool flagParar) {
  unsigned long tiempoActual = millis();

  //Bateria baja -> rojo parpadeante
  if (flagBateriaBaja == LOW) {
    // setear el tiempo de Encendido de LED en el momento de activar la flag
    if (tiempoActual <= tiempoDeEncendidoDeLed + duracionParpadeoLed && tiempoActual > tiempoDeEncendidoDeLed) {
      analogWrite(pinLedRgbRojo, 255);
      analogWrite(pinLedRgbVerde, 0);
      analogWrite(pinLedRgbAzul, 0);
      // Internal WS2812B mirrors external: red on
      ledInterno(255, 0, 0);

    } else if (tiempoActual > tiempoDeEncendidoDeLed + 2*duracionParpadeoLed) {
      //Se reinicia el "ciclo" de parpadeo
      tiempoDeEncendidoDeLed = millis();
      
    } else if (tiempoActual > tiempoDeEncendidoDeLed + duracionParpadeoLed){
      analogWrite(pinLedRgbRojo, 0);
      analogWrite(pinLedRgbVerde, 0);
      analogWrite(pinLedRgbAzul, 0);
      // Internal WS2812B mirrors external: off
      ledInterno(0, 0, 0);
    }
   
  } else if (flagObstaculo == 1 || flagParar == 1) { //Obstaculo o paro de emergencia -> rojo fijo
    analogWrite(pinLedRgbRojo, 255);
    analogWrite(pinLedRgbVerde, 0);
    analogWrite(pinLedRgbAzul, 0);
    // Internal WS2812B mirrors external: red fixed
    ledInterno(255, 0, 0);

  } else if (flagBluetooth == 0) { //Bluetooth no conectado -> azul y verde intercalados
    // setear el tiempo de Encendido de LED en el momento de activar la flag
    if (tiempoActual <= tiempoDeEncendidoDeLed + duracionParpadeoLed && tiempoActual > tiempoDeEncendidoDeLed) {
      analogWrite(pinLedRgbRojo, 0);
      analogWrite(pinLedRgbVerde, 255);
      analogWrite(pinLedRgbAzul, 0);
      // Internal WS2812B mirrors external: green
      ledInterno(0, 255, 0);

    } else if (tiempoActual > tiempoDeEncendidoDeLed + 2*duracionParpadeoLed) {
      //Se reinicia el "ciclo" de parpadeo
      tiempoDeEncendidoDeLed = millis();
      
    } else if (tiempoActual > tiempoDeEncendidoDeLed + duracionParpadeoLed){
      analogWrite(pinLedRgbRojo, 0);
      analogWrite(pinLedRgbVerde, 0);
      analogWrite(pinLedRgbAzul, 255);
      // Internal WS2812B mirrors external: blue
      ledInterno(0, 0, 255);
    } 

  } else if (recibeProgra == 1) { //Recibe progra de la App -> azul parpadeante
    // setear el tiempo de Encendido de LED en el momento de activar la flag
    if (tiempoActual <= tiempoDeEncendidoDeLed + duracionParpadeoLed && tiempoActual > tiempoDeEncendidoDeLed) {
      analogWrite(pinLedRgbRojo, 0);
      analogWrite(pinLedRgbVerde, 0);
      analogWrite(pinLedRgbAzul, 255);
      // Internal WS2812B mirrors external: blue
      ledInterno(0, 0, 255);

    } else if (tiempoActual > tiempoDeEncendidoDeLed + 2*duracionParpadeoLed) {
      //Se reinicia el "ciclo" de parpadeo
      tiempoDeEncendidoDeLed = millis();
      
    } else if (tiempoActual > tiempoDeEncendidoDeLed + duracionParpadeoLed){
      analogWrite(pinLedRgbRojo, 0);
      analogWrite(pinLedRgbVerde, 0);
      analogWrite(pinLedRgbAzul, 0);
      // Internal WS2812B mirrors external: off
      ledInterno(0, 0, 0);
    }

  } else if (flagEjecucion == 1) { //Robot ejecutando progra -> verde fijo
    analogWrite(pinLedRgbRojo, 0);
    analogWrite(pinLedRgbVerde, 255);
    analogWrite(pinLedRgbAzul, 0);
    // Internal WS2812B mirrors external: green fixed
    ledInterno(0, 255, 0);
    
  } else if (flagBluetooth == 1) { //Bluetooth conectado -> azul fijo
    analogWrite(pinLedRgbRojo, 0);
    analogWrite(pinLedRgbVerde, 0);
    analogWrite(pinLedRgbAzul, 255);
    // Internal WS2812B mirrors external: blue fixed
    ledInterno(0, 0, 255);
  }
}

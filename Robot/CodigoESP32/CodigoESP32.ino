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

//***************************************************************************************
// Pinta el LED WS2812B interno (IO02) solo cuando el color cambia.
//
// La función de estado del LED corre en cada vuelta de loop(); comparar contra el último
// color evita reescribir el bus RMT si nada cambió. El "último color" vive en una variable
// estática local, así que persiste entre llamadas.
//
// @param r Componente roja, 0..255.
// @param g Componente verde, 0..255.
// @param b Componente azul, 0..255.
//***************************************************************************************
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
// Variables globales y clases de callback para el BLE nativo del ESP32 (librería BLEDevice)
//***************************************************************************************

BLEServer *pServer = NULL;               // Representa a este ESP32 actuando como servidor BLE
BLECharacteristic *pCharacteristic = NULL; // Puntero a la característica de lectura/escritura 

volatile bool deviceConnected = false;   // true mientras un central (la App) está conectado
volatile bool nuevoMensajeBLE = false;   // true cuando llegó una escritura nueva aún no procesada
char mensajeBLEBuffer[501] = {};
portMUX_TYPE bleMux = portMUX_INITIALIZER_UNLOCKED;
volatile bool bleStopPending = false;

//***************************************************************************************
// Clase de callbacks para los eventos de conexión y desconexión.
// onConnect/onDisconnect los llama automáticamente la pila BLE
//***************************************************************************************
class MyServerCallbacks: public BLEServerCallbacks {
    //***********************************************************************************
    // Marca que hay un dispositivo central conectado.
    //
    // Solo actualiza la bandera global deviceConnected, que loop() usa para el LED y
    // leerBluetooth() para decidir si procesa mensajes.
    //
    // @param pServer Servidor BLE que emite el evento (no se usa).
    //***********************************************************************************
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    }

    //***********************************************************************************
    // Marca que ya no hay dispositivo conectado y vuelve a anunciar el robot.
    //
    // El BLE nativo del ESP32 no reanuda el advertising solo tras una desconexión; sin
    // reiniciarlo el robot dejaría de ser visible para nuevas conexiones. Por eso apaga
    // deviceConnected y llama a start() del advertising del mismo servidor.
    //
    // @param pServer Servidor BLE que emite el evento.
    //***********************************************************************************
    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      // IMPORTANTE: el BLE nativo del ESP32 NO reinicia el advertising automáticamente
      // tras una desconexión. Sin esto, el dispositivo queda invisible para nuevas
      // conexiones después de la primera desconexión. Se llama aquí para que un teléfono
      // siempre pueda encontrar y reconectar con el robot.
      pServer->getAdvertising()->start();
    }
};

//***************************************************************************************
// Clase de callbacks para los eventos de escritura de la característica.
// onWrite lo llama automáticamente la pila BLE en el momento en que la App escribe
//***************************************************************************************
class MyCharacteristicCallbacks: public BLECharacteristicCallbacks {
    //***********************************************************************************
    // Recibe el valor escrito por la App y lo deja listo para leerBluetooth().
    //
    // Ignora valores vacíos o de más de 500 caracteres. Recorre el mensaje en grupos de
    // 5 y, si encuentra "PARAR", activa bleStopPending con prioridad sobre cualquier otro
    // mensaje para que la parada no se pierda. Si no hay PARAR, copia el texto a
    // mensajeBLEBuffer y activa nuevoMensajeBLE. Todo el acceso se protege con bleMux
    // porque loop() lo lee desde otra tarea.
    //
    // @param pCharacteristic Característica BLE que recibió la escritura.
    //***********************************************************************************
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
//***************************************************************************************
// Devuelve la frecuencia real del temporizador LEDC asociado a un pin.
//
// ledcReadFreq() del core 3.x devuelve 0 mientras el duty sea 0 (siempre al arrancar), así
// que no sirve para verificar la configuración de los motores. Esta función obtiene el bus
// LEDC del pin con perimanGetPinBus y consulta ledc_get_freq() del canal y temporizador.
//
// @param pin Número de GPIO configurado con ledcAttach.
//
// @return Frecuencia en Hz, o 0 si el pin no tiene un bus LEDC asociado.
//***************************************************************************************
uint32_t ledcTimerHz(uint8_t pin) {
  auto* bus = (ledc_channel_handle_t*)perimanGetPinBus(pin, ESP32_BUS_TYPE_LEDC);
  if (!bus) return 0;
  return ledc_get_freq((ledc_mode_t)(bus->channel / SOC_LEDC_CHANNEL_NUM), (ledc_timer_t)bus->timer_num);
}

#include "MotionRuntime.h"

//***************************************************************************************
// ISR del encoder derecho: suma un pulso por cada flanco de sus canales A y B.
//
// Corre en contexto de interrupción, por eso protege el contador con encoderMux. El
// controlador de movimiento lo lee de forma coherente con readEncoderCounts().
//***************************************************************************************
void ARDUINO_ISR_ATTR rightUpdateEncoder() {
  portENTER_CRITICAL_ISR(&encoderMux);
  ++rightEncoderPos;
  portEXIT_CRITICAL_ISR(&encoderMux);
}
//***************************************************************************************
// ISR del encoder izquierdo: suma un pulso por cada flanco de sus canales A y B.
//
// Igual que el derecho, usa encoderMux para que el contador compartido no se lea a medias.
//***************************************************************************************
void ARDUINO_ISR_ATTR leftUpdateEncoder() {
  portENTER_CRITICAL_ISR(&encoderMux);
  ++leftEncoderPos;
  portEXIT_CRITICAL_ISR(&encoderMux);
}

//***************************************************************************************
// Inicializa el robot: configuración persistente, periféricos, PWM y servidor BLE.
//
// Orden de arranque:
// 1. Abre el puerto Serial y llama a loadConfig(), que lee (o crea una vez) de NVS el
//    nombre del dispositivo, los ángulos de los servos, la frecuencia PWM y los perfiles
//    de movimiento/giro. Si la configuración no es válida, configReady queda en false y
//    el movimiento se bloquea.
// 2. Apaga el LED interno y prepara el servo del lápiz (50 Hz, neutro) y el servo 360
//    del set de herramientas.
// 3. Configura como entrada los pines de encoders, sensores infrarrojos, trackers y
//    batería baja; como salida los de motores y LED RGB externo.
// 4. Reserva los temporizadores de los servos antes de llamar a attachMotorPWM() y deja
//    los motores detenidos con stopMotion(); si el PWM no se aplicó, lo avisa por Serial.
// 5. Engancha las interrupciones de los cuatro canales de encoder.
// 6. Inicia el BLE nativo con el nombre en deviceName, crea el servidor, el servicio y la
//    característica con los UUID acordados con la App, registra los callbacks y empieza a
//    anunciarse para que la tablet pueda conectarse.
// 7. Guarda en tiempoDeEncendidoDeLed el instante inicial del parpadeo del LED.
//***************************************************************************************
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



//***************************************************************************************
// Bucle principal: atiende E/S y ejecuta la máquina de estados del programa de bloques.
//
// En cada vuelta procesa comandos de desarrollador por Serial, revisa si hay mensajes BLE
// nuevos (o cada 50 ms) para no perder un STOP, avanza las pruebas de motor opcionales,
// toma las lecturas de los sensores infrarrojos, trackers y batería baja, y luego recorre
// el switch de estado:
// - ESPERA: aguarda a que termine de llegar un programa (flancoNegRecibeProgra) y pasa a
//   LEE_MEMORIA reiniciando el flujo; un paro recibido aquí se ignora.
// - LEE_MEMORIA: lee la siguiente instrucción de lista_instrucciones y salta al estado que
//   corresponda; si se están ignorando ramas, las salta hasta la marca IF/ELSE/WHILE.
// - MOVERSE y GIRAR: ejecutan la maniobra y pasan a DETENERSE al terminar o si hay paro u
//   obstáculo.
// - DETENERSE: detiene los motores, espera el asentamiento del chasis y vuelve a
//   LEE_MEMORIA, a ESPERA (paro o prueba) o a MOVIMIENTO_OBSTACULO.
// - CICLO, OBSTACULOS, HERRAMIENTA, IF, WHILE y HERRAMIENTA_SET: aplican esa instrucción
//   y vuelven a LEE_MEMORIA.
// - MOVIMIENTO_OBSTACULO: retrocede tras un obstáculo, reinicia el flujo y va a ESPERA.
// - NADA: no hace nada.
// Al salir del switch emite telemetría, limpia el flanco de recepción, apaga el pulso de
// recibeProgra tras su duración y actualiza el color del LED RGB.
//***************************************************************************************
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
      // En reposo: espera que termine de llegar un programa y descarta paros.
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
      // Toma la siguiente instrucción de la lista y decide a qué estado pasar.
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
      // Avanza o retrocede la distancia pedida y vigila paro y obstáculos.
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
      // Gira el ángulo pedido (negativo = izquierda) y vigila paro y obstáculos.
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
      // Detiene los motores, espera el asentamiento y elige el siguiente estado.
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
      // Controla el contador de repeticiones y retrocede el puntero al inicio del ciclo.
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
      // Activa o desactiva la detección de obstáculos según el bloque.
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
      // Retrocede una distancia fija tras detectar un obstáculo y termina el programa.
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
      // Activa o desactiva el servo del lápiz (herramienta básica).
      // HEINI baja el lápiz; HEFIN lo sube.
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
      // Estado inactivo: no ejecuta nada y deja que el switch termine.
      break;
    }

    case IF: {
      // Evalúa la condición del IF/ELSE y actualiza las banderas de salto de rama.
      verSernsores();
      bifurcacionIF();
      estado = LEE_MEMORIA;
      break;
    }

    case WHILE: {
      // Reevalúa la condición del WHILE y repite o abandona el cuerpo.
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
      // Acciona la garra o la grúa del set de herramientas según el comando.
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

//******************************************************************************************************************
// Imprime por Serial las lecturas actuales de los trackers inferiores.
//
// Es una ayuda de depuración usada por los estados IF y WHILE antes de evaluar una rama;
// no lee los pines, solo muestra los valores globales ya capturados en loop().
//******************************************************************************************************************

void verSernsores(){
  Serial.println("****************************");
  Serial.println(lecturaSensorTrackerIzquierdo);
  Serial.println(lecturaSensorTrackerDerecho);
}



//******************************************************************************************************************
// Decide si se ejecuta la rama IF o se salta hasta ELSE/IFFIN.
//
// Si ambas condiciones se cumplen, marca ejecutandoRamaIf[anidamientoIF] para que un
// ELSE posterior sepa que la rama ya se ejecutó. Si no, activa ignorarHastaElse y guarda
// el nivel de anidamiento actual para saltar solo hasta la marca correspondiente.
//
// @param condicionSensorIzquierdo true si el tracker izquierdo cumple la condición pedida.
// @param condicionSensorDerecho true si el tracker derecho cumple la condición pedida.
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
// Traduce el valor de la instrucción IF/ELSE a las condiciones de los trackers.
//
// valor_instruccion codifica qué combinación de sensores sobre negro/blanco se pidió, o
// sensorNoImporta para un ELSE sin condición. Según el caso llama a validacionIf() con las
// lecturas (o sus negaciones) ya capturadas en loop().
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
// Ejecuta la lógica de flujo de una instrucción IF, ELSE o IFFIN.
//
// Al IFINICIA incrementa anidamientoIF y evalúa la condición. En ELSE, si la rama
// anterior ya se ejecutó, activa ignorarHastaIFFIN para saltar el resto; si no, evalúa la
// condición del ELSE. En IFFIN limpia la marca de la rama y baja el anidamiento. Se apoya
// en las banderas globales que luego consume LEE_MEMORIA.
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
// Decide si se entra al cuerpo del WHILE o se salta hasta WHILEFIN.
//
// Si la condición se cumple, guarda en indicesWhile[anidamientoWhile] el puntero a la
// instrucción del WHILE y sube el anidamiento para poder repetir el cuerpo. Si no, activa
// ignorarHastaWHILEFIN y guarda el nivel actual para saltar solo este ciclo.
//
// @param condicionSensorIzquierdo true si el tracker izquierdo cumple la condición pedida.
// @param condicionSensorDerecho true si el tracker derecho cumple la condición pedida.
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
// Igual que validacionWhile pero para un WHILE NOT: repite mientras NO se cumpla la condición.
//
// Guarda el índice de retorno y sube el anidamiento cuando la condición es falsa; en caso
// contrario activa ignorarHastaWHILEFIN y el nivel de salto.
//
// @param condicionSensorIzquierdo true si el tracker izquierdo cumple la condición pedida.
// @param condicionSensorDerecho true si el tracker derecho cumple la condición pedida.
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
// Ejecuta la lógica de flujo de WHILE y WHILE NOT.
//
// En WHILEFIN baja el anidamiento y devuelve inst_actual al índice guardado al entrar al
// ciclo, de modo que LEE_MEMORIA vuelva a evaluar la condición. En el inicio, decodifica
// valor_instruccion entre "mientras" y "mientras no" y las combinaciones de trackers, y
// llama a validacionWhile() o validacionNotWhile().
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
// Mueve el servo 360 del set de herramientas durante el tiempo de acción configurado.
//
// Usa las globales velocidad y tiempoDeAccion, que fija accionarHerramientaSet(). Tras el
// movimiento devuelve el servo a velocidadNeutra y espera 100 ms para que se detenga.
//******************************************************************************************************************

void accionarMotorHerramientaSet(){
  servoHerramientaSet.write(velocidad);
  delay(tiempoDeAccion);
  servoHerramientaSet.write(velocidadNeutra);
  delay(100);
};

//******************************************************************************************************************
// Acciona la garra o la grúa del set de herramientas según valor_instruccion.
//
// Para cada acción (abrir/cerrar garra, subir/bajar grúa) elige velocidad y tiempo y llama
// a accionarMotorHerramientaSet(). Antes comprueba posicionHerramienta: si la herramienta
// ya está en la posición pedida no la vuelve a mover. Tras moverse actualiza esa global,
// que arranca en 0 porque la posición inicial es desconocida.
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
// Traduce el programa que manda la app a la lista de instrucciones del robot.
//
// El mensaje se lee en bloques de 5 caracteres. Hay bloques de control de 5 letras (ATINI
// inicio, ATFIN fin del programa, PARAR, y marcas sin valor como CIFIN, OBINI/OBFIN,
// HEINI/HEFIN, IFFIN, WHFIN) y bloques de 2 letras + 3 dígitos de valor (AV avanzar y RE
// retroceder en cm, GD/GI girar en grados, CI ciclo con repeticiones, IF/EL/WH condiciones
// de los trackers, HE acción de garra/grúa). Cada instrucción se guarda en
// lista_instrucciones como [constante inst_..., valor]; ATFIN fija inst_final y al terminar
// inst_actual vuelve a 0 para que LEE_MEMORIA empiece desde el principio.
// Ejemplo: ATINIAV020GD030CI003RE010GI090CIFINATFIN.
//
// @param mensaje Mensaje completo, de hasta 500 caracteres (onWrite descarta los más largos).
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
// Procesa el estado pendiente del BLE y, si corresponde, interpreta un programa nuevo.
//
// Actualiza flagBluetooth con deviceConnected. Dentro de la sección crítica de bleMux
// recoge bleStopPending y nuevoMensajeBLE, copia el buffer a una variable local y limpia
// las banderas. Un STOP pendiente tiene prioridad y llama a requestMotionStop(). Si no hay
// conexión o mensaje, retorna. Descarta mensajes cuya longitud no sea múltiplo de 5 y no
// reemplaza programas durante una maniobra, con configuración inválida o con un fallo
// activo (calibrationIdle, configReady y motion.fault). Si interpreta el programa, activa
// el pulso recibeProgra para que el LED parpadee en azul.
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
// Activa o desactiva el lápiz moviendo el servo a activateAngle o deactivateAngle.
//
// El parámetro tapa a la global int set, que no se usa aquí. Espera 500 ms después de
// escribir el ángulo para que la siguiente instrucción no empiece con el servo en marcha.
//
// @param set true para bajar/activar la herramienta; false para subirla/desactivarla.
//
// @return Siempre true, porque la escritura al servo no informa errores.
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
// Elige el color o parpadeo del LED RGB externo e interno según el estado del robot.
//
// Se llama al final de cada loop(). El orden de las comprobaciones es la prioridad:
// batería baja (rojo parpadeante), obstáculo o paro de emergencia (rojo fijo), Bluetooth
// desconectado (verde/azul intercalados), recepción de programa (azul parpadeante),
// ejecución (verde fijo) y Bluetooth conectado (azul fijo). Para los parpadeos reutiliza
// tiempoDeEncendidoDeLed como referencia de fase y lo reinicia al completar cada ciclo.
//
// @param flagBateriaBaja Lectura de la señal del powerboost; LOW indica batería baja.
// @param flagBluetooth true si hay conexión Bluetooth con la App.
// @param flagEjecucion true si se está ejecutando una programación.
// @param flagObstaculo true si los sensores infrarrojos detectaron un obstáculo.
// @param recibeProgra Pulso activo mientras se recibe/recién se recibió un programa.
// @param flagParar true si se pidió un paro de emergencia.
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

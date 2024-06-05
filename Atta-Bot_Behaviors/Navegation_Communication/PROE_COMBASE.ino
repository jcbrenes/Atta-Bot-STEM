//Código de feather base que recibe datos de los robots en el campo y los envia por usb al puerto serial en el formato predefinido


#include <SPI.h>
#include <RH_RF69.h>
#include <RHDatagram.h>

/************ Serial Setup ***************/
#define debug 1

#if debug == 1
#define serialPrint(x) Serial.print(x)
#define serialPrintln(x) Serial.println(x)
#else
#define serialPrint(x)
#define serialPrintln(x)
#endif

// Variables para la transformación de coordenadas
const int cantidadRobots = 3;
int transformacionRespectoA = 1; // La transformacion de coordeanadas se va a hacer respecto a este robot
int distCoordenadas; // Recibe la informacion de distanci de cada robot
int matTransformation[cantidadRobots]; // Arreglo utilizado para transformar las coordenadas de los robots.


/************ Radio Setup ***************/
#define RF69_FREQ 915.0   // Frecuencias deben ser iguales con respecto a los demás nodos
#define MY_ADDRESS     0  // Dirección del receptor (base). No sé si es necesaria.
// Definiciones de pines.
#define RFM69_CS      8
#define RFM69_INT     3
#define RFM69_RST     4
#define LED           13

// Inicialización del driver de la biblioteca Radio Head.
RH_RF69 rf69(RFM69_CS, RFM69_INT);
RHDatagram rf69_manager(rf69, MY_ADDRESS);

// Declaración de variables
unsigned long timeStamp1;
uint8_t buf[RH_RF69_MAX_MESSAGE_LEN];
uint8_t len = sizeof(buf);
uint8_t idMensajeRecibido;

// Variables de recepción de datos
int16_t posX;
int16_t posY;
int16_t rot;
int8_t tipSens;
int16_t dis;
int16_t angulo;

int c = 0;

void setup() 
{
  /****General****/
  if (debug == 1){
    Serial.begin(9600);
    while (!Serial); // wait until serial console is open, remove if not tethered to computer 
  }
  pinMode(LED, OUTPUT);     
  pinMode(RFM69_RST, OUTPUT);
  digitalWrite(RFM69_RST, LOW);

  serialPrintln("Prueba base");
  serialPrintln();

  // manual reset
  digitalWrite(RFM69_RST, HIGH);
  delay(10);
  digitalWrite(RFM69_RST, LOW);
  delay(10);
  
  if (!rf69_manager.init()) {
    serialPrintln("RFM69 radio init failed");
    while (1);
  }
  serialPrintln("RFM69 radio init OK!");
  Serial.println("RFM69 radio init OK!");
  
  // Setear frecuencia
  if (!rf69.setFrequency(RF69_FREQ)) {
    Serial.println("setFrequency failed");
  }

  // Configurar potencia
  rf69.setTxPower(20, true);   //Rango de 14-20 para la potencia, segundo argumento debe ser verdadero para el 69HCW.

  Serial.print("RFM69 radio @");  Serial.print((int)RF69_FREQ);  Serial.println(" MHz");

  sincronizar(); // Envía el valor de clock a los robots del enjambre

  // Crear el arreglo para la transformacion de coordenadas
  for (int i = 0; i < cantidadRobots; i++) // Inicializacion del arreglo
  {
    matTransformation[i] = 0;
  }

  transformation(); // Recibe la información de la transoformación de coordenadas, comentar en caso de no requerirse
}

void loop() {
  // Código
  if (rf69_manager.available()){
    if (rf69_manager.recvfrom(buf, &len, &idMensajeRecibido)){
      buf[len] = 0;
      posX = *(int16_t*)&buf[0];
      posY = *(int16_t*)&buf[2] + matTransformation[idMensajeRecibido];;
      rot = *(int16_t*)&buf[4];
      tipSens = (int8_t)buf[6];
      dis = *(int16_t*)&buf[7];
      angulo = *(int16_t*)&buf[9];
    }
    if(tipSens != 20){ // Cuando recibe una distancia el tipo de sensor es 20
      serialPrint(idMensajeRecibido);serialPrint("; ");serialPrint(posX);serialPrint("; ");serialPrint(posY);
      serialPrint("; ");serialPrint(rot);serialPrint("; ");serialPrint(tipSens);
      serialPrint("; ");serialPrint(dis);serialPrint("; ");serialPrintln(angulo);
    }
  }
  
  actividad();
}

/// \brief Envía el valor del clock en el registro para sincronizar los robots.
/// \return Devuelve true si se envía el mensaje y false en caso contrario.
bool sincronizar(){
  timeStamp1 = RTC->MODE0.COUNT.reg; //Extraer tiempo del RTC de la base
  uint8_t reloj[4];
  uint32_t* ptrReloj = (uint32_t*)&timeStamp1;       //Utilizo el puntero para extraer la información del dato flotante.
  for(uint8_t i = 0; i < 4; i++){
    reloj[i] = *ptrReloj >> i*8;  //La parte de "(255UL << i*8)) >> i*8" es solo para ir acomodando los bytes en el array de envío mensaje[].
  }

  return rf69_manager.sendto(reloj, sizeof(reloj), RH_BROADCAST_ADDRESS);     //Enviar valor del RTC al esclavo
}

/// @brief Protocolo de inicio para realizar la transoformacion de coordenadas
void transformation(){
  int distanciasRecibidas[cantidadRobots]; // Arreglo para almacenar las distancias entre robots
  bool distanciaRobotRecibida[cantidadRobots]; // Arreglo para saber que distancia se ha recibido
  bool todasDistanciasRecibidas = false; // Verifica que se tengan todas las distancias

  // Inicio de la variable
  for (int i = 0; i < cantidadRobots; i++)
  {
    distanciaRobotRecibida[i] = false;
  }
  
  // Mientras no se hayan recibido las distancias no inicia
  while (!todasDistanciasRecibidas)
  {
    if (rf69_manager.available()){ // Recepcion de datos
      if (rf69_manager.recvfrom(buf, &len, &idMensajeRecibido)){
        buf[len] = 0;
        distCoordenadas = *(int16_t*)&buf[0];
        tipSens = (int8_t)buf[6];
        if(tipSens == 20){
          distanciasRecibidas[idMensajeRecibido - 1] = distCoordenadas;
          distanciaRobotRecibida[idMensajeRecibido - 1] = true;
        }
      }
    }

    // Verifica si llegaron todos los mensajes
    for (int i = 0; i < cantidadRobots - 1; i++)
    {
      if (distanciaRobotRecibida[i] == true && distanciaRobotRecibida[i+1] == true){
        todasDistanciasRecibidas = true;
      }
      else{
        todasDistanciasRecibidas = false;
      }
    }
  }
  
  // Configuracion del arreglo de transformacion
  for (int i = 0; i < cantidadRobots; i++)
  {
    if (i+1 < transformacionRespectoA){
      for (int j = i; j < transformacionRespectoA - 1; j++)
      {
        matTransformation[i] -= distanciasRecibidas[j];
      }
    }
    if (i+1 > transformacionRespectoA)
    {
      for (int j = transformacionRespectoA-1; j < i; j++)
      {
        matTransformation[i] += distanciasRecibidas[j];
      }
    }
  }
  
  // Imprime un resumen de los valores recibidos
  for (int i = 0; i < cantidadRobots; i++)
  {
    serialPrint(i+1);serialPrint(' ');serialPrint(distanciasRecibidas[i]);serialPrint(' ');serialPrintln(matTransformation[i]);
  }
}

void actividad(){  //Pulsar led 13 para mostrar actividad del feather
  if(c>100000){
    digitalWrite(13,!digitalRead(13));
    c=0;
  }
  else{
    c=c+1;
  }
}
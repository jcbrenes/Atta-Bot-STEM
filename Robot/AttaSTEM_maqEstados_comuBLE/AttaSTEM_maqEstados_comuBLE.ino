#define ENCODER_DO_NOT_USE_INTERRUPTS
#include <ArduinoBLE.h>
#include <string>
#include <Encoder.h>
using namespace std;

//constantes del robot empleado
const int tiempoMuestreo=100000; //unidades: micro segundos
const float pulsosPorRev=45; //cantidad de pulsos de una única salida
const int factorEncoder=4; //cantidad de salidas de encoders que se están detectando (pueden ser 2 o 4)
const float circunferenciaRueda=139.5;//Circunferencia de la rueda = 139.5mm 
const float pulsosPorMilimetro=((float)pulsosPorRev)/circunferenciaRueda; 
const float distanciaCentroARueda=61;// Radio de giro del carro, es la distancia en mm entre el centro y una rueda. 
const float conversionMicroSaMin=1/(60 * 1000000);// factor de conversion microsegundo (unidades del tiempo muestreo) a minuto
const float conversionMicroSaSDiv=1000000;// factor de conversion microsegundo (unidades del tiempo muestreo) a segundo
const float tiempoMuestreoS= (float)tiempoMuestreo/conversionMicroSaSDiv;

//constantes para control PID movimiento lineal para tiempoMuestreo=100000 us
const float velRequerida=120.0; //unidades mm/s
const float KpVel=1; //constante control proporcional
const float KiVel=0.65; //constante control integral
const float KdVel=0.0; //constante control derivativo

//constantes para control PID de giro 
const float KpGiro=4.0; //constante control proporcional
const float KiGiro=1.1;//constante control integral
const float KdGiro=0.17; //constante control derivativo

//Constantes para la implementación del control PID real
const int errorMinIntegralVelocidad=-255;
const int errorMaxIntegralVelocidad=255;
const int errorMinIntegralGiro=-110;
const int errorMaxIntegralGiro=110;
const int limiteSuperiorCicloTrabajoVelocidad=200;
const int limiteInferiorCicloTrabajoVelocidad=90;
int limiteSuperiorCicloTrabajoGiro=150;
int limiteInferiorCicloTrabajoGiro=0;
const int limiteSuperiorCicloTrabajoGiroCalibracion=50;
const int limiteInferiorCicloTrabajoGiroCalibracion=-50;
const int cicloTrabajoMinimo= 20;
const int minCiclosEstacionario= 20;
const float correcionVelRuedas = 0.5;

// Muestreo velocidad
unsigned long previousMillis=0;
long intervaloTiempoMuestreo=100;
long contPulsosPasadoIzq=0;
long contPulsosPasadoDer=0;
long contPulsosIzq=0;
long contPulsosDer=0;

//Variables que almacenan el desplazamiento angular de cada rueda
float posActualRuedaDerecha = 0.0;
float posActualRuedaIzquierda = 0.0;

//Variables del valor de velocidad en cada rueda
float velActualDerecha = 0.0;
float velActualIzquierda = 0.0;

//Valores acumulados para uso en las ecuaciones de control
//Para Giro
float errorAnteriorGiroDer = 0;
float errorAnteriorGiroIzq = 0;
float sumErrorGiroDer = 0;
float sumErrorGiroIzq = 0;
int contCiclosEstacionarioGiro = 0;

//Para Velocidad
float errorAnteriorVelDer = 0;
float errorAnteriorVelIzq = 0;
float sumErrorVelDer = 0;
float sumErrorVelIzq = 0;

//Para Coordenadas
float distLinealRuedaDerecha = 0;
float distLinealRuedaIzquierda = 0;

//Variables para avance
int distanciaAvanzada = 0;
bool giroTerminado = 1; //Se hace esta variable global para saber cuando se está en un giro y cuando no



// variables para los pines de la ideaboard
long contadorPulsosIzquierda = 0;
long contadorPulsosDerecha = 0;
const int motorIzquierdoA = 12;
const int motorIzquierdoB = 14;
const int motorDerechoA = 13;
const int motorDerechoB = 15;
const int sensorInfrarrojoFrontal = 34;
const int sensorInfrarrojoDerecho = 39;
const int sensorInfrarrojoIzquierdo = 4;
const int sensorTrackerDerecho=5;
const int sensorTrackerIzquierdo=36;
const int pin_boton_Start=19;
const int pin_boton_Stop=18;

//Iniciados de contador de enconders
Encoder encoderIzquierdo(27, 33);
Encoder encoderDerecho(32, 35);



//variables máquina de estados
enum posibles_Estados {ESPERA=0, LEE_MEMORIA, MOVERSE, GIRAR, DETENERSE, CICLO, OBSTACULOS, MOVIMIENTO_OBSTACULO, NADA};
posibles_Estados estado = ESPERA;
bool giro_listo = false;
bool movimiento_listo = true; 
bool obstaculos_activo = false;
bool primer_ciclo = true;
bool retroceso_listo = true;
bool obstaculo_detectado=false;
bool paro_emergencia=false;

//variables para comunicación Bluetooth
string mensajeBLE="";
BLEService servicio("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
BLEStringCharacteristic caracteristico("beb5483e-36e1-4688-b7f5-ea07361b26a8", BLERead | BLEWrite, 512);

//apuntadores y variables para la lista de instrucciones
enum posibles_Instrucciones {inst_Avanzar=1, inst_Retroceder, inst_GiroIzquierdo, inst_GiroDerecho, inst_CicloInicia, inst_CicloFin, inst_ObstaculoInicia, inst_ObstaculoFin, inst_FinalMsg};
short lista_instrucciones[100][2];
short inst_final = 0;
short inst_actual = 0;
short instruccion = 0;
short valor_instruccion = 0;
short inst_inicio_ciclo = 0;
short cantidad_ciclos = 0;


void setup() {

  pinMode(motorIzquierdoA, OUTPUT);
  pinMode(motorDerechoA, OUTPUT);
  pinMode(motorIzquierdoB, OUTPUT);
  pinMode(motorDerechoB, OUTPUT);
  pinMode(sensorInfrarrojoFrontal,INPUT);
  pinMode(sensorInfrarrojoDerecho,INPUT);
  pinMode(sensorInfrarrojoIzquierdo,INPUT);
  pinMode(sensorTrackerDerecho,INPUT);
  pinMode(sensorTrackerIzquierdo,INPUT);
  pinMode (pin_boton_Start, INPUT_PULLUP);
  pinMode(pin_boton_Stop,INPUT_PULLUP);
  encoderIzquierdo.write(0);
  encoderDerecho.write(0);
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
  contadorPulsosIzquierda = encoderIzquierdo.read();
  contadorPulsosDerecha = encoderDerecho.read();
  Serial.print("motor 1:");// no hace nada pero se ocupa un tipo de delay para que los motores se muevan y esto es lo que mejor funciona jeje
  int lecturaBotonStart=digitalRead( pin_boton_Start );
  int lecturaBotonStop=digitalRead( pin_boton_Stop );
  int lecturaInfrarrojoFrontal=digitalRead(sensorInfrarrojoFrontal);
  int lecturaInfrarrojoDerecho=digitalRead(sensorInfrarrojoDerecho);
  int lecturaInfrarrojoIzquierdo=digitalRead(sensorInfrarrojoIzquierdo);
  int lecturaSensorTrackerDerecho=digitalRead(sensorTrackerDerecho);
  int lecturaSensorTrackerIzquierdo=digitalRead(sensorTrackerIzquierdo);

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
      }

      break; 
    }
    
    case MOVERSE: {

      //Ejecuta el estado de avanzar o retroceder
      //(es el mismo pero con distancia negativa)
      movimiento_listo=AvansarDistanciaDeseada(valor_instruccion, contadorPulsosDerecha, contadorPulsosIzquierda);

      //Lógica estado siguiente
      if (!lecturaBotonStop) { 
        paro_emergencia=true;
        estado = DETENERSE;

      }else if ( movimiento_listo ) {
        estado = DETENERSE;
      }
      else if (obstaculos_activo) {
        if (!lecturaInfrarrojoFrontal||!lecturaInfrarrojoDerecho||!lecturaInfrarrojoIzquierdo||lecturaSensorTrackerDerecho||lecturaSensorTrackerIzquierdo){
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
      movimiento_listo=Giro(valor_instruccion);

      //Lógica estado siguiente
      if (!lecturaBotonStop) {
        paro_emergencia=true; 
        estado = DETENERSE;

      }else if ( movimiento_listo ) {
        //movimiento_listo = false;
        estado = DETENERSE;
      }
      else if (obstaculos_activo) {
        if (!lecturaInfrarrojoFrontal||!lecturaInfrarrojoDerecho||!lecturaInfrarrojoIzquierdo||lecturaSensorTrackerDerecho||lecturaSensorTrackerIzquierdo){
          obstaculo_detectado=true;
          estado=DETENERSE;
        }
      }
      break;
    }

    case DETENERSE: {

      //***Poner los motores en OFF
      
      ConfiguraEscribePuenteH(1,0,0);
      ConfiguraEscribePuenteH(-1,0,0);
      ConfiguraEscribePuenteHGiro(1,0,0);
      ConfiguraEscribePuenteHGiro(-1,0,0);
      delay(500);
      // reset de encoders
      encoderIzquierdo.write(0);
      encoderDerecho.write(0);
      if (!lecturaBotonStop) {
        paro_emergencia=true;
      }
      
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
      // *Genera el movimiento despues que un obstaculo se detect, el cual corresponde a un retroceso
      retroceso_listo=AvansarDistanciaDeseada(-50, contadorPulsosDerecha, contadorPulsosIzquierda);
      obstaculo_detectado=false;
      
      // Lógica estado siguiente
      if (!lecturaBotonStop) { 
        paro_emergencia=true;
        estado = DETENERSE;
      } else if (retroceso_listo){
        ConfiguraEscribePuenteH(-1,0,0);
        estado = ESPERA;
      } 
      break;
    }

    case NADA: {
      break;
    }
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
        }
        
  }
  inst_actual = 0; 
}

///////// FUNCIONES DE MOVERSE (AVANCE Y RETROCESO)//////////////////

//***************************************************************************************
//Función que determina si es avance, o retroceso en base a los valores de distancia y 
//configura los pines del Puente H
//
//Utiliza el valor de distancia para determinar si se va a avanzar o retroceder
//despues de esto escribe los valores de PMW acordes a la accion del control
//
//
//@param distanciaDeseada la distancia que se movera el robot en cm 
//@param pmwRuedaDer el valor de pmw para la rueda derecha basado en el control PID
//@param pmwRuedaIzq el valor de pmw para la rueda izquierda basado en el control PID
// 
//***************************************************************************************

void ConfiguraEscribePuenteH (int distanciaDeseada, int pwmRuedaDer, int pwmRuedaIzq) {
  if (distanciaDeseada >= 0) {
    analogWrite(motorIzquierdoA, pwmRuedaDer);
    analogWrite(motorDerechoB, pwmRuedaIzq);

  } else if (distanciaDeseada<= 0) {
    analogWrite(motorIzquierdoB, pwmRuedaDer);
    analogWrite(motorDerechoA, pwmRuedaIzq);
  }
}

//***************************************************************************************
//Función que realiza el cálculo de la distancia lineal recorrida por cada rueda
//
//Utiliza el contador de encoders de la biblioteca ENCODERS para determinar la distancia avanzada 
//por el robot al dividir este contador entre los pulsos por milimetros para clacular la distacia en mm
//
//
//@param contadorPulsosIzquierda el contador de pusos del encoder izquierdo
//@param contadorPulsosDerecha el contador de pusos del encoder derecho
//@return DistanciaLineal la distancia avanzada de forma lineal en mm
// 
//***************************************************************************************

float calculaDistanciaLinealRecorrida(long contadorPulsosIzquierda, long contadorPulsosDerecha) {

  
  float distLinealRuedaDerecha = -contadorPulsosIzquierda / pulsosPorMilimetro;
  float distLinealRuedaIzquierda = contadorPulsosDerecha / pulsosPorMilimetro;
  float DistanciaLineal = (distLinealRuedaDerecha + distLinealRuedaIzquierda) / 2.0;
  return DistanciaLineal;
}

//***************************************************************************************
//Funcion para implementar el control PID por velocidad en una rueda.
//
//Se debe tener un muestreo en tiempos constantes, no aparecen las constantes de tiempo en la ecuación, 
//sino que se integran con las constantes Ki y Kd. Se recibe la posición de referencia, la posición actual 
//(medida con los encoders), el error acumulado (por referencia), y el valor anterior del error (por referencia)
//Entrega el valor de ciclo de trabajo (PWM) que se enviará al motor CD
//
//
//@param velRef la velocidad que se busca alcanzar
//@param velActual velocidad actual del robot
//@param sumErrorVel suma del error de la velocidad que debe ser parametro global
//@param errorAnteriorVel error anterior de la velocidad que debe ser parametro global
//@return pidTermVel valor pid para ser colocado en los motores para el avanze o retroceso
// 
//***************************************************************************************

int ControlVelocidadRueda( float velRef, float velActual, float& sumErrorVel, float& errorAnteriorVel ) {


  float errorVel = velRef - velActual; //se actualiza el error actual

  //se actualiza el error integral y se restringe en un rango, para no aumentar sin control
  //como son variables que se mantienen en ciclos futuros, se usan variables globales
  sumErrorVel += errorVel * tiempoMuestreoS; //Anteriormente se comportaba como producto de sumatoria cuando debía ser sumatoria de productos
  sumErrorVel = constrain(sumErrorVel, errorMinIntegralVelocidad, errorMaxIntegralVelocidad);

  //error derivativo (diferencial)
  float difErrorVel = (errorVel - errorAnteriorVel) / tiempoMuestreoS / 10; //Se divide el factor derivativo entre 10 debido a la inestabilidad de la velocidad por falta de precisión en la medición

  //ecuación de control PID
  float pidTermVel = ((KpVel * errorVel) + (KiVel * sumErrorVel) + (KdVel * difErrorVel));  //Agregada división entre 5 porque PID saturaba, buscar donde está el error
  
  //Se limita los valores máximos y mínimos de la acción de control, para no saturarla
  pidTermVel = constrain( (int)pidTermVel, limiteInferiorCicloTrabajoVelocidad, limiteSuperiorCicloTrabajoVelocidad);


  //actualiza el valor del error para el siguiente ciclo
  errorAnteriorVel = errorVel;
  return  ((int)pidTermVel);
}

//***************************************************************************************
//Función que ejecuta el avance o retroceso del carro mediante el cálculo de la velocidad y
//la aplicacion del control de la misma
//
//Inicia con el calculo de la velocidad actual del robot crando un ciclo con millis para 
//poder definir la cantidad de pulsos en una cantidad de tiempo y de aca determinar la velocidad, despues 
//de esto, usa esta velocidad para implementar el controlen cada rueda, ademas acalcula la distancia que esta 
//recorriendose para determinar cuando se ha llegado a la distancia deseada, a esto punto reinicia la variables y 
//convierte el booloeano de avanceListo en un true.
//
//
//@param distanciaDeseada la distancia que se busca avansar o retroceder, un numero en mm
//@param contadorPulsosIzquierda el contador de pusos del encoder izquierdo
//@param contadorPulsosDerecha el contador de pusos del encoder derecho
//@return avanceListo booloeano que indica que se ha avanzado o retrocedido la distancia deseada
// 
//***************************************************************************************

bool AvansarDistanciaDeseada (int distanciaDeseada, long pulsosEncoderIzq, long pulsosEncoderDer) {
  
  float(contPulsosIzq= pulsosEncoderIzq);
  float(contPulsosDer= pulsosEncoderDer);
  // crea una condicion de tiempo usando milis para aplicar un tiempo de muestreo si usar delays ya que no son compatibles con la biblioteca de encoders
  unsigned long currentMillis=millis();
  if ((currentMillis-previousMillis) >= intervaloTiempoMuestreo){
    previousMillis=currentMillis;
    //se calculan las velocidades de ambas ruedas
    float velActualIzquierda = ((float)(contPulsosIzq - contPulsosPasadoIzq) / pulsosPorMilimetro) / (float)(intervaloTiempoMuestreo*0.001); //velocidad en mm por s
    float velActualDerecha = ((float)(contPulsosDer - contPulsosPasadoDer) / pulsosPorMilimetro) / (float)(intervaloTiempoMuestreo*0.001); //velocidad en mm por s
    velActualDerecha= -1.0 *  velActualDerecha; // debido a la lectura de encors, la velocidad derecha es negativa, por lo que se transforma a positiva.
    contPulsosPasadoIzq = contPulsosIzq;
    contPulsosPasadoDer = contPulsosDer;
    float velSetPoint= velRequerida;// velocidad deseada de las ruedas
    if (distanciaDeseada<0){  //Si la distancia deseada es negativa, significa retroceder y por ende la logica de lecturas de encoders es cambiada para que siempre sea positivos
      velActualDerecha= -1.0 *  velActualDerecha;
      velActualIzquierda=-1.0*velActualIzquierda;
    }
    //float errorVelocidad = velActualDerecha - velActualIzquierda; //Error entre la velocidad de las dos ruedas
    float velSetPointDerecha = velSetPoint;// se define la velocidad objetivo para cada rueda
    float velSetPointIzquierda = velSetPoint; 
    //se aplica el lazo de control PID de velocidad para obtener un valor PMW para cada rueda
    int cicloTrabajoRuedaDerecha = ControlVelocidadRueda(velSetPointDerecha, velActualDerecha, sumErrorVelDer, errorAnteriorVelDer);
    int cicloTrabajoRuedaIzquierda = ControlVelocidadRueda(velSetPointIzquierda, velActualIzquierda, sumErrorVelIzq, errorAnteriorVelIzq);
    //Se configura el puente H 
    ConfiguraEscribePuenteH (distanciaDeseada, cicloTrabajoRuedaDerecha, cicloTrabajoRuedaIzquierda);
    // calculo de la distancia
    float distanciaAvanzada= calculaDistanciaLinealRecorrida(contadorPulsosIzquierda,contadorPulsosDerecha);
    // define si el avance fue finalizado 
    bool avanceListo = false; 
    if (abs(distanciaAvanzada) >= abs(distanciaDeseada)) {
    sumErrorVelDer=0;
    errorAnteriorVelDer=0;
    sumErrorVelIzq=0;
    errorAnteriorVelIzq=0;
    distanciaAvanzada=0;
    avanceListo=true;
    }
  return avanceListo;
  }
}




////////////// FUNCIONES DE GIRO (GIRO DERECHO E IZQUIERDO)//////////////

//***************************************************************************************
//Función que determina si es giro derecho o giro izquierdo en base a los valores de giro 
//y configura los pines del Puente H
//
//Utiliza el valor del giro para determinar si se va a girara a la derecha o izquierda
//despues de esto escribe los valores de PMW acordes a la accion del control
//
//
//@param giroDeseado el giro que se movera el robot en grados
//@param pmwRuedaDer el valor de pmw para la rueda derecha basado en el control PID
//@param pmwRuedaIzq el valor de pmw para la rueda izquierda basado en el control PID
// 
//***************************************************************************************

void ConfiguraEscribePuenteHGiro (int giroDeseado, int pwmRuedaDer, int pwmRuedaIzq) {
  if (giroDeseado >= 0) {
    analogWrite(motorIzquierdoB, pwmRuedaDer);
    analogWrite(motorDerechoB, pwmRuedaIzq);

  } else if (giroDeseado<= 0) {
    analogWrite(motorIzquierdoA, pwmRuedaDer);
    analogWrite(motorDerechoA, pwmRuedaIzq);
  }
}


//***************************************************************************************
//Función que calcula la distancia angular (en grados) que se ha desplazado el robot.
//
//Para robots diferenciales, en base a un giro sobre su eje (no arcos). Recibe la cantidad de
//pulsos de la rueda. Devuelve un ángulo en grados. Esto lo hace al usar el contador de los encoders
//y tranformarlo en la distacia de la circunferencia obtenida. 

//
//
//@param cantPulsos contador de pulsos del encoder de la rueda correspondiente
//@return despAngular desplazamiento angular del robot
// 
//***************************************************************************************

float ConvDistAngular(float cantPulsos) {

  //Para robots diferenciales, en base a un giro sobre su eje (no arcos)
  //Recibe la cantidad de pulsos de la rueda. Devuelve un ángulo en grados.

  float despAngular = cantPulsos / (distanciaCentroARueda * pulsosPorMilimetro) * 180 / PI;
  return despAngular;
}

//***************************************************************************************
//Funcion para implementar el control PID por posición en una rueda.
//
//Se debe tener un muestreo en tiempos constantes, no aparecen las constantes de tiempo en la ecuación, 
//sino que se integran con las constantes Ki y Kd. Se recibe la posición de referencia, la posición actual
//(medida con los encoders), el error acumulado (por referencia), y el valor anterior del error (por referencia)
//Entrega el valor de ciclo de trabajo (PWM) que se enviará al motor CD
//
//
//@param posRef el ángulo que se busca alcanzar
//@param posActual ángulo actual del robot
//@param sumErrorGiro suma del error del giro que debe ser parametro global
//@param errorAnteriorGiro error anterior del giro que debe ser parametro global
//@return pidTermGiro valor pid para ser colocado en los motores para el avanze o retroceso
// 
//***************************************************************************************


int ControlPosGiroRueda( float posRef, float posActual, float& sumErrorGiro, float& errorAnteriorGiro ) {


  float errorGiro = posRef - posActual; //se actualiza el error actual
  //se actualiza el error integral y se restringe en un rango, para no aumentar sin control
  //como son variables que se mantienen en ciclos futuros, se usan variables globales
  sumErrorGiro += errorGiro * tiempoMuestreoS;
  sumErrorGiro = constrain(sumErrorGiro, errorMinIntegralGiro, errorMaxIntegralGiro);

  //error derivativo (diferencial)
  float difErrorGiro = (errorGiro - errorAnteriorGiro) / tiempoMuestreoS;

  //ecuación de control PID
  float pidTermGiro = (KpGiro * errorGiro) + (KiGiro * sumErrorGiro) + (KdGiro * difErrorGiro);

  //Se limita los valores máximos y mínimos de la acción de control, para no saturarla
  pidTermGiro = constrain( int (pidTermGiro), limiteInferiorCicloTrabajoGiro, limiteSuperiorCicloTrabajoGiro);

  //Restricción para manejar la zona muerta del PWM sobre la velocidad
  if (-cicloTrabajoMinimo < pidTermGiro && pidTermGiro < cicloTrabajoMinimo) {
    pidTermGiro = 0;
  }

  //actualiza el valor del error para el siguiente ciclo
  errorAnteriorGiro = errorGiro;

  return  pidTermGiro;
}

//***************************************************************************************
//Función que revisa el estado de la acción de control y si se mantiene varios ciclos en 
//cero, asume que ya está en el estado estacionario
//
//Utiliza el valor de PMW para cada motor y si determina que estos son cero, determina que
//el giro fue completado.
//
//@param contCiclosEstacionario el contador de ciclos que se llevan a cabo en 0
//@param pmwRuedaDer el valor de pmw para la rueda derecha basado en el control PID
//@param pmwRuedaIzq el valor de pmw para la rueda izquierda basado en el control PID
//@return estadoEstacionarioAlcanzado booleano que determina que el estado estacionario fue alcanzado
// 
//***************************************************************************************

bool EstadoEstacionario (int pwmRuedaDer, int pwmRuedaIzq, int& contCiclosEstacionario) {
  //Recibe los ciclos de trabajo en cada rueda y una variable por referencia donde se almacenan cuantos ciclos seguidos se llevan
  //Devuelve una variable que es TRUE si ya se alcanzó el estado estacionario

  bool estadoEstacionarioAlcanzado = false;

  if (pwmRuedaDer == 0 && pwmRuedaIzq == 0) {
    contCiclosEstacionario++;
    if (contCiclosEstacionario > minCiclosEstacionario) {
      contCiclosEstacionario = 0;
      estadoEstacionarioAlcanzado = true;
    }
  } else {
    contCiclosEstacionario = 0;
  }

  return estadoEstacionarioAlcanzado;
}

//***************************************************************************************
//Función que ejecuta el giro del robot sobre su propio eje. 
//
//Usa control PID en cada rueda. Este control PID permite el movimiento hasta llegar al giro 
//desado, una vez aca se usa la funcion de estado estacionario para definir que el giro ha 
//terminado por completo y si es asi define el booleano de giro terminado como real.
//
//@param grados la cantidad de grados que se desea girar
//@return giroListo booleano que determina que el giro ha sido realizado
// 
//***************************************************************************************

bool Giro(float grados) {
  grados = 1.2 * grados;
  bool negativo = false;
  posActualRuedaDerecha = abs(ConvDistAngular(contadorPulsosIzquierda));
  posActualRuedaIzquierda = abs(ConvDistAngular(contadorPulsosDerecha));

  if (grados<0){
    negativo = true;
    grados = -grados;
  }
  
  int cicloTrabajoRuedaDerecha = ControlPosGiroRueda( grados, posActualRuedaDerecha, sumErrorGiroDer, errorAnteriorGiroDer );
  int cicloTrabajoRuedaIzquierda = ControlPosGiroRueda( grados, posActualRuedaIzquierda, sumErrorGiroIzq, errorAnteriorGiroIzq);
  if (negativo){
    grados=-grados;
    negativo=false;
  }
  ConfiguraEscribePuenteHGiro (grados,cicloTrabajoRuedaDerecha, cicloTrabajoRuedaIzquierda);
  bool giroListo = EstadoEstacionario (cicloTrabajoRuedaDerecha, cicloTrabajoRuedaIzquierda, contCiclosEstacionarioGiro);
  if (giroListo){
    sumErrorGiroDer = 0;
    errorAnteriorGiroDer = 0;
    sumErrorGiroIzq = 0;
    errorAnteriorGiroIzq = 0;
  }
  return giroListo;
}

#include <ArduinoBLE.h>
#include <string>
using namespace std;

//Definición de pines
const int pin_boton_Start=35;
const int pin_boton_Stop=34;

//variables máquina de estados
enum posibles_Estados {ESPERA=0, LEE_MEMORIA, MOVERSE, GIRAR, DETENERSE, CICLO, OBSTACULOS, NADA};
posibles_Estados estado = ESPERA;
bool giro_listo = false;
bool movimiento_listo = true; 
bool obstaculos_activo = false;
bool primer_ciclo = true;

//variables para comunicación Bluetooth
string mensajeBLE="ATINIOBINIAV020GD030CI003RE010GI090CIFINOBFINATFIN";
BLEService servicio("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
BLEStringCharacteristic caracteristico("beb5483e-36e1-4688-b7f5-ea07361b26a8", BLERead | BLEWrite, 512);

//apuntadores y variables para la lista de instrucciones
enum posibles_Instrucciones {inst_Avanzar=1, inst_Retroceder, inst_GiroIzquierdo, inst_GiroDerecho, inst_CicloInicia, inst_CicloFin, inst_ObstaculoInicia, inst_ObstaculoFin};
short lista_instrucciones[100][2];
short inst_final = 0;
short inst_actual = 0;
short instruccion = 0;
short valor_instruccion = 0;
short inst_inicio_ciclo = 0;
short cantidad_ciclos = 0;


void setup() {

  pinMode(pin_boton_Start, INPUT);
  pinMode(pin_boton_Stop, INPUT);
  Serial.begin(115200);

  //Inicialización comunicación bluetooth BLE
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
    while (1);
  }
  BLE.setLocalName("MyBLE");
  BLE.setAdvertisedService(servicio);
  servicio.addCharacteristic(caracteristico);
  BLE.addService(servicio);
  BLE.advertise();

}

void loop() {
  
  BLEDevice central = BLE.central();

  //Máquina de estados principal
  switch (estado) {

    case ESPERA:  { 
      //Serial.print("Stop: ");
      //Serial.println(digitalRead( pin_boton_Stop ) );
      Serial.println("Estado: Espera (recibe mensaje BLE)");
      delay(1000);

      //Leer comunicación por BLE
      if (central) {
      Serial.print("Conectado al central: ");
      Serial.println(central.address());
      while (central.connected()) {
        if (caracteristico.written()) {
          Serial.print("Recibido: ");
          mensajeBLE = string( caracteristico.value().c_str() );
          Serial.println(mensajeBLE.c_str());
          caracteristico.writeValue("");
        }
      }
      Serial.print("Desconectado del central: ");
      Serial.println(central.address());
      
      //Arranca cuando se programa ***Para pruebas***
      estado = LEE_MEMORIA;
      inst_actual = 0;
      }
      
      //Revisa la cadena de caracteres y extrae las instrucciones 
      Interpreta_mensajeBLE(mensajeBLE); 

      //Lógica estado siguiente
      if (digitalRead( pin_boton_Start )) { 
        estado = LEE_MEMORIA;
        inst_actual = 0;
      }

      break;
    }

    case LEE_MEMORIA:  { 

      if ( inst_actual != inst_final ){
        instruccion = lista_instrucciones[inst_actual][0];
        valor_instruccion = lista_instrucciones[inst_actual][1];
        inst_actual++; 
      } else {
        inst_actual = 0;
      }
      
      //Lógica estado siguiente
      if (digitalRead( pin_boton_Stop )  ||  inst_actual == inst_final) { 
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

      Serial.print("Estado: Lee Memoria -> ");
      Serial.print(posibles_Instrucciones(instruccion));
      Serial.print(" valor: ");
      Serial.println(valor_instruccion);
      delay(2000);

      break; 
    }
    
    case MOVERSE: {

      //Ejecuta el estado de avanzar o retroceder
      //(es el mismo pero con distancia negativa)
      Serial.println("Estado: Moverse (adelante o atrás)");
      delay(2000); 

      //Lógica estado siguiente
      if (digitalRead( pin_boton_Stop )) { 
        estado = ESPERA;

      }else if ( movimiento_listo ) {
        //movimiento_listo = false;
        estado = DETENERSE;
      }
      break;
    }

    case GIRAR: {

      //Ejecuta el estado de girar derecha o izquierda
      //(es el mismo pero con ángulo negativo)
      Serial.println("Estado: Girar (derecha o izquierda)");
      delay(2000); 

      //Lógica estado siguiente
      if (digitalRead( pin_boton_Stop )) { 
        estado = ESPERA;

      }else if ( movimiento_listo ) {
        //movimiento_listo = false;
        estado = DETENERSE;
      }
      break;
    }

    case DETENERSE: {

      //***Poner los motores en OFF
      Serial.println("Estado: Detenerse (siempre luego de cada movimimiento)");
      delay(1000);
      
      //Lógica estado siguiente
      if (digitalRead( pin_boton_Stop )) { 
        estado = ESPERA;
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

      Serial.print("Estado: Ciclo ->  ¿Inicia ciclo? ");
      Serial.print(instruccion == inst_CicloInicia);
      Serial.print("  Ciclos pendientes: ");
      Serial.println(cantidad_ciclos);
      delay(5000);


      //Lógica estado siguiente
      if (digitalRead( pin_boton_Stop )) { 
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
      Serial.print("Estado: Obstáculos -> ");
      Serial.println(obstaculos_activo);
      delay(4000);

      //Lógica estado siguiente
      if (digitalRead( pin_boton_Stop )) { 
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
          Serial.println("mensaje viene bien");
        
        }else if (comando == "ATFIN"){
          Serial.println("Mensaje finalizado");
          inst_final = i/5;
        
        }else if (comando == "OBINI"){
          Serial.println("Obstaculos habilitados");
          lista_instrucciones[inst_actual][0] = inst_ObstaculoInicia;
          lista_instrucciones[inst_actual][1] = 0;
          inst_actual++;

        }else if (comando == "OBFIN"){
          Serial.println("Obstaculos deshabilitados");
          lista_instrucciones[inst_actual][0] = inst_ObstaculoFin;
          lista_instrucciones[inst_actual][1] = 0;
          inst_actual++;

        }else if (comando == "CIFIN"){
          Serial.println("Ciclo finaliza");
          lista_instrucciones[inst_actual][0] = inst_CicloFin;
          lista_instrucciones[inst_actual][1] = 0;
          inst_actual++;  

        }else if (instruccion == "CI" && comando != "CIFIN"){
          Serial.print("Ciclo inicia: ");
          short valor = stoi (valor_instruccion);
          Serial.println(valor);
          lista_instrucciones[inst_actual][0] = inst_CicloInicia;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;

        }else if (instruccion == "AV"){
          Serial.print("Avanza: ");
          short valor = stoi (valor_instruccion);
          Serial.println(valor);
          lista_instrucciones[inst_actual][0] = inst_Avanzar;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;

        }else if (instruccion == "RE"){
          Serial.print("Retrocede: ");
          short valor = stoi (valor_instruccion);
          Serial.println(valor);
          lista_instrucciones[inst_actual][0] = inst_Retroceder;
          lista_instrucciones[inst_actual][1]= valor;
          inst_actual++;

        }else if (instruccion == "GI"){
          Serial.print("Gira izquierda: ");
          short valor = stoi (valor_instruccion);
          Serial.println(valor);
          lista_instrucciones[inst_actual][0] = inst_GiroIzquierdo;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;

        }else if (instruccion == "GD"){
          Serial.print("Gira derecha: ");
          short valor = stoi (valor_instruccion);
          Serial.println(valor);
          lista_instrucciones[inst_actual][0] = inst_GiroDerecho;
          lista_instrucciones[inst_actual][1] = valor;
          inst_actual++;
        }
        
  }
  inst_actual = 0; 
}
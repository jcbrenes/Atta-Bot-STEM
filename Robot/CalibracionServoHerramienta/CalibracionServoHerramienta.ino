// Proyecto Atta-Bot STEM
// Calibración manual de los límites del servo de la herramienta.
// Señal del servo: GPIO 26 (myServo, igual que CodigoESP32.ino).
//
// Abra el Monitor Serial a 115200 baudios y seleccione "Nueva línea".
// El programa inicia en 90. Pruebe un paso a la vez hasta encontrar los
// valores superior e inferior que la herramienta puede aceptar sin forzarla.
//
// Comandos:
//   r              reinicia en 90
//   +              aumenta 5 grados desde el valor actual
//   -              disminuye 5 grados desde el valor actual
//   ?              muestra esta ayuda
//
// "Herramienta" es el lápiz: el servo de GPIO 26 que CodigoESP32.ino mueve en el estado
// HERRAMIENTA (no el servo continuo de garra/grúa, GPIO 23). Los ángulos encontrados se
// guardan en el firmware principal con SET active (lápiz abajo), SET inactive (lápiz
// arriba) y SET neutral (al encender). Con el firmware principal también se pueden probar
// sin cargar este sketch: modo DEV y TEST <ángulo>.

#include <ESP32Servo.h>

const int pinServoHerramienta = 26;
const int valorInicial = 90;
const int valorMinimo = 0;
const int valorMaximo = 180;
const int pasoCalibracion = 5;

Servo servoHerramienta;
int valorActual = valorInicial;

//***************************************************************************************
// Mueve el servo a un ángulo (acotado a 0..180) e imprime el valor actual.
//
// @param nuevoValor Ángulo pedido en grados.
//***************************************************************************************
void moverServo(int nuevoValor) {
  valorActual = constrain(nuevoValor, valorMinimo, valorMaximo);
  servoHerramienta.write(valorActual);
  Serial.print("Valor actual: ");
  Serial.println(valorActual);
}

//***************************************************************************************
// Imprime la lista de comandos.
//***************************************************************************************
void imprimirAyuda() {
  Serial.println();
  Serial.println("Comandos: r (reiniciar a 90), + (subir 5), - (bajar 5), ?");
}

//***************************************************************************************
// Interpreta un comando del Monitor Serie: r, +, - o ?/ayuda.
//
// @param comando Línea recibida.
//***************************************************************************************
void procesarComando(String comando) {
  comando.trim();
  comando.toLowerCase();
  if (comando.length() == 0) return;

  if (comando == "r") {
    moverServo(valorInicial);
    return;
  }
  if (comando == "?" || comando == "ayuda") {
    imprimirAyuda();
    return;
  }

  if (comando == "+") {
    moverServo(valorActual + pasoCalibracion);
    return;
  }
  if (comando == "-") {
    moverServo(valorActual - pasoCalibracion);
    return;
  }

  Serial.println("Comando no reconocido.");
  imprimirAyuda();
}

//***************************************************************************************
// Inicia Serial y el servo (50 Hz, pulsos de 500 a 2400 us, como el firmware principal) en 90°.
//***************************************************************************************
void setup() {
  Serial.begin(115200);
  servoHerramienta.setPeriodHertz(50);
  // Mismo rango de pulsos que utiliza el firmware principal para myServo.
  servoHerramienta.attach(pinServoHerramienta, 500, 2400);
  moverServo(valorInicial);

  Serial.println("\nCalibración manual de límites del servo");
  imprimirAyuda();
}

//***************************************************************************************
// Lee una línea del Monitor Serie cuando llega y la procesa.
//***************************************************************************************
void loop() {
  if (Serial.available() > 0) {
    procesarComando(Serial.readStringUntil('\n'));
  }
}

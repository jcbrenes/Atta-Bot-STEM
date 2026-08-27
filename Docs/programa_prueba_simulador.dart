// Programa de prueba para el simulador de Atta-Bot.
// Dibuja un cuadrado de 18 cm por lado, activa el lápiz y muestra
// el efecto visual de detección de objetos durante el recorrido.

void main() {
  activarDeteccion();
  activarLapiz();

  repetir(4, () {
    avanzar(18);
    girarDerecha(90);
  });

  desactivarLapiz();
  desactivarDeteccion();
}

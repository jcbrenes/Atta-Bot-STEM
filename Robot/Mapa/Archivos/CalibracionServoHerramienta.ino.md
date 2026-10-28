---
tags: [indice]
---
# CalibracionServoHerramienta.ino

Proyecto Atta-Bot STEM
Calibración manual de los límites del servo de la herramienta.
Señal del servo: GPIO 26 (myServo, igual que CodigoESP32.ino).

Abra el Monitor Serial a 115200 baudios y seleccione "Nueva línea".
El programa inicia en 90. Pruebe un paso a la vez hasta encontrar los
valores superior e inferior que la herramienta puede aceptar sin forzarla.

Comandos:
  r              reinicia en 90
  +              aumenta 5 grados desde el valor actual
  -              disminuye 5 grados desde el valor actual
  ?              muestra esta ayuda

"Herramienta" es el lápiz: el servo de GPIO 26 que CodigoESP32.ino mueve en el estado
HERRAMIENTA (no el servo continuo de garra/grúa, GPIO 23). Los ángulos encontrados se
guardan en el firmware principal con SET active (lápiz abajo), SET inactive (lápiz
arriba) y SET neutral (al encender). Con el firmware principal también se pueden probar
sin cargar este sketch: modo DEV y TEST <ángulo>.

## Funciones
- [[CalibracionServoHerramienta.moverServo]] (línea 37)
- [[CalibracionServoHerramienta.imprimirAyuda]] (línea 47)
- [[CalibracionServoHerramienta.procesarComando]] (línea 57)
- [[CalibracionServoHerramienta.setup]] (línea 87)
- [[CalibracionServoHerramienta.loop]] (línea 101)

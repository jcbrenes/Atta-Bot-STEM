---
tags: [indice]
---
# CalibracionMotores.ino

Proyecto Atta-bot-STEM del Tecnológico de Costa Rica
Código para la calibración del PPR de los motores N20

Mide el PPR (cuentas de encoder por vuelta de rueda) de cada motor, que luego se guarda en
el firmware principal con SET rppr / SET lppr. Es un sketch aparte: se carga, se mide y se
vuelve a cargar CodigoESP32 (la NVS no se borra, la calibración guardada se conserva).

Montaje: en el eje del motor se pone el acrílico de calibración, un brazo que solo puede
girar media vuelta entre dos topes. El motor empuja el brazo contra un tope (preparación) y
después lo lleva lento hasta el otro (medición); las cuentas de esa media vuelta por 2 son el
PPR. Se cuentan los flancos de A y B (x4), igual que el firmware principal, así que el
resultado es directamente el valor para SET.

Uso: Monitor Serie a 115200, enviar "medirDerecho" o "medirIzquierdo"; el sketch hace
numMedicionesPorRealizar mediciones (descarta las de PPR <= PPRminimo, rebotes del brazo) e
imprime el promedio. "reset" detiene todo.

Es el método antiguo (útil de media vuelta). Hoy el PPR también se mide con el firmware
principal, sin cambiar de sketch: comando ENCODERS antes y después de girar la rueda a mano
varias vueltas, y la prueba del cuadrado (Calibracion_cuadrado.md) lo afina con track.

Ojo: aquí los pines del motor izquierdo están invertidos respecto a CodigoESP32.ino
(M1 = 15, M2 = 13); solo cambia el sentido de giro de la prueba, no el PPR medido.

## Funciones
- [[CalibracionMotores.rightEncoderAEvent]] (línea 104)
- [[CalibracionMotores.rightEncoderBEvent]] (línea 118)
- [[CalibracionMotores.leftEncoderAEvent]] (línea 128)
- [[CalibracionMotores.leftEncoderBEvent]] (línea 142)
- [[CalibracionMotores.setup]] (línea 166)
- [[CalibracionMotores.loop]] (línea 205)
- [[CalibracionMotores.arranque]] (línea 379)

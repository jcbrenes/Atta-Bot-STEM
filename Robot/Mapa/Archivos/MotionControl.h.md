---
tags: [indice]
---
# MotionControl.h

Controlador de movimiento V2 (controller=3): rectas y giros con encoders.

Todo está en el namespace atta y no usa nada de Arduino, así que se compila y prueba en PC
(tests/motion_control_test.cpp, tests/turn_control_test.cpp). MotionRuntime.h es la capa
que lo conecta al hardware: lee los encoders, llama a Controller cada vuelta de loop() y
aplica el PWM que calcula.

Cómo se mueve el robot:
1. Controller.begin convierte la orden (mm o grados) en una distancia objetivo por rueda.
2. Cada 25 ms Controller.update mide distancia y velocidad de cada rueda (Controller.sample),
   calcula la velocidad de referencia con rampas de aceleración y frenado
   (Controller.reference), la corrige para que las dos ruedas avancen parejas (sync) y
   obtiene el PWM de cada rueda con un PI por rueda (wheelPWM).
3. Cada rueda se detiene al llegar a su distancia; en los giros, además, se espera a que
   las ruedas queden quietas (asentamiento) para informar si el giro se pasó.
4. Si algo no cuadra (rueda trabada, tiempo agotado, configuración inválida) se detiene y
   deja un Fault que MotionRuntime.h informa por Serial.

Unidades: mm, mm/s, mm/s², ms; PWM de 0 a 255. Guía completa: Control_movimiento_V2.md.

## Funciones
- `clamp` (línea 32)
- [[faultName]] (línea 128)
- `within` (línea 142)
- [[validTurnConfig]] (línea 152)
- [[validWheel]] (línea 168)
- [[validConfig]] (línea 188)
- [[migrateGains]] (línea 209)
- [[wheelPWM]] (línea 249)
- [[Controller.rightReverse]] (línea 296)
- [[Controller.leftReverse]] (línea 302)
- [[Controller.stop]] (línea 307)
- [[Controller.fail]] (línea 319)
- [[Controller.clear]] (línea 323)
- [[Controller.begin]] (línea 345)
- [[Controller.sample]] (línea 388)
- [[Controller.update]] (línea 419)
- [[Controller.reference]] (línea 478)

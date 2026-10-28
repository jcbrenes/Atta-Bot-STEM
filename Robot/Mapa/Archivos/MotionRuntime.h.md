---
tags: [indice]
---
# MotionRuntime.h

Capa de hardware del movimiento y consola de calibración por Serial.

Conecta el controlador de MotionControl.h con el robot: lee los encoders, escribe el PWM del
puente H, ejecuta las órdenes MOVE/TURN de la máquina de estados, informa fallos y
telemetría, y atiende el modo desarrollador (DEV) del Monitor Serie con el que se calibra.

Se incluye dentro de CodigoESP32.ino después de los pines y la máquina de estados, porque
usa sus variables globales (estado, pines de motores, banderas del programa BLE).
tests/runtime_test.cpp lo compila en PC con stubs de Arduino.

Comandos de la consola: ver processSerialCommand y Guia_parametros_SET.md.

## Funciones
- `readEncoderCounts` (línea 37)
- [[applyMotorOutputs]] (línea 55)
- [[attachMotorPWM]] (línea 76)
- [[stopMotion]] (línea 95)
- [[calibrationIdle]] (línea 110)
- [[resetProgramFlow]] (línea 121)
- [[requestMotionStop]] (línea 136)
- [[reportMotionFault]] (línea 160)
- [[emitTelemetry]] (línea 186)
- [[runMotion]] (línea 219)
- [[advanceDesiredDistance]] (línea 255)
- [[turnDesiredAngle]] (línea 263)
- [[updateMotorTest]] (línea 273)
- [[startMotorTest]] (línea 306)
- [[printDeveloperHelp]] (línea 333)
- [[processSerialCommand]] (línea 358)
- [[readDeveloperSerial]] (línea 418)

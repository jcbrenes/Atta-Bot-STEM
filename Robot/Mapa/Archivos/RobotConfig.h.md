---
tags: [indice]
---
# RobotConfig.h

Configuración persistente del Atta: lee, valida y guarda en la NVS del ESP32
(namespace "Atta-Creds") todo lo que se calibra robot por robot.

Hay cuatro grupos de valores:
- nombre Bluetooth ("deviceName") y frecuencia PWM de motores ("pwmHz");
- ángulos de los servos, una clave entera por campo (servoFields);
- perfil de movimiento "motionV2": el struct atta::MotionConfig completo, guardado como
  un solo bloque binario (PPR, radios, ganancias, start/hold/ff, track, velocidades...);
- perfil de giro "turnV1": el struct atta::TurnConfig (rampas y aproximación de los giros),
  separado para no cambiar el formato binario de motionV2 ya instalado en los robots.

Cada campo que se puede cambiar con "SET <campo> <valor>" está en una de las tablas
servoFields, turnFields o motionFields (nombre del campo → variable en RAM), más los casos
especiales device, pwmhz y los alias kp/ki/kd de saveDeveloperValue. Para agregar un
parámetro nuevo basta con sumarlo a la tabla y al struct; SHOW y SET lo toman solos.
Qué significa cada campo y cuándo tocarlo: Guia_parametros_SET.md.

Se compila tanto en el ESP32 como en PC (tests/config_test.cpp usa un Preferences falso
de tests/stubs), por eso no depende de nada del sketch.

## Funciones
- `parseFloatValue` (línea 98)
- [[writeMotionProfile]] (línea 115)
- [[writeTurnProfile]] (línea 133)
- [[loadConfig]] (línea 157)
- [[printDeveloperConfig]] (línea 221)
- [[verifyConfig]] (línea 242)
- [[saveDeveloperValue]] (línea 276)

---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 347
---
# setup

> Inicializa el robot: configuración persistente, periféricos, PWM y servidor BLE.
>
> Orden de arranque:
> 1. Abre el puerto Serial y llama a loadConfig(), que lee (o crea una vez) de NVS el
>    nombre del dispositivo, los ángulos de los servos, la frecuencia PWM y los perfiles
>    de movimiento/giro. Si la configuración no es válida, configReady queda en false y
>    el movimiento se bloquea.
> 2. Apaga el LED interno y prepara el servo del lápiz (50 Hz, neutro) y el servo 360
>    del set de herramientas.
> 3. Configura como entrada los pines de encoders, sensores infrarrojos, trackers y
>    batería baja; como salida los de motores y LED RGB externo.
> 4. Reserva los temporizadores de los servos antes de llamar a attachMotorPWM() y deja
>    los motores detenidos con stopMotion(); si el PWM no se aplicó, lo avisa por Serial.
> 5. Engancha las interrupciones de los cuatro canales de encoder.
> 6. Inicia el BLE nativo con el nombre en deviceName, crea el servidor, el servicio y la
>    característica con los UUID acordados con la App, registra los callbacks y empieza a
>    anunciarse para que la tablet pueda conectarse.
> 7. Guarda en tiempoDeEncendidoDeLed el instante inicial del parpadeo del LED.

**Archivo:** [[CodigoESP32.ino]] · línea 347

```cpp
void setup()
```

## Llama a
- [[attachMotorPWM]]
- [[leftUpdateEncoder]]
- [[loadConfig]]
- [[rightUpdateEncoder]]
- [[stopMotion]]
- `ledInterno`

## Emite
- [[Mensaje ERROR PWM]]

## Campos SET que usa
- [[SET device]]
- [[SET neutral]]
- [[SET stop]]

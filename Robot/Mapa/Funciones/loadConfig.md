---
tags: [funcion]
archivo: RobotConfig.h
linea: 157
---
# loadConfig

> Carga la configuración desde NVS al arrancar; crea una sola vez lo que falte.
>
> Un Atta recién cargado no tiene claves: se guardan los valores por defecto del firmware
> (nombre Atta-V-02, ángulos, 20 kHz). Si no existe motionV2 pero sí las claves del firmware
> anterior (Rppr, Lppr, kp, ki, kd), se migra: el PPR se conserva y las ganancias se
> convierten a segundos con atta::migrateGains. Si no existe turnV1 se crea con los valores
> por defecto de atta::TurnConfig, sin tocar motionV2.
>
> Un perfil guardado pero inválido o de otro tamaño NO se reemplaza por valores por defecto:
> se deja como está y configReady queda en false, lo que bloquea el movimiento hasta
> corregirlo con SET (así no se pierde en silencio la calibración de un robot).
>
> Deja configReady en true solo si todo quedó cargado y válido, y lo informa por Serial.

**Archivo:** [[RobotConfig.h]] · línea 157

```cpp
void loadConfig()
```

## Llama a
- [[writeMotionProfile]]
- [[writeTurnProfile]]

## La llaman
- [[setup]]

## Emite
- [[Mensaje ERROR CONFIG]]

## Campos SET que usa
- [[SET device]]
- [[SET pwmhz]]

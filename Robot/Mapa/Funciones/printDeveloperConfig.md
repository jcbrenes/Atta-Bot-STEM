---
tags: [funcion]
archivo: RobotConfig.h
linea: 221
---
# printDeveloperConfig

> Responde al comando SHOW: imprime toda la configuración en RAM como líneas SET.
>
> La salida se puede guardar como respaldo y volver a pegar en el Monitor Serie para
> restaurar el robot (cargar_firmware_attas.sh guarda una en Respaldos_SHOW/). La primera
> línea dice las versiones de los perfiles (schema, turn_schema, controller) y la frecuencia
> PWM que el periférico aplicó de verdad. Muestra la RAM, no la NVS: para comparar con lo
> guardado está VERIFY.

**Archivo:** [[RobotConfig.h]] · línea 221

```cpp
void printDeveloperConfig()
```

## La llaman
- [[processSerialCommand]]

## Emite
- [[Mensaje CONFIG]]

## Campos SET que usa
- [[SET device]]
- [[SET pwmhz]]

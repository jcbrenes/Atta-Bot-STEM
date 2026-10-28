---
tags: [funcion]
archivo: RobotConfig.h
linea: 276
---
# saveDeveloperValue

> Atiende "SET <campo> <valor>": valida, guarda en NVS y verifica un campo.
>
> Busca el campo en este orden: device (texto, máx. 31 caracteres, sin comas), servoFields
> (entero 0..180), pwmhz (entero motorPwmMinHz..motorPwmMaxHz), turnFields, motionFields y
> los alias kp/ki/kd, que escriben la misma ganancia en las dos ruedas. Para los campos de
> perfil se cambia la RAM, se reescribe el perfil entero y, si no pasa la validación o falla
> la escritura, la RAM vuelve al valor anterior: un SET inválido no deja nada a medias.
>
> device y pwmhz se guardan pero recién se aplican al reiniciar (el nombre BLE y el PWM se
> configuran en setup). Al final recalcula configReady con verifyConfig.
>
> @param field Nombre del campo, sin importar mayúsculas.
> @param value Texto del valor.
>
> @return true si el valor se guardó y toda la configuración quedó verificada.

**Archivo:** [[RobotConfig.h]] · línea 276

```cpp
bool saveDeveloperValue(String field, String value)
```

## Llama a
- [[verifyConfig]]
- [[writeMotionProfile]]
- [[writeTurnProfile]]
- `parseFloatValue`

## La llaman
- [[processSerialCommand]]

## Campos SET que usa
- [[SET device]]
- [[SET kd]]
- [[SET ki]]
- [[SET kp]]
- [[SET pwmhz]]

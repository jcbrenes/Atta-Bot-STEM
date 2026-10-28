---
tags: [funcion]
archivo: MotionRuntime.h
linea: 273
---
# updateMotorTest

> Avanza la prueba MOTOR en curso; se llama en cada vuelta de loop().
>
> Mide las ruedas cada 25 ms (para que la telemetría muestre la velocidad) sin ningún control:
> el PWM es fijo. Al cumplirse la duración imprime MOTOR_DONE con las cuentas y hace un STOP
> completo, para que la rueda se detenga antes de otra prueba o de invertir el sentido. Si la
> rueda probada no cuenta pulsos en stallMs, la declara trabada.

**Archivo:** [[MotionRuntime.h]] · línea 273

```cpp
void updateMotorTest()
```

## Llama a
- [[Controller.fail]]
- [[reportMotionFault]]
- [[requestMotionStop]]
- `readEncoderCounts`

## La llaman
- [[loop]]

## Emite
- [[Mensaje MOTOR_DONE]]

## Campos SET que usa
- [[SET filterms]]
- [[SET stallms]]

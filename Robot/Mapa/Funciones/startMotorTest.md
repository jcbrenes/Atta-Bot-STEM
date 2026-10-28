---
tags: [funcion]
archivo: MotionRuntime.h
linea: 306
---
# startMotorTest

> Arranca "MOTOR <R|L> <F|R> <PWM> <ms>": una rueda a PWM fijo, sin controlador.
>
> Sirve para calibrar la zona muerta: el menor PWM con el que la rueda arranca es el valor de
> SET ..start de esa rueda y sentido (ver DriveCalibration). Imprime MOTOR_BEGIN con las
> cuentas iniciales; restando las de MOTOR_DONE se obtienen las cuentas recorridas.
>
> @param command Línea en mayúsculas. Rueda R o L, sentido F (adelante) o R (atrás), PWM
> 0..maxPWM y duración 100..3000 ms.
>
> @return true si el formato y los rangos son válidos y la prueba arrancó.

**Archivo:** [[MotionRuntime.h]] · línea 306

```cpp
bool startMotorTest(const String& command)
```

## Llama a
- [[Controller.clear]]
- [[applyMotorOutputs]]
- `readEncoderCounts`

## La llaman
- [[processSerialCommand]]

## Emite
- [[Mensaje MOTOR_BEGIN]]

## Campos SET que usa
- [[SET maxpwm]]

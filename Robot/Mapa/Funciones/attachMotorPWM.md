---
tags: [funcion]
archivo: MotionRuntime.h
linea: 76
---
# attachMotorPWM

> Configura el PWM de los 4 pines de motores a motorPwmHz y 8 bits, y lo comprueba.
>
> Con la misma frecuencia y resolución el core asigna a los 4 pines un único temporizador
> LEDC, distinto del de los servos (50 Hz); por eso setup llama a esto después de reservar
> los servos. Lee la frecuencia real del temporizador (ledcTimerHz) y falla si se aleja más
> de 2 % de la pedida o si los pines quedaron en temporizadores distintos. Deja la frecuencia
> real en motorPwmActiveHz (la muestra SHOW).
>
> @return true si los 4 pines quedaron con la frecuencia pedida.

**Archivo:** [[MotionRuntime.h]] · línea 76

```cpp
bool attachMotorPWM()
```

## Llama a
- [[ledcTimerHz]]

## La llaman
- [[setup]]

## Campos SET que usa
- [[SET pwmhz]]

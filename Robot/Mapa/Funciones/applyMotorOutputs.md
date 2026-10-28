---
tags: [funcion]
archivo: MotionRuntime.h
linea: 55
---
# applyMotorOutputs

> Escribe el PWM y el sentido de las dos ruedas en el puente H.
>
> Cada motor tiene dos pines (M1 adelante, M2 atrás): primero se pone en 0 el pin del sentido
> contrario y después se escribe el PWM en el del sentido pedido, así nunca quedan los dos
> activos. Siempre se escriben las dos ruedas. Guarda lo aplicado para la telemetría.
>
> @param rightReverse true si la rueda derecha va hacia atrás.
> @param leftReverse true si la rueda izquierda va hacia atrás.
> @param r PWM derecho (se limita a 0..255).
> @param l PWM izquierdo (se limita a 0..255).

**Archivo:** [[MotionRuntime.h]] · línea 55

```cpp
void applyMotorOutputs(bool rightReverse, bool leftReverse, int r, int l)
```

## La llaman
- [[runMotion]]
- [[startMotorTest]]
- [[stopMotion]]

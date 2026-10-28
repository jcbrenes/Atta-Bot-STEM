---
tags: [funcion]
archivo: MotionRuntime.h
linea: 95
---
# stopMotion

> Detiene los motores ya: corta la maniobra, cancela la prueba MOTOR y pone PWM 0.
>
> No cambia el estado del programa; para un STOP completo está requestMotionStop.

**Archivo:** [[MotionRuntime.h]] · línea 95

```cpp
void stopMotion()
```

## Llama a
- [[Controller.stop]]
- [[applyMotorOutputs]]

## La llaman
- [[loop]]
- [[reportMotionFault]]
- [[requestMotionStop]]
- [[setup]]

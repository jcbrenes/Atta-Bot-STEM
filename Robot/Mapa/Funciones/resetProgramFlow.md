---
tags: [funcion]
archivo: MotionRuntime.h
linea: 121
---
# resetProgramFlow

> Reinicia el estado de flujo de un programa: ciclos, ramas IF/WHILE y detección de obstáculos.
>
> Un programa interrumpido (STOP u obstáculo) no llega a CIFIN/OBFIN; sin este reinicio el
> siguiente programa heredaría la detección activa y el contador de ciclos.

**Archivo:** [[MotionRuntime.h]] · línea 121

```cpp
void resetProgramFlow()
```

## La llaman
- [[loop]]
- [[requestMotionStop]]

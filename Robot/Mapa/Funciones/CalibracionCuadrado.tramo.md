---
tags: [funcion]
archivo: CalibracionCuadrado.h
linea: 26
---
# CalibracionCuadrado.tramo

> Avanza una pose con el recorrido real de cada rueda (modelo de dos ruedas, arco de círculo).
>
> @param p Pose a actualizar (mm y radianes, rumbo antihorario positivo).
> @param dR Recorrido real de la rueda derecha, mm con signo.
> @param dL Recorrido real de la rueda izquierda, mm con signo.
> @param via Separación real entre ruedas, mm.

**Archivo:** [[CalibracionCuadrado.h]] · línea 26

```cpp
inline void tramo(Pose& p, double dR, double dL, double via)
```

## La llaman
- [[CalibracionCuadrado.cuadrado]]

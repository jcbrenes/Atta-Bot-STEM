---
tags: [funcion]
archivo: CalibracionCuadrado.h
linea: 142
---
# CalibracionCuadrado.corregir

> Convierte los errores estimados en los valores nuevos de SET rppr, lppr y track.
>
> Si una rueda recorre kR mm reales por cada mm que cree el firmware, su PPR nuevo es
> rppr/kR (más cuentas por mm); el track nuevo es la vía efectiva.
>
> @param e Errores estimados por estimar.
> @param rppr PPR derecho actual.
> @param lppr PPR izquierdo actual.
>
> @return Valores corregidos.

**Archivo:** [[CalibracionCuadrado.h]] · línea 142

```cpp
inline Correccion corregir(const Errores& e, double rppr, double lppr)
```

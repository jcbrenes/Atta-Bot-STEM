---
tags: [metodo]
archivo: MotionControl.h
linea: 388
---
# Controller.sample

> Mide una rueda: distancia desde el origen y velocidad filtrada.
>
> La diferencia de cuentas se resta en módulo 2^32, así que funciona aunque el contador
> desborde. La velocidad pasa por un filtro paso bajo de primer orden con constante filterMs.
> Si la rueda contó pulsos (o no tiene PWM) se actualiza lastProgress, que usa la detección de
> traba.
>
> @param s Estado de la rueda a actualizar.
> @param c Calibración de la rueda (ppr y radius → mm por cuenta).
> @param ticks Cuenta actual del encoder.
> @param now millis() actual.
> @param dt Tiempo desde la muestra anterior, s.
> @param filterMs Constante del filtro de velocidad, ms.

**Archivo:** [[MotionControl.h]] · línea 388

```cpp
static void sample(WheelState& s, const WheelConfig& c, uint32_t ticks, uint32_t now, float dt, float filterMs)
```

## La llaman
- [[Controller.update]]

## Campos SET que usa
- [[SET lppr]]
- [[SET lradius]]
- [[SET rppr]]
- [[SET rradius]]
- [[SET speed]]

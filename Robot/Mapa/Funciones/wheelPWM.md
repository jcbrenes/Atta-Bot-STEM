---
tags: [funcion]
archivo: MotionControl.h
linea: 249
---
# wheelPWM

> Calcula el PWM de una rueda para seguir su velocidad de referencia (PI con extras).
>
> PWM = feedforward·referencia + kp·error + integral + kd·derivada, donde error es
> referencia − velocidad medida y la derivada se toma de la medición (no salta al cambiar la
> referencia). El resultado se limita entre un piso y maxPWM: si la rueda va lenta, el piso es
> el PWM de arranque (start) o de sostén (sustain) para vencer la zona muerta del motor; si va
> rápida, 0. Anti-windup: la integral solo se actualiza si no empuja más hacia una saturación.
> Con referencia 0 devuelve 0 y vacía la integral.
>
> @param c Calibración de la rueda (ganancias).
> @param d Zona muerta del sentido en que gira la rueda ahora.
> @param s Estado de la rueda; actualiza integral, previousSpeed y saturated.
> @param dt Período de control en s.
> @param maxPWM Tope de PWM.
> @param starting true durante la ventana de arranque si la rueda aún no se movió.
>
> @return PWM entre 0 y maxPWM.

**Archivo:** [[MotionControl.h]] · línea 249

```cpp
inline int wheelPWM(const WheelConfig& c, const DriveCalibration& d, WheelState& s, float dt, float maxPWM, bool starting)
```

## Llama a
- `clamp`

## La llaman
- [[Controller.update]]

## Campos SET que usa
- [[SET kd]]
- [[SET ki]]
- [[SET kp]]
- [[SET lfff]]
- [[SET lfhold]]
- [[SET lfstart]]
- [[SET lkd]]
- [[SET lki]]
- [[SET lkp]]
- [[SET lrff]]
- [[SET lrhold]]
- [[SET lrstart]]
- [[SET rfff]]
- [[SET rfhold]]
- [[SET rfstart]]
- [[SET rkd]]
- [[SET rki]]
- [[SET rkp]]
- [[SET rrff]]
- [[SET rrhold]]
- [[SET rrstart]]
- [[SET speed]]

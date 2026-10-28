---
tags: [funcion]
archivo: MotionControl.h
linea: 168
---
# validWheel

> Valida la calibración de una rueda.
>
> Rangos: ppr 1..100000, radius 5..100 mm, kp y ki 0..100, kd 0..10; por sentido, start
> 0..maxPWM, sustain 0..start y feedforward 0..10.
>
> @param w Calibración de la rueda.
> @param maxPWM Tope de PWM del perfil, para acotar start.
>
> @return true si todos los campos están en rango.

**Archivo:** [[MotionControl.h]] · línea 168

```cpp
inline bool validWheel(const WheelConfig& w, float maxPWM)
```

## Llama a
- `within`

## La llaman
- [[validConfig]]

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
- [[SET lppr]]
- [[SET lradius]]
- [[SET lrff]]
- [[SET lrhold]]
- [[SET lrstart]]
- [[SET rfff]]
- [[SET rfhold]]
- [[SET rfstart]]
- [[SET rkd]]
- [[SET rki]]
- [[SET rkp]]
- [[SET rppr]]
- [[SET rradius]]
- [[SET rrff]]
- [[SET rrhold]]
- [[SET rrstart]]

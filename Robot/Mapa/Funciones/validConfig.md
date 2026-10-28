---
tags: [funcion]
archivo: MotionControl.h
linea: 188
---
# validConfig

> Valida el perfil de movimiento completo antes de usarlo o guardarlo.
>
> Rangos: maxPWM 1..255, track 40..400 mm, speed y turnSpeed 10..300 mm/s, rampas
> 10..1000 mm/s², syncGain 0..10, tolerance 0.1..5 mm, filterMs 0..200, stallMs 300..5000,
> startMs 0..500 y menor que stallMs; más validWheel para cada rueda.
>
> @param c Perfil de movimiento.
>
> @return true si se puede usar y guardar.

**Archivo:** [[MotionControl.h]] · línea 188

```cpp
inline bool validConfig(const MotionConfig& c)
```

## Llama a
- [[validWheel]]
- `within`

## La llaman
- [[Controller.begin]]

## Campos SET que usa
- [[SET accel]]
- [[SET decel]]
- [[SET filterms]]
- [[SET maxpwm]]
- [[SET speed]]
- [[SET stallms]]
- [[SET startms]]
- [[SET sync]]
- [[SET tolerance]]
- [[SET track]]
- [[SET turnaccel]]
- [[SET turndecel]]
- [[SET turnspeed]]

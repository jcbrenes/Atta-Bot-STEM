---
tags: [funcion]
archivo: MotionControl.h
linea: 152
---
# validTurnConfig

> Valida el perfil de giro: version 1 y cada campo dentro de su rango.
>
> Rangos: rampas 10..1000 mm/s², approachSpeed 5..100 mm/s, approachDistance 1..100 mm.
>
> @param c Perfil de giro.
>
> @return true si se puede usar y guardar.

**Archivo:** [[MotionControl.h]] · línea 152

```cpp
inline bool validTurnConfig(const TurnConfig& c)
```

## Llama a
- `within`

## La llaman
- [[Controller.begin]]

## Campos SET que usa
- [[SET accel]]
- [[SET decel]]
- [[SET turnaccel]]
- [[SET turnapproach]]
- [[SET turndecel]]
- [[SET turnzone]]

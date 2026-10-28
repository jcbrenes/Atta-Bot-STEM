---
tags: [metodo]
archivo: MotionControl.h
linea: 478
---
# Controller.reference

> Calcula la velocidad de referencia de una rueda: perfil trapezoidal con frenado.
>
> La velocidad pedida se limita por la de frenado sqrt(2·decel·restante), para poder parar
> justo en el objetivo, y en los giros además por la curva de aproximación: baja hasta
> approachSpeed al entrar a los últimos approachDistance mm y dentro de ellos sigue bajando
> con la raíz de lo que falta. El cambio respecto a la referencia anterior se limita a
> accel·dt al subir y decel·dt al bajar. Rectas: rampas de MotionConfig; giros: de TurnConfig.
>
> @param s Estado de la rueda; escribe s.reference.
> @param c Perfil de movimiento.
> @param requested Velocidad pedida para esta rueda (crucero ± corrección de sync), mm/s.

**Archivo:** [[MotionControl.h]] · línea 478

```cpp
void reference(WheelState& s, const MotionConfig& c, float requested)
```

## Llama a
- `clamp`

## La llaman
- [[Controller.update]]

## Campos SET que usa
- [[SET accel]]
- [[SET decel]]
- [[SET turnaccel]]
- [[SET turnapproach]]
- [[SET turndecel]]
- [[SET turnzone]]

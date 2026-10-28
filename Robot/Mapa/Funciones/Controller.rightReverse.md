---
tags: [metodo]
archivo: MotionControl.h
linea: 296
---
# Controller.rightReverse

> Sentido físico de la rueda derecha: en los giros va al revés que la izquierda.
>
> Giro positivo (TURN 90) = derecha atrás e izquierda adelante: el robot gira a la derecha.
>
> @return true si la rueda derecha debe ir hacia atrás.

**Archivo:** [[MotionControl.h]] · línea 296

```cpp
bool rightReverse() const
```

## La llaman
- [[Controller.update]]
- [[runMotion]]

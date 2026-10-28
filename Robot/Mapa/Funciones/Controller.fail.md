---
tags: [metodo]
archivo: MotionControl.h
linea: 319
---
# Controller.fail

> Aborta la maniobra dejando registrado el motivo.
>
> @param f Fallo que se informará.

**Archivo:** [[MotionControl.h]] · línea 319

```cpp
void fail(Fault f)
```

## Llama a
- [[Controller.stop]]

## La llaman
- [[Controller.begin]]
- [[Controller.update]]
- [[runMotion]]
- [[updateMotorTest]]

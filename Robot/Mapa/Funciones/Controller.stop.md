---
tags: [metodo]
archivo: MotionControl.h
linea: 307
---
# Controller.stop

> Termina la maniobra: PWM, referencias e integrales a cero. No borra el fallo.

**Archivo:** [[MotionControl.h]] · línea 307

```cpp
void stop()
```

## La llaman
- [[Controller.begin]]
- [[Controller.clear]]
- [[Controller.fail]]
- [[Controller.update]]
- [[stopMotion]]

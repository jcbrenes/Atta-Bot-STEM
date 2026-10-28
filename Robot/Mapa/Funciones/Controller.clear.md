---
tags: [metodo]
archivo: MotionControl.h
linea: 323
---
# Controller.clear

> Detiene y borra el fallo; lo usa el comando CLEAR y el reintento tras un fallo recuperable.

**Archivo:** [[MotionControl.h]] · línea 323

```cpp
void clear()
```

## Llama a
- [[Controller.stop]]

## La llaman
- [[processSerialCommand]]
- [[reportMotionFault]]
- [[startMotorTest]]

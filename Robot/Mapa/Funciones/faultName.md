---
tags: [funcion]
archivo: MotionControl.h
linea: 128
---
# faultName

> Nombre del fallo tal como sale en los mensajes FAULT, TURN_RESULT y la telemetría.
>
> @param f Fallo.
>
> @return Texto fijo en mayúsculas ("RIGHT_STALL", "CONTROL_LATE", ...).

**Archivo:** [[MotionControl.h]] · línea 128

```cpp
inline const char* faultName(Fault f)
```

## La llaman
- [[auditar_giros.main]]

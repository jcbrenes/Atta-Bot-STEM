---
tags: [funcion]
archivo: MotionControl.h
linea: 209
---
# migrateGains

> Convierte las ganancias del firmware anterior a V2 (ganancias en segundos).
>
> El firmware viejo integraba y derivaba por muestra con un período de 0.01 s; V2 usa segundos
> con un período nominal de 0.025 s. kp no cambia, ki se multiplica por 0.4 y kd por 0.025.
> Es una conversión de unidades, no garantiza la misma respuesta: hay que validar en el robot.
>
> @param w Rueda cuyas ganancias se escriben.
> @param kp Ganancia proporcional anterior.
> @param ki Ganancia integral anterior.
> @param kd Ganancia derivativa anterior.

**Archivo:** [[MotionControl.h]] · línea 209

```cpp
inline void migrateGains(WheelConfig& w, float kp, float ki, float kd)
```

## Campos SET que usa
- [[SET kd]]
- [[SET ki]]
- [[SET kp]]
- [[SET lkd]]
- [[SET lki]]
- [[SET lkp]]
- [[SET rkd]]
- [[SET rki]]
- [[SET rkp]]

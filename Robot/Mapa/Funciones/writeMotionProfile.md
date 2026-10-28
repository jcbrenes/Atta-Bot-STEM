---
tags: [funcion]
archivo: RobotConfig.h
linea: 115
---
# writeMotionProfile

> Guarda el perfil de movimiento completo en la clave "motionV2" y lo relee para verificarlo.
>
> El namespace NVS lo abre el llamador. Una sola escritura del bloque entero evita que un
> corte de alimentación deje combinadas ganancias de dos calibraciones distintas. No escribe
> nada si el perfil no pasa atta::validConfig.
>
> @param candidate Perfil a guardar.
>
> @return true si quedó guardado y lo leído coincide byte por byte.

**Archivo:** [[RobotConfig.h]] · línea 115

```cpp
bool writeMotionProfile(const atta::MotionConfig& candidate)
```

## La llaman
- [[loadConfig]]
- [[saveDeveloperValue]]

---
tags: [funcion]
archivo: RobotConfig.h
linea: 133
---
# writeTurnProfile

> Guarda el perfil de giro en la clave "turnV1" y lo relee para verificarlo.
>
> Igual que writeMotionProfile, pero para atta::TurnConfig. El namespace lo abre el llamador.
>
> @param candidate Perfil de giro a guardar.
>
> @return true si quedó guardado y lo leído coincide byte por byte.

**Archivo:** [[RobotConfig.h]] · línea 133

```cpp
bool writeTurnProfile(const atta::TurnConfig& candidate)
```

## La llaman
- [[loadConfig]]
- [[saveDeveloperValue]]

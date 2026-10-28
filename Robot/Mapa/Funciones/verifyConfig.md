---
tags: [funcion]
archivo: RobotConfig.h
linea: 242
---
# verifyConfig

> Responde a VERIFY: compara la configuración en RAM con la guardada en NVS.
>
> Revisa nombre, servos, pwmHz y los dos perfiles binarios byte por byte, y que ambos
> perfiles sigan dentro de rango. También la usa saveDeveloperValue después de cada SET para
> detectar una escritura que falló a medias.
>
> @return true si RAM y NVS coinciden y la configuración es válida.

**Archivo:** [[RobotConfig.h]] · línea 242

```cpp
bool verifyConfig()
```

## La llaman
- [[processSerialCommand]]
- [[saveDeveloperValue]]

## Campos SET que usa
- [[SET device]]
- [[SET pwmhz]]

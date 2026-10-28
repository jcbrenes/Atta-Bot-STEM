---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 321
---
# leftUpdateEncoder

> ISR del encoder izquierdo: suma un pulso por cada flanco de sus canales A y B.
>
> Igual que el derecho, usa encoderMux para que el contador compartido no se lea a medias.

**Archivo:** [[CodigoESP32.ino]] · línea 321

```cpp
void ARDUINO_ISR_ATTR leftUpdateEncoder()
```

## La llaman
- [[setup]]

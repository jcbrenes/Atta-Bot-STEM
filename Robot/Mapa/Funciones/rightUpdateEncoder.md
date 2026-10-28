---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 311
---
# rightUpdateEncoder

> ISR del encoder derecho: suma un pulso por cada flanco de sus canales A y B.
>
> Corre en contexto de interrupción, por eso protege el contador con encoderMux. El
> controlador de movimiento lo lee de forma coherente con readEncoderCounts().

**Archivo:** [[CodigoESP32.ino]] · línea 311

```cpp
void ARDUINO_ISR_ATTR rightUpdateEncoder()
```

## La llaman
- [[setup]]

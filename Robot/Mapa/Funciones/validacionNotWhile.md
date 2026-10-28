---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 979
---
# validacionNotWhile

> Igual que validacionWhile pero para un WHILE NOT: repite mientras NO se cumpla la condición.
>
> Guarda el índice de retorno y sube el anidamiento cuando la condición es falsa; en caso
> contrario activa ignorarHastaWHILEFIN y el nivel de salto.
>
> @param condicionSensorIzquierdo true si el tracker izquierdo cumple la condición pedida.
> @param condicionSensorDerecho true si el tracker derecho cumple la condición pedida.

**Archivo:** [[CodigoESP32.ino]] · línea 979

```cpp
void validacionNotWhile(bool condicionSensorIzquierdo, bool condicionSensorDerecho)
```

## La llaman
- [[bifurcacionWHILE]]

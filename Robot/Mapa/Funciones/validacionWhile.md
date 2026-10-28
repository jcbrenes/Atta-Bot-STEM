---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 959
---
# validacionWhile

> Decide si se entra al cuerpo del WHILE o se salta hasta WHILEFIN.
>
> Si la condición se cumple, guarda en indicesWhile[anidamientoWhile] el puntero a la
> instrucción del WHILE y sube el anidamiento para poder repetir el cuerpo. Si no, activa
> ignorarHastaWHILEFIN y guarda el nivel actual para saltar solo este ciclo.
>
> @param condicionSensorIzquierdo true si el tracker izquierdo cumple la condición pedida.
> @param condicionSensorDerecho true si el tracker derecho cumple la condición pedida.

**Archivo:** [[CodigoESP32.ino]] · línea 959

```cpp
void validacionWhile(bool condicionSensorIzquierdo, bool condicionSensorDerecho)
```

## La llaman
- [[bifurcacionWHILE]]

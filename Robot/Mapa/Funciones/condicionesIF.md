---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 876
---
# condicionesIF

> Traduce el valor de la instrucción IF/ELSE a las condiciones de los trackers.
>
> valor_instruccion codifica qué combinación de sensores sobre negro/blanco se pidió, o
> sensorNoImporta para un ELSE sin condición. Según el caso llama a validacionIf() con las
> lecturas (o sus negaciones) ya capturadas en loop().

**Archivo:** [[CodigoESP32.ino]] · línea 876

```cpp
void condicionesIF()
```

## Llama a
- [[validacionIf]]

## La llaman
- [[bifurcacionIF]]

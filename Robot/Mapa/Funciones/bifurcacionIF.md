---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 917
---
# bifurcacionIF

> Ejecuta la lógica de flujo de una instrucción IF, ELSE o IFFIN.
>
> Al IFINICIA incrementa anidamientoIF y evalúa la condición. En ELSE, si la rama
> anterior ya se ejecutó, activa ignorarHastaIFFIN para saltar el resto; si no, evalúa la
> condición del ELSE. En IFFIN limpia la marca de la rama y baja el anidamiento. Se apoya
> en las banderas globales que luego consume LEE_MEMORIA.

**Archivo:** [[CodigoESP32.ino]] · línea 917

```cpp
void bifurcacionIF()
```

## Llama a
- [[condicionesIF]]

## La llaman
- [[loop]]

---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 998
---
# bifurcacionWHILE

> Ejecuta la lógica de flujo de WHILE y WHILE NOT.
>
> En WHILEFIN baja el anidamiento y devuelve inst_actual al índice guardado al entrar al
> ciclo, de modo que LEE_MEMORIA vuelva a evaluar la condición. En el inicio, decodifica
> valor_instruccion entre "mientras" y "mientras no" y las combinaciones de trackers, y
> llama a validacionWhile() o validacionNotWhile().

**Archivo:** [[CodigoESP32.ino]] · línea 998

```cpp
void bifurcacionWHILE()
```

## Llama a
- [[validacionNotWhile]]
- [[validacionWhile]]

## La llaman
- [[loop]]

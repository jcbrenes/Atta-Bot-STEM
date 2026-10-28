---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 1077
---
# accionarHerramientaSet

> Acciona la garra o la grúa del set de herramientas según valor_instruccion.
>
> Para cada acción (abrir/cerrar garra, subir/bajar grúa) elige velocidad y tiempo y llama
> a accionarMotorHerramientaSet(). Antes comprueba posicionHerramienta: si la herramienta
> ya está en la posición pedida no la vuelve a mover. Tras moverse actualiza esa global,
> que arranca en 0 porque la posición inicial es desconocida.

**Archivo:** [[CodigoESP32.ino]] · línea 1077

```cpp
void accionarHerramientaSet()
```

## Llama a
- [[accionarMotorHerramientaSet]]

## La llaman
- [[loop]]

## Campos SET que usa
- [[SET forward]]
- [[SET reverse]]
- [[SET stop]]

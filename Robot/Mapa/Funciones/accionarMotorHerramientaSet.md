---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 1061
---
# accionarMotorHerramientaSet

> Mueve el servo 360 del set de herramientas durante el tiempo de acción configurado.
>
> Usa las globales velocidad y tiempoDeAccion, que fija accionarHerramientaSet(). Tras el
> movimiento devuelve el servo a velocidadNeutra y espera 100 ms para que se detenga.

**Archivo:** [[CodigoESP32.ino]] · línea 1061

```cpp
void accionarMotorHerramientaSet()
```

## La llaman
- [[accionarHerramientaSet]]

## Campos SET que usa
- [[SET stop]]

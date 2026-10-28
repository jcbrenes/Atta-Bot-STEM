---
tags: [funcion]
archivo: CalibracionServoHerramienta.ino
linea: 57
---
# CalibracionServoHerramienta.procesarComando

> Interpreta un comando del Monitor Serie: r, +, - o ?/ayuda.
>
> @param comando Línea recibida.

**Archivo:** [[CalibracionServoHerramienta.ino]] · línea 57

```cpp
void procesarComando(String comando)
```

## Llama a
- [[CalibracionServoHerramienta.imprimirAyuda]]
- [[CalibracionServoHerramienta.moverServo]]

## La llaman
- [[CalibracionServoHerramienta.loop]]

---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 1307
---
# controlServo

> Activa o desactiva el lápiz moviendo el servo a activateAngle o deactivateAngle.
>
> El parámetro tapa a la global int set, que no se usa aquí. Espera 500 ms después de
> escribir el ángulo para que la siguiente instrucción no empiece con el servo en marcha.
>
> @param set true para bajar/activar la herramienta; false para subirla/desactivarla.
>
> @return Siempre true, porque la escritura al servo no informa errores.

**Archivo:** [[CodigoESP32.ino]] · línea 1307

```cpp
bool controlServo(bool set)
```

## La llaman
- [[loop]]

## Campos SET que usa
- [[SET active]]
- [[SET inactive]]

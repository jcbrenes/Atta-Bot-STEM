---
tags: [funcion]
archivo: CalibracionMotores.ino
linea: 379
---
# CalibracionMotores.arranque

> Función para arranque del motor
>
> Esta función envía un PWM cada vez mayor al motor, hasta que se detecte suficiente avance en los encoders.
>
> @param direccion La dirección en la que se debe mover el motor: 2 para la preparación y 1 para la medición.
>
> @return true si el motor ya arrancó.

**Archivo:** [[CalibracionMotores.ino]] · línea 379

```cpp
bool arranque(int direccion)
```

## La llaman
- [[CalibracionMotores.loop]]

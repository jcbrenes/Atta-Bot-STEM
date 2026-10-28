---
tags: [funcion]
archivo: MotionRuntime.h
linea: 110
---
# calibrationIdle

> Dice si el robot está quieto y sin programa, condición para tocar la configuración.
>
> Se exige para SET, SHOW, MOVE, MOTOR, etc. (escribir en NVS o imprimir mucho mientras los
> motores actúan retrasaría el control) y para aceptar programas BLE nuevos.
>
> @return true si está en ESPERA, sin maniobra, sin prueba MOTOR, sin esperar la parada y sin
> recibir un programa.

**Archivo:** [[MotionRuntime.h]] · línea 110

```cpp
bool calibrationIdle()
```

## La llaman
- [[leerBluetooth]]
- [[processSerialCommand]]

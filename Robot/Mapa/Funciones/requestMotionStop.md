---
tags: [funcion]
archivo: MotionRuntime.h
linea: 136
---
# requestMotionStop

> STOP completo: detiene motores y cancela el programa en curso.
>
> Lo usan PARAR por BLE, STOP por Serial, el fin de la prueba MOTOR y los fallos no
> recuperables. Marca paro_emergencia, borra el programa (inst_actual = inst_final = 0) y su
> flujo, y pasa a DETENERSE, que espera stopSettlingTime antes de volver a ESPERA.

**Archivo:** [[MotionRuntime.h]] · línea 136

```cpp
void requestMotionStop()
```

## Llama a
- [[resetProgramFlow]]
- [[stopMotion]]

## La llaman
- [[leerBluetooth]]
- [[processSerialCommand]]
- [[reportMotionFault]]
- [[updateMotorTest]]

## Estados que asigna
- [[Estado DETENERSE]]

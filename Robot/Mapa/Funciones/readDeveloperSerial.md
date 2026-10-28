---
tags: [funcion]
archivo: MotionRuntime.h
linea: 418
---
# readDeveloperSerial

> Lee la consola Serial sin bloquear y pasa cada línea completa a processSerialCommand.
>
> Atiende como máximo 64 caracteres por vuelta de loop() para que un flujo continuo no frene
> el control. Ignora \r. Una línea de más de 95 caracteres se descarta entera.

**Archivo:** [[MotionRuntime.h]] · línea 418

```cpp
void readDeveloperSerial()
```

## Llama a
- [[processSerialCommand]]

## La llaman
- [[loop]]

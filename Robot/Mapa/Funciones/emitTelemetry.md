---
tags: [funcion]
archivo: MotionRuntime.h
linea: 186
---
# emitTelemetry

> Con TELEMETRY ON, imprime una fila CSV del controlador cada 100 ms.
>
> Formato: T,ms,device,modo,reverse,dt,cuentas R y L,mm R y L,referencia R y L,velocidad R y L,
> PWM R y L,integral R y L,saturada R y L,fallo. modo es IDLE, MOVE, TURN, SETTLE o MOTOR.
> Las columnas están en COLUMNS de tools/capturar_movimiento.py, que la guarda en CSV.
> Si el buffer de Serial no tiene lugar se descarta la fila: nunca bloquea el control.

**Archivo:** [[MotionRuntime.h]] · línea 186

```cpp
void emitTelemetry()
```

## Llama a
- `readEncoderCounts`

## La llaman
- [[loop]]

## Emite
- [[Mensaje T]]

## Campos SET que usa
- [[SET device]]
- [[SET speed]]

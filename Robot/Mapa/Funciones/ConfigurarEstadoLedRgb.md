---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 1334
---
# ConfigurarEstadoLedRgb

> Elige el color o parpadeo del LED RGB externo e interno según el estado del robot.
>
> Se llama al final de cada loop(). El orden de las comprobaciones es la prioridad:
> batería baja (rojo parpadeante), obstáculo o paro de emergencia (rojo fijo), Bluetooth
> desconectado (verde/azul intercalados), recepción de programa (azul parpadeante),
> ejecución (verde fijo) y Bluetooth conectado (azul fijo). Para los parpadeos reutiliza
> tiempoDeEncendidoDeLed como referencia de fase y lo reinicia al completar cada ciclo.
>
> @param flagBateriaBaja Lectura de la señal del powerboost; LOW indica batería baja.
> @param flagBluetooth true si hay conexión Bluetooth con la App.
> @param flagEjecucion true si se está ejecutando una programación.
> @param flagObstaculo true si los sensores infrarrojos detectaron un obstáculo.
> @param recibeProgra Pulso activo mientras se recibe/recién se recibió un programa.
> @param flagParar true si se pidió un paro de emergencia.

**Archivo:** [[CodigoESP32.ino]] · línea 1334

```cpp
void ConfigurarEstadoLedRgb(int flagBateriaBaja, bool flagBluetooth, bool flagEjecucion, bool flagObstaculo, bool recibeProgra, bool flagParar)
```

## Llama a
- `ledInterno`

## La llaman
- [[loop]]

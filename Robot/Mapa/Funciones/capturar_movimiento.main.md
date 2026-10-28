---
tags: [funcion]
archivo: capturar_movimiento.py
linea: 14
---
# capturar_movimiento.main

> Abre la consola DEV del Atta por USB y guarda la telemetría en CSV.
>
> Pide la clave DEV sin mostrarla, entra en modo desarrollador y envía SHOW, VERIFY y
> TELEMETRY ON. Cada fila "T,..." que llega se escribe en el CSV (columnas de COLUMNS, las
> mismas de emitTelemetry en MotionRuntime.h); el resto de lo que imprime el robot va a
> pantalla y a un .log junto al CSV, igual que los comandos tecleados (MOVE 300, TURN 90,
> MOTOR R F 80 1000...). Con "salir" o Ctrl+C manda STOP, TELEMETRY OFF y EXIT.
> No sobrescribe ensayos: si el CSV o su .log ya existen, se niega.
>
> Parámetros (línea de comandos):
> - --port: puerto serie del Atta (/dev/ttyUSB0, COM3).
> - --output: CSV nuevo; el .log se crea con el mismo nombre.

**Archivo:** [[capturar_movimiento.py]] · línea 14

```python
def main()
```

## Llama a
- [[capturar_movimiento.keyboard]]

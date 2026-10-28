---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 1274
---
# leerBluetooth

> Procesa el estado pendiente del BLE y, si corresponde, interpreta un programa nuevo.
>
> Actualiza flagBluetooth con deviceConnected. Dentro de la sección crítica de bleMux
> recoge bleStopPending y nuevoMensajeBLE, copia el buffer a una variable local y limpia
> las banderas. Un STOP pendiente tiene prioridad y llama a requestMotionStop(). Si no hay
> conexión o mensaje, retorna. Descarta mensajes cuya longitud no sea múltiplo de 5 y no
> reemplaza programas durante una maniobra, con configuración inválida o con un fallo
> activo (calibrationIdle, configReady y motion.fault). Si interpreta el programa, activa
> el pulso recibeProgra para que el LED parpadee en azul.

**Archivo:** [[CodigoESP32.ino]] · línea 1274

```cpp
void leerBluetooth()
```

## Llama a
- [[Interpreta_mensajeBLE]]
- [[calibrationIdle]]
- [[requestMotionStop]]

## La llaman
- [[loop]]

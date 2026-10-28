---
tags: [metodo]
archivo: CodigoESP32.ino
linea: 196
---
# MyCharacteristicCallbacks.onWrite

> Recibe el valor escrito por la App y lo deja listo para leerBluetooth().
>
> Ignora valores vacíos o de más de 500 caracteres. Recorre el mensaje en grupos de
> 5 y, si encuentra "PARAR", activa bleStopPending con prioridad sobre cualquier otro
> mensaje para que la parada no se pierda. Si no hay PARAR, copia el texto a
> mensajeBLEBuffer y activa nuevoMensajeBLE. Todo el acceso se protege con bleMux
> porque loop() lo lee desde otra tarea.
>
> @param pCharacteristic Característica BLE que recibió la escritura.

**Archivo:** [[CodigoESP32.ino]] · línea 196

```cpp
void onWrite(BLECharacteristic *pCharacteristic)
```

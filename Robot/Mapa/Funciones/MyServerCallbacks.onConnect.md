---
tags: [metodo]
archivo: CodigoESP32.ino
linea: 157
---
# MyServerCallbacks.onConnect

> Marca que hay un dispositivo central conectado.
>
> Solo actualiza la bandera global deviceConnected, que loop() usa para el LED y
> leerBluetooth() para decidir si procesa mensajes.
>
> @param pServer Servidor BLE que emite el evento (no se usa).

**Archivo:** [[CodigoESP32.ino]] · línea 157

```cpp
void onConnect(BLEServer* pServer)
```

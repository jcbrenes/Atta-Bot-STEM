---
tags: [metodo]
archivo: CodigoESP32.ino
linea: 170
---
# MyServerCallbacks.onDisconnect

> Marca que ya no hay dispositivo conectado y vuelve a anunciar el robot.
>
> El BLE nativo del ESP32 no reanuda el advertising solo tras una desconexión; sin
> reiniciarlo el robot dejaría de ser visible para nuevas conexiones. Por eso apaga
> deviceConnected y llama a start() del advertising del mismo servidor.
>
> @param pServer Servidor BLE que emite el evento.

**Archivo:** [[CodigoESP32.ino]] · línea 170

```cpp
void onDisconnect(BLEServer* pServer)
```

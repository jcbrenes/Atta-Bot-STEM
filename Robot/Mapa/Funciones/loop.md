---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 478
---
# loop

> Bucle principal: atiende E/S y ejecuta la máquina de estados del programa de bloques.
>
> En cada vuelta procesa comandos de desarrollador por Serial, revisa si hay mensajes BLE
> nuevos (o cada 50 ms) para no perder un STOP, avanza las pruebas de motor opcionales,
> toma las lecturas de los sensores infrarrojos, trackers y batería baja, y luego recorre
> el switch de estado:
> - ESPERA: aguarda a que termine de llegar un programa (flancoNegRecibeProgra) y pasa a
>   LEE_MEMORIA reiniciando el flujo; un paro recibido aquí se ignora.
> - LEE_MEMORIA: lee la siguiente instrucción de lista_instrucciones y salta al estado que
>   corresponda; si se están ignorando ramas, las salta hasta la marca IF/ELSE/WHILE.
> - MOVERSE y GIRAR: ejecutan la maniobra y pasan a DETENERSE al terminar o si hay paro u
>   obstáculo.
> - DETENERSE: detiene los motores, espera el asentamiento del chasis y vuelve a
>   LEE_MEMORIA, a ESPERA (paro o prueba) o a MOVIMIENTO_OBSTACULO.
> - CICLO, OBSTACULOS, HERRAMIENTA, IF, WHILE y HERRAMIENTA_SET: aplican esa instrucción
>   y vuelven a LEE_MEMORIA.
> - MOVIMIENTO_OBSTACULO: retrocede tras un obstáculo, reinicia el flujo y va a ESPERA.
> - NADA: no hace nada.
> Al salir del switch emite telemetría, limpia el flanco de recepción, apaga el pulso de
> recibeProgra tras su duración y actualiza el color del LED RGB.

**Archivo:** [[CodigoESP32.ino]] · línea 478

```cpp
void loop()
```

## Llama a
- [[ConfigurarEstadoLedRgb]]
- [[accionarHerramientaSet]]
- [[advanceDesiredDistance]]
- [[bifurcacionIF]]
- [[bifurcacionWHILE]]
- [[controlServo]]
- [[emitTelemetry]]
- [[leerBluetooth]]
- [[readDeveloperSerial]]
- [[resetProgramFlow]]
- [[stopMotion]]
- [[turnDesiredAngle]]
- [[updateMotorTest]]
- [[verSernsores]]

## Emite
- [[Mensaje MOVE_DONE]]

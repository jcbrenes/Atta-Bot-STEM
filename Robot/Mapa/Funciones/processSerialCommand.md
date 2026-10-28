---
tags: [funcion]
archivo: MotionRuntime.h
linea: 358
---
# processSerialCommand

> Atiende una línea de la consola de calibración (Monitor Serie, 115200, fin de línea \n).
>
> STOP funciona siempre. El resto exige entrar antes con "DEV <clave>" (developerPassword en
> RobotConfig.h); es protección contra cambios accidentales, no seguridad. Ya en modo DEV:
> TELEMETRY ON/OFF y EXIT funcionan siempre; los demás solo con el robot quieto
> (calibrationIdle) y si no, responde BUSY.
>
> Comandos: HELP, SHOW (configuración en RAM), VERIFY (RAM contra NVS), CLEAR (despejar fallo),
> ENCODERS (cuentas), SET <campo> <valor> (guardar; ver saveDeveloperValue), TEST <ángulo>
> (mover el servo del lápiz sin guardar), MOVE <mm> / TURN <grados> (maniobra con el
> controlador, hasta ±3000 mm o ±3600°; al terminar imprime MOVE_DONE) y MOTOR (ver
> startMotorTest).
>
> @param command Línea recibida, sin el salto de línea.

**Archivo:** [[MotionRuntime.h]] · línea 358

```cpp
void processSerialCommand(String command)
```

## Llama a
- [[Controller.clear]]
- [[calibrationIdle]]
- [[printDeveloperConfig]]
- [[printDeveloperHelp]]
- [[requestMotionStop]]
- [[saveDeveloperValue]]
- [[startMotorTest]]
- [[verifyConfig]]
- `parseFloatValue`
- `readEncoderCounts`

## La llaman
- [[readDeveloperSerial]]

## Emite
- [[Mensaje BUSY]]
- [[Mensaje ENCODERS]]
- [[Mensaje VERIFY ERROR]]
- [[Mensaje VERIFY OK]]

## Estados que asigna
- [[Estado GIRAR]]
- [[Estado MOVERSE]]

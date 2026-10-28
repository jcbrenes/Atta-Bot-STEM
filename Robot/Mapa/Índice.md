---
tags: [indice]
---
# Mapa del firmware Atta-Bot STEM

Generado desde el código por `Robot/tools/mapa_obsidian.py`. No editar a mano: se reescribe en cada corrida.

**Cómo leerlo:** la app manda el programa por BLE → [[Interpreta_mensajeBLE]] llena `lista_instrucciones` → [[loop]] recorre los estados. La calibración entra por Serie → [[readDeveloperSerial]] → [[processSerialCommand]] → [[saveDeveloperValue]] → NVS.

Colores del grafo: funciones azul, métodos celeste, estados naranja, instrucciones morado, comandos verde, mensajes rojo y parámetros amarillo. El grafo oculta las notas de índice con el filtro `-tag:#indice`. Las funciones utilitarias (`clamp`, `constrain`, `ledInterno`, `parseFloatValue`, `readEncoderCounts`, `within`) no se enlazan porque las llama casi todo.

## Archivos
- [[CodigoESP32.ino]]
- [[RobotConfig.h]]
- [[MotionRuntime.h]]
- [[MotionControl.h]]
- [[CalibracionMotores.ino]]
- [[CalibracionServoHerramienta.ino]]
- [[CalibracionCuadrado.h]]
- [[calibrar_cuadrado.cpp]]
- [[auditar_giros.cpp]]
- [[capturar_movimiento.py]]

## Estados
- [[Estado ESPERA]]
- [[Estado LEE_MEMORIA]]
- [[Estado MOVERSE]]
- [[Estado GIRAR]]
- [[Estado DETENERSE]]
- [[Estado CICLO]]
- [[Estado OBSTACULOS]]
- [[Estado MOVIMIENTO_OBSTACULO]]
- [[Estado HERRAMIENTA]]
- [[Estado HERRAMIENTA_SET]]
- [[Estado IF]]
- [[Estado WHILE]]
- [[Estado NADA]]

Ejemplo de programa BLE (valor por defecto de `mensajeBLE`): `ATINIAV020GD030CI003RE010GI090CIFINATFIN`

## Instrucciones BLE
- [[Instruccion ATCOF]]
- [[Instruccion ATCOI]]
- [[Instruccion ATFIN]]
- [[Instruccion ATINI]]
- [[Instruccion AV]]
- [[Instruccion CI]]
- [[Instruccion CIFIN]]
- [[Instruccion EJECU]]
- [[Instruccion EL]]
- [[Instruccion GD]]
- [[Instruccion GI]]
- [[Instruccion HE]]
- [[Instruccion HEFIN]]
- [[Instruccion HEINI]]
- [[Instruccion IF]]
- [[Instruccion IFFIN]]
- [[Instruccion OBFIN]]
- [[Instruccion OBINI]]
- [[Instruccion PARAR]]
- [[Instruccion RE]]
- [[Instruccion WH]]
- [[Instruccion WHFIN]]

## Comandos serie
- [[Comando CLEAR]]
- [[Comando DEV]]
- [[Comando ENCODERS]]
- [[Comando EXIT]]
- [[Comando HELP]]
- [[Comando MOTOR]]
- [[Comando MOVE]]
- [[Comando SET]]
- [[Comando SHOW]]
- [[Comando STOP]]
- [[Comando TELEMETRY OFF]]
- [[Comando TELEMETRY ON]]
- [[Comando TEST]]
- [[Comando TURN]]
- [[Comando VERIFY]]

## Mensajes serie
- [[Mensaje BUSY]]
- [[Mensaje CONFIG]]
- [[Mensaje ENCODERS]]
- [[Mensaje ERROR CONFIG]]
- [[Mensaje ERROR PWM]]
- [[Mensaje FAULT]]
- [[Mensaje MOTOR_BEGIN]]
- [[Mensaje MOTOR_DONE]]
- [[Mensaje MOVE_DONE]]
- [[Mensaje PROGRAM_CONTINUE]]
- [[Mensaje T]]
- [[Mensaje TURN_RESULT]]
- [[Mensaje VERIFY ERROR]]
- [[Mensaje VERIFY OK]]

## Parámetros SET
- [[Parámetros SET]]

## Guías
- [[Calibracion_paso_a_paso]]
- [[README]]
- [[Control_movimiento_V2]]
- [[Guia_parametros_SET]]
- [[Calibracion_cuadrado]]
- [[Auditoria_giros_V2]]
- [[Auditoria_movimiento_13_Attas]]

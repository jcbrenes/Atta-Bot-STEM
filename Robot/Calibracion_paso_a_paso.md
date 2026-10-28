---
tags: [guia]
---
# Calibración paso a paso

Nota de entrada para quien tenga que calibrar un Atta o tocar el firmware sin haber estado
cuando se hizo. Une las guías que ya existen con el mapa generado desde el código
([[Índice]] del Mapa). Para el detalle de cada valor: [[Guia_parametros_SET]]. Para el
controlador y sus decisiones: [[Control_movimiento_V2]].

## Idea general

Todos los Attas llevan **el mismo firmware** ([[CodigoESP32.ino]]). Lo que cambia de un robot a
otro (PPR de cada rueda, separación entre ruedas, PWM de arranque, ángulos de los servos,
nombre Bluetooth) vive en la **NVS** del ESP32, una memoria que no se borra al cargar
firmware nuevo. Por eso se puede actualizar el firmware de los 13 sin recalibrar ninguno.

La calibración se hace por el **Monitor Serie** (115200 baudios, fin de línea "Nueva línea"),
con el robot conectado por USB y el firmware principal cargado:

```text
DEV <clave>          entrar al modo desarrollador (clave en RobotConfig.h)
SHOW                 ver todo; guardar esta salida como respaldo
SET <campo> <valor>  guardar un valor (queda verificado en NVS al instante)
VERIFY               comprobar que RAM y NVS coinciden
EXIT
```

Cómo viaja un `SET` por el código: [[readDeveloperSerial]] → [[processSerialCommand]] →
[[saveDeveloperValue]] → [[writeMotionProfile]] / [[writeTurnProfile]] → NVS. Al arrancar,
[[loadConfig]] lo vuelve a leer. Lista de todos los campos con su defecto y rango:
[[Parámetros SET]].

## Antes de empezar

1. **Respaldo.** `SHOW` y guardar la salida con el nombre del robot. El script
   `cargar_firmware_attas.sh` ya lo hace solo en `Respaldos_SHOW/`. Esa salida se puede pegar de
   vuelta en el Monitor Serie para restaurar el robot.
2. **Firmware y perfil común.** `bash Robot/cargar_firmware_attas.sh compilar` y después
   `bash Robot/cargar_firmware_attas.sh continuo` (o `configurar` si solo cambian valores).
   Fija en cada Atta los valores que son iguales para todos (velocidades, rampas, ganancias,
   `pwmhz 20000`) y no toca los propios de cada robot. No usar "Erase All Flash": borra la NVS.
3. **Nombre.** Un Atta que nunca guardó nada arranca como `Atta-V-02`: `SET device Atta-X-NN`
   y reiniciar ([[SET device]]).

## Orden de calibración de un robot

Cada paso corrige un síntoma distinto; ir en orden, porque los siguientes dependen de los
anteriores.

| # | Qué | Cómo | Campos |
|---|---|---|---|
| 1 | Encoders vivos | `ENCODERS`, girar cada rueda a mano, `ENCODERS` otra vez: las dos cuentas deben subir. Si no, revisar cableado antes de seguir. | — |
| 2 | PPR de cada rueda | `ENCODERS` antes y después de girar la rueda a mano N vueltas: PPR = diferencia / N. Método antiguo: sketch [[CalibracionMotores.ino]]. | [[SET rppr]], [[SET lppr]] |
| 3 | Arranque de cada motor | `MOTOR R F <pwm> 1000` subiendo el PWM de 5 en 5 hasta que la rueda se mueve, en el suelo. Repetir con `R R`, `L F`, `L R`. | [[SET rfstart]], [[SET rrstart]], [[SET lfstart]], [[SET lrstart]] |
| 4 | Servo del lápiz | `TEST <ángulo>` hasta que el lápiz apoye sin forzar (abajo) y quede libre (arriba). También el sketch [[CalibracionServoHerramienta.ino]]. | [[SET active]], [[SET inactive]], [[SET neutral]] |
| 5 | Servo de la herramienta (garra/grúa) | Ajustar hasta que en reposo no se mueva solo. | [[SET stop]], [[SET forward]], [[SET reverse]] |
| 6 | Rectas | `MOVE 300` y medir con regla. Si una recta se curva, la proporción rppr/lppr está mal (paso 7). | — |
| 7 | Giros y rectas finos | Prueba del cuadrado en los dos sentidos ([[Calibracion_cuadrado]]); la calculadora `tools/calibrar_cuadrado.cpp` devuelve tres líneas `SET`. | [[SET rppr]], [[SET lppr]], [[SET track]] |
| 8 | Comprobar | `VERIFY`, reiniciar, `SHOW` (que persista) y un octágono o cuadrado con lápiz. Guardar el `SHOW` final. | — |

No tocar para "arreglar" síntomas: `tolerance`, `filterms`, `stallms`, `startms` (seguridad),
`rradius`/`lradius` (se dejan en 22 y se ajusta PPR) ni `kd` (0). No cambiar PPR para que el
robot vaya más rápido: eso es `speed`.

## Qué mirar cuando algo falla

El firmware avisa por Serial con mensajes fijos ([[Índice]] → Mensajes serie):

- `FAULT,RIGHT_STALL` / `LEFT_STALL`: una rueda con PWM no contó pulsos en `stallms`. Encoder
  suelto, batería baja o rueda trabada. Ver [[Controller.update]].
- `FAULT,TIMEOUT` / `CONTROL_LATE` / `NOT_SETTLED`: maniobra demasiado larga, `loop()` atrasado,
  o el giro no se quedó quieto. Ver [[reportMotionFault]].
- `PROGRAM_CONTINUE`: en un programa de la app, se saltó la instrucción que falló y siguió.
- `TURN_RESULT,OVERSHOOT`: el giro se pasó. No se corrige con `track`; se corrige con
  `turnapproach`/`turnzone`. Ver [[runMotion]].
- `ERROR CONFIG`: perfil inválido en NVS; el robot no se mueve hasta arreglarlo con `SET`.
- `ERROR PWM`: los motores no quedaron a la frecuencia pedida ([[attachMotorPWM]]).

Para ver el controlador por dentro: `TELEMETRY ON` (una fila CSV cada 100 ms, [[emitTelemetry]])
o `python3 Robot/tools/capturar_movimiento.py --port /dev/ttyUSB0 --output ensayo.csv`.

## Para quien modifique el firmware

- **Dónde está cada cosa:** máquina de estados y Bluetooth en [[CodigoESP32.ino]]; perfil y NVS
  en [[RobotConfig.h]]; controlador en [[MotionControl.h]]; unión con el hardware y consola en
  [[MotionRuntime.h]].
- **Cada función lleva un recuadro de comentarios** (`//****...`) con qué hace, por qué,
  `@param` y `@return`. El mapa se arma desde esos recuadros: si se agrega o cambia una
  función, se actualiza su recuadro y se regenera el mapa:

  ```sh
  python3 Robot/tools/mapa_obsidian.py --revisar
  ```

- **Agregar un parámetro calibrable:** sumarlo al struct (`MotionConfig`, `WheelConfig` o
  `TurnConfig`) con su rango en `validConfig`/`validTurnConfig`, y a la tabla `motionFields` o
  `turnFields`. SHOW y SET lo toman solos. Ojo: cambiar un struct cambia el bloque binario
  guardado; hay que subir `version` y migrar en [[loadConfig]], o los robots ya calibrados
  quedan bloqueados con `ERROR CONFIG`.
- **Probar sin robot:** los tests de `tests/` compilan el controlador y la configuración en PC
  (comandos al final de [[Control_movimiento_V2]]). Correrlos antes de cargar a los Attas.
- **Abrir el vault:** en Obsidian, "Abrir carpeta como vault" → la carpeta `Robot/`. La vista de
  grafo muestra el firmware entero conectado.

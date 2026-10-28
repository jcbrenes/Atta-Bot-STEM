# Guía práctica de parámetros `SET`

Qué hace cada valor que muestra `SHOW`, cuándo tocarlo y qué síntoma corrige.
Rangos exactos y detalles del controlador: `Control_movimiento_V2.md`.

Unidades: distancia en mm, velocidad en mm/s, aceleración en mm/s², PWM de
0 a 255 (8 bits, sin importar `pwmhz`). `r`/`l` = rueda derecha/izquierda.

Los parámetros se dividen en tres clases:

- **Calibración del robot**: dependen del hardware de cada Atta. Se miden
  robot por robot y no se copian de otro.
- **Perfil común**: iguales en todos los Attas. El script
  `cargar_firmware_attas.sh` los fija al cargar el firmware.
- **No tocar**: valores de seguridad o del controlador que funcionan bien con
  su valor por defecto.

## 1. Geometría — calibración del robot

| Campo | Qué es | Síntoma si está mal |
|---|---|---|
| `rppr`, `lppr` | Cuentas del encoder por vuelta de rueda. Convierte cuentas en mm. | Recorre más o menos de lo pedido; si difieren mal entre sí, las rectas se curvan. |
| `rradius`, `lradius` | Radio efectivo de la rueda (22). | Igual que PPR. Se deja en 22 y se ajusta PPR. |
| `track` | Separación efectiva entre ruedas. Convierte grados en mm de giro. | **Todos** los giros se quedan cortos (track bajo) o se pasan (track alto). |

Cómo calibrar: la prueba del cuadrado (`Calibracion_cuadrado.md`) calcula
`rppr`, `lppr` y `track` a la vez. No cambie PPR para hacer el robot más rápido.

## 2. Velocidad — perfil común

Las rectas y los giros tienen rampas **separadas**:

| Campo | Aplica a | Qué hace | Estándar |
|---|---|---|---|
| `speed` | Rectas | Velocidad de crucero. | 150 |
| `accel` | Rectas | Qué tan rápido sube a `speed`. Muy alto: la rueda patina al arrancar. | 350 |
| `decel` | Rectas | Qué tan rápido frena. Muy alto: se pasa o patina al parar. | 400 |
| `turnspeed` | Giros | Velocidad máxima de giro. | 120 |
| `turnaccel` | Giros | Rampa de subida del giro. | 120 |
| `turndecel` | Giros | Rampa de frenado del giro. | 120 |
| `turnzone` | Giros | Últimos mm (por rueda) que se recorren despacio. | 5 |
| `turnapproach` | Giros | Velocidad dentro de `turnzone`. Es lo que da precisión al ángulo. | 40 |
| `maxpwm` | Todo | Tope de PWM del controlador. Deja margen para corregir. | 230 |

**Importante:** `accel`/`decel` no afectan a los giros, y en giros cortos
`turnspeed` casi no importa: con `turnaccel 120` el robot no alcanza la
velocidad de crucero antes de empezar a frenar. En un giro de 45° (unos 47 mm
por rueda con `track 120`) llega a ~76 mm/s; en uno de 90°, a ~107 mm/s. Para
girar más rápido hay que subir `turnaccel`/`turndecel`, no `turnspeed`.

Prueba en V-02 (octágono de 20 cm × 45°, error de cierre):

| Escalón | `speed` | `accel` / `decel` | Cierre |
|---|---|---|---|
| 1 | 110 | 250 / 300 | casi 1 cm |
| 2 (estándar) | 150 | 350 / 400 | 1.2 cm y 1.5 cm (dos corridas) |
| intermedio | 170 | 350 / 400 | 2 cm |
| 3 | 190 | 450 / 500 | 3.4 cm |

Como `turnaccel`/`turndecel` estuvieron en 120 en los tres escalones, la
diferencia del escalón 3 viene de las rectas. Por encima de 150 mm/s el error
crece rápido; 150 es el máximo sin pérdida notable (una corrida por escalón,
salvo el 2; entre corridas varía unos 3 mm).

## 3. Motores y control — `kp`/`ki`/`kd` son perfil común; el resto, del robot

El controlador ajusta el PWM de cada rueda cada 25 ms para seguir la velocidad
de referencia.

| Campo | Qué hace | Cuándo tocarlo |
|---|---|---|
| `rkp`, `lkp` | Ganancia proporcional: cuánto PWM agrega por cada mm/s de error. | Estándar: 2.1. Si la rueda oscila (zumba o va a tirones), bajarla. |
| `rki`, `lki` | Ganancia integral: corrige el error que se acumula (rueda con más fricción). | Estándar: 2.1 (antes 0.8 en la mayoría). Si tarda en alcanzar la velocidad, subirla un poco. |
| `rkd`, `lkd` | Derivada. | Dejar en 0. |
| `kp`, `ki`, `kd` | Atajo: asigna el mismo valor a las dos ruedas. | — |
| `rfstart`, `rrstart`, `lfstart`, `lrstart` | PWM mínimo para que la rueda arranque desde quieta (f = adelante, r = atrás). Solo se aplica durante `startms` si la rueda aún no se movió. | Si una rueda tarda en arrancar o arranca a destiempo. Medir con `MOTOR`: el menor PWM que la mueve. Común: 60. |
| `rfhold`, `rrhold`, `lfhold`, `lrhold` | PWM mínimo mientras la rueda va más lenta de lo pedido. | Dejar en 0 salvo que la rueda se trabe a baja velocidad. |
| `rfff`, `rrff`, `lfff`, `lrff` | Feedforward: PWM base proporcional a la velocidad pedida, antes de la corrección. | Dejar en 0 mientras no haya curva PWM/velocidad medida. |
| `sync` | Cuánto frena la rueda que va adelantada para que las dos avancen igual. | Común: 1. Más alto endereza más, pero puede oscilar. |

## 4. Seguridad y fin de maniobra — no tocar

| Campo | Qué hace | Valor |
|---|---|---|
| `tolerance` | Margen en mm para dar por llegada una rueda. | 0.5 |
| `filterms` | Suavizado de la velocidad medida por el encoder. | 50 |
| `stallms` | Si una rueda con PWM no cuenta pulsos en este tiempo → `RIGHT_STALL`/`LEFT_STALL` y se detiene. | 1500 |
| `startms` | Ventana del arranque en la que aplica `*start`. | 200 |

Si aparece un `STALL`, revisar el encoder, la batería y las ruedas antes de
cambiar estos valores. Subir `stallms` no arregla un encoder desconectado.
Para seguir después de un fallo: `CLEAR`.

## 5. Servos — calibración del robot

| Campo | Servo | Qué es |
|---|---|---|
| `neutral` | Lápiz (pilot) | Ángulo al encender el Atta. |
| `active` | Lápiz | Ángulo con el lápiz abajo (dibujando). |
| `inactive` | Lápiz | Ángulo con el lápiz arriba. |
| `forward` | Herramienta (servo continuo del set) | Valor para abrir garra / subir grúa. |
| `reverse` | Herramienta | Valor para cerrar garra / bajar grúa. |
| `stop` | Herramienta | Valor en que el servo continuo queda quieto. Si la herramienta se mueve sola en reposo, ajustar este. |

Probar ángulos del lápiz sin guardarlos: `TEST <angulo>`.

## 6. Otros

| Campo | Qué es |
|---|---|
| `pwmhz` | Frecuencia del PWM de motores. Estándar 20000 (inaudible). Se aplica al reiniciar. Con 1000 Hz los motores zumban. |
| `device` | Nombre Bluetooth del Atta. Se aplica al reiniciar. **Un Atta nuevo arranca como `Atta-V-02`**: hay que darle su nombre. |

## Comandos útiles

```text
DEV <clave>          entrar en modo configuración
SHOW / VERIFY        ver valores / comprobar que coinciden con la memoria
SET <campo> <valor>  guardar un valor
MOVE <mm>            recta (negativo: atrás)
TURN <grados>        giro (negativo: izquierda)
MOTOR <R|L> <F|R> <PWM> <ms>   mover una rueda directamente (sin control)
ENCODERS             cuentas actuales
TELEMETRY ON|OFF     datos del controlador cada 100 ms
STOP / CLEAR / EXIT
```

Antes de cambiar valores, guarde la salida de `SHOW` del robot.

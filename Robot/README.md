# Directorio Robot 

 Código para la programación del controlador del robot

 Lenguaje: C++
 Ambiente de programación: Arduino IDE
 Microncontrolador usado: IdeaBoard (basada en ESP32)

## Calibración persistente desde el firmware principal

Abra `CodigoESP32/CodigoESP32.ino` conservando los archivos `.h` de su carpeta. En el primer arranque crea los
valores por defecto; después los conserva en la memoria no volátil del ESP32
(NVS), incluso al cargar firmware que respete el perfil. Mantenga desactivado
`Erase All Flash Before Sketch Upload` y conserve las particiones.

Abra el Monitor Serial a **115200 baudios** y con terminación **Nueva línea**.
Para habilitar los comandos de calibración escriba:

```
DEV AttaDev2026
```

La clave está definida como `developerPassword` en `CodigoESP32/RobotConfig.h`;
cámbiela antes de distribuir el firmware. El acceso sirve como protección ante
cambios accidentales: una persona con acceso físico al USB y al código puede
leerla.

Una vez dentro:

```
SHOW
SET neutral 75
SET active 85
SET inactive 50
TEST 85
EXIT
```

`SET` guarda y verifica de inmediato, estando el robot detenido. `SHOW` lista
todos los campos disponibles y `VERIFY` compara la configuración con NVS.
`kp`, `ki` y `kd` son alias para modificar ambas ruedas; también existen
`rkp/rki/rkd` y `lkp/lki/lkd`. **Las ganancias V2 usan segundos**; consulte la
migración antes de copiar valores del código anterior.
`TEST` mueve el servo del lápiz de forma temporal y no guarda nada.
Los valores `neutral`, `active` e `inactive` corresponden al servo de lápiz;
`forward`, `reverse` y `stop` al servo continuo del set de herramientas.

El sketch `CodigoESP32/Preferences/Preferences.ino` queda solo como referencia
legada y ya no escribe valores, para impedir que sobrescriba una calibración por
accidente.

La guía [Control y calibración V2](Control_movimiento_V2.md) explica el respaldo,
la migración, los rangos, pruebas por motor, telemetría CSV y validación física.
Use el modo de diagnóstico del firmware principal para calibrar. El antiguo
`BancoDePruebasPID` se conserva como referencia histórica; sus constantes y
su protocolo de telemetría no equivalen al controlador V2.

La revisión `controller=3` añade rampas propias de giro (`turnaccel`, `turndecel`),
aproximación final (`turnapproach`, `turnzone`) y observación de encoders durante
la parada. Conserva el perfil `motionV2` y guarda esos ajustes en `turnV1`.
Consulte `TURN_RESULT` para distinguir giro completado, exceso o fallo; el
ángulo estimado por encoders no sustituye la medición física del chasis.

# Auditoría de giros V2 — 19 de septiembre de 2026

Nota de seguimiento: los hallazgos siguientes describen el controlador 2 antes
de la mejora. El código local fue actualizado posteriormente a controlador 3;
véase la sección final y `Control_movimiento_V2.md`. La herramienta de simulación
incluye siempre el controlador actual, por lo que ya produce resultados nuevos.

## Alcance y conclusión

Revisión del controlador local basado en `0e3755d`, incluyendo el cambio local
que permite continuar programas tras fallos recuperables. No se modificó el
firmware durante esta auditoría ni se hicieron mediciones físicas.

Hay limitaciones verificables de finalización y observación del movimiento que
deben resolverse antes de intentar compensar todos los errores con `track`.
No se ha demostrado cuál explica el error del Atta-A-02 ni su magnitud real.
La fórmula geométrica de giro no presenta un factor dos ni una conversión de
grados incorrectos. Un firmware común es viable; precisión idéntica en los 13
robots sin validación física no queda demostrada.

## Hallazgos priorizados

1. **Alta: llegada por posición sin comprobar reposo ni compensar exceso.**
   `CodigoESP32/MotionControl.h:140–142` enclava `arrived` para cada rueda al
   alcanzar `target - tolerance`, aunque siga girando. No hay límite superior
   de error: sobrepasar ampliamente el destino también cumple la condición.
   `reference()` ordena cero a la rueda llegada y no corrige el exceso.
   `update():132` deja de muestrear cuando `active` es falso. La espera de
   `CodigoESP32.ino:550–583` es temporal: no verifica cuentas estables ni ajusta
   la trayectoria. Las ISR siguen contando y la telemetría publica cuentas
   acumuladas, pero sus distancias y velocidades de la maniobra quedan congeladas.
   La siguiente maniobra toma un nuevo origen, sin compensar el exceso anterior.

2. **Alta: la rampa de frenado limita la referencia, no garantiza la frenada física.**
   `MotionControl.h:156–164` usa `sqrt(2 * deceleration * remaining)`; el PID
   intenta seguir esa referencia, pero la condición de llegada no exige una
   velocidad final baja. La salida PWM está limitada a valores no negativos y
   el sentido permanece fijo durante la maniobra. No hay inversión correctiva.
   `MotionRuntime.h:19–32` pone ambas entradas del motor en cero al detenerlo.
   No se concluye que eso sea frenado activo o rueda libre sin verificar el
   puente real. No aumentar `decel` suponiendo que implica más capacidad física
   de frenado: también retrasa el momento de empezar a reducir la referencia.

3. **Media: rectas y giros comparten aceleración y desaceleración.**
   Solo la velocidad nominal cambia entre `speed` y `turnSpeed`
   (`MotionControl.h:145`); `reference()` utiliza los mismos parámetros.
   El ajuste reciente a `accel=250`, `decel=300` también modifica los giros.
   Separar el perfil permitiría preservar las rectas que el usuario ya considera
   correctas. No demuestra por sí mismo qué valores servirán para toda la flota.

4. **Media: los encoders cuentan magnitud, sin sentido físico.**
   `CodigoESP32.ino:241–250` incrementa una cuenta en cada ISR; no decodifica A/B.
   Retroceso accidental u oscilación también sumarían avance. Esto limita una
   futura corrección automática de sobrepaso: no basta con invertir el motor.
   El cambio a conteo con signo necesita pruebas de polaridad, resolución x4,
   desbordamiento y compatibilidad con los PPR existentes. No hay evidencia de
   que los encoders actuales estén perdiendo pulsos o contando ruido.

5. **Media: las pruebas existentes no validan el ángulo tras asentamiento.**
   `tests/motion_control_test.cpp:97–112` simula hasta `m.active == false` y
   comprueba distancia en ese instante. No simula después la inercia restante,
   contacto del lápiz ni deslizamiento. Que pase no demuestra precisión angular.

6. **Diagnóstico: continuar tras un fallo puede dejar giros incompletos.**
   El cambio solicitado en `MotionRuntime.h:57–73` conserva la secuencia, pero
   omite la maniobra fallida y despeja el fallo. No equivale a terminar el ángulo.
   Separar ensayos con `FAULT`/`PROGRAM_CONTINUE` de los giros completados antes
   de atribuir un ángulo insuficiente a geometría o PID. Una prueba `TURN` por
   Serial mantiene el fallo enclavado, a diferencia del programa de la app.

## Comprobaciones correctas y límites

- Para giro sobre el centro, recorrido de cada rueda =
  `abs(grados) * pi * track / 360`: 90° y track 120 mm dan 94,248 mm por rueda.
  PPR y radio se aplican por rueda; las salidas ordenan sentidos opuestos.
  El signo físico derecha/izquierda depende del cableado y debe comprobarse.
- La sincronización compara recorridos en mm y reduce la referencia de la rueda
  adelantada. No mide el ángulo del chasis ni corrige el exceso una vez llegada.
- Con track 120, tolerance 0,5 mm permite aproximadamente 0,477° de defecto
  conjunto ideal. No constituye una cota de error final. Una cuenta por rueda
  con radios 22 y PPR 822/808 representa aproximadamente 0,162° conjuntamente.
  Son cálculos condicionales, no mediciones del track del usuario.
- Rectas correctas no verifican por sí solas el `track`, la respuesta al invertir
  una rueda ni el agarre durante giro. No se justifica alterar PPR/radios ahora.

## Reproducción en computadora

Desde la raíz:

```sh
g++ -std=c++17 -Wall -Wextra Robot/tools/auditar_giros.cpp -o /tmp/atta-auditar-giros
/tmp/atta-auditar-giros
```

El programa incluye el controlador real y una planta hipotética de dos motores
con fricción y retardo, derivada de la familia usada en la prueba existente.
Utiliza los parámetros compartidos por el usuario, con track=120 y ganancias
por defecto donde no se aportaron valores completos. Compara tres respuestas
de motor, cuatro órdenes y dos períodos: 24 casos. No modela deslizamiento,
carga de giro, asimetría de sentido ni la electrónica real. Ángulos reportados
en magnitud; +/-90 son iguales por construcción de la planta.

Ejemplo de 90°, paso 25 ms, misma geometría y control:

| Respuesta simulada | Ángulo de encoders al terminar | Ángulo del modelo tras 500 ms |
|---|---:|---:|
| 0,10 | 90,609° | 97,167° |
| 0,20 | 89,968° | 91,617° |
| 0,40 | 89,806° | 90,263° |

Todos estos casos terminan sin fallo. Esto reproduce que el criterio actual
puede dar por bueno un giro cuyo ángulo cambia después. No estima el error del
Atta real ni prueba que una modificación concreta ya lo resuelva.

## Orden de corrección propuesto para un firmware común

1. Registrar por maniobra: resultado completo/omitido, motivo, cuentas al cortar
   PWM y al terminar asentamiento, tiempos y velocidad de llegada. Mantener la
   observación durante asentamiento y distinguir reposo de espera transcurrida.
2. Separar rampas de giro y añadir una aproximación final de baja velocidad;
   evaluar posición y reposo con tolerancias explícitas. Comprobar frenado real
   antes de introducir modos eléctricos nuevos. El sobrepaso debe reportarse,
   no declararse corregido simplemente por esperar.
3. Versionar/migrar NVS si se amplía MotionConfig: `RobotConfig.h` guarda la
   estructura binaria y exige tamaño exacto; añadir campos sin migración haría
   inválidos los perfiles guardados. Preservar calibraciones y ajustes de recta.
4. Ampliar simulaciones con asentamiento, diferentes retardos, fallos y dirección.
   Validar un mismo perfil en una muestra de Attas con 45/90/180° en ambos
   sentidos y con lápiz arriba/abajo. Medir orientación externa además de encoders.
   Solo entonces decidir si basta un track común; no compensar frenado con track.

Una IMU no es requisito para estas correcciones. Considerarla si las mediciones
externas muestran desviaciones que las cuentas de rueda no reflejan; tampoco
debe prometerse precisión universal solo por añadir un sensor.

## Seguimiento: primera mejora implementada

Controlador 3: rampas propias, aproximación progresiva final, observación de
encoders hasta reposo (500 ms mínimo, 150 ms sin pulsos, 2000 ms máximo),
resultado explícito de exceso y perfil independiente `turnV1`. El formato
binario `motionV2` permanece intacto. La espera no corrige sobrepaso; el nuevo
perfil intenta reducirlo antes de cortar PWM, y lo reporta si ocurre.

En los 24 escenarios del simulador, el peor error del modelo tras finalizar y
esperar otros 500 ms pasa de unos 9,4° a 2,4°. Para +90° con paso de 25 ms,
los resultados de las tres respuestas pasan de 97,167/91,617/90,263° a
90,693/90,173/89,787°. Estos números incluyen la misma planta hipotética,
no mediciones físicas ni deslizamiento. Los tiempos crecen: para esos giros
de 90°, la nueva finalización tarda aproximadamente 4,75–4,80 s incluyendo
asentamiento. El perfil inicial prioriza precisión sobre rapidez.

Las nuevas pruebas verifican persistencia sin reescribir motionV2, perfiles
inválidos, fallos NVS, independencia de rampas, movimiento residual, exceso,
ausencia de reposo, wrap temporal y STOP durante asentamiento. Las pruebas
de rectas anteriores siguen pasando. Validación física pendiente.

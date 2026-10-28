# Auditoría de movimiento de los 13 Attas

Fecha: 2026-09-18. Revisión estática de los archivos locales, incluidos los cambios de trabajo existentes. No se conectaron robots, no se midieron motores y no se modificó el firmware. Las referencias de línea corresponden a esta revisión.

**Dictamen:** hay defectos y limitaciones del control que pueden explicar diferencias entre robots y entre ejecuciones. Conviene corregirlos antes de seguir afinando PID. La solución propuesta es un firmware común, medición por motor y calibración persistente por Atta. No hay evidencia suficiente para asignar la causa física a cada uno de los 13 equipos ni para proponer ganancias definitivas.

**1. Qué significa cada ajuste**

| Variable | Qué representa | Cómo determinarla |
|---|---|---|
| PPR usado por este código | Cuentas por revolución de la rueda/eje de salida, contando cambios en A y B | Medir vueltas conocidas con el mismo modo de conteo |
| Radio efectivo de rueda | Conversión de vueltas a distancia en el suelo | Medir recorridos después de verificar PPR |
| Separación efectiva entre ruedas | Conversión de recorrido a ángulo de giro | Medir giros después de calibrar distancia |
| Velocidad objetivo | Rapidez deseada en mm/s | Elegir dentro del rango sostenible de ambos motores bajo carga |
| PWM | Orden eléctrica al puente de motores; no es una velocidad medida | Medir respuesta de cada motor y sentido |
| PI/PID | Corrección de la diferencia entre velocidad pedida y medida | Ajustar después de validar medición y límites |

No utilizar PPR para compensar un motor lento o un giro incorrecto: modifica simultáneamente la velocidad estimada y la distancia. Un mismo chasis y peso no garantizan la misma respuesta de motores, reductoras, alimentación, ruedas o presión del pilot. Estas son hipótesis físicas por comprobar, no fallas demostradas en la flota.

**2. Hallazgos prioritarios en el firmware principal**

Todas las referencias de esta sección son a `CodigoESP32/CodigoESP32.ino`.

| ID / prioridad | Evidencia | Consecuencia y acción propuesta |
|---|---|---|
| M1 / Alta | Líneas 1388–1407: integral multiplicada por `0.01`, pero muestreo nominal de 25 ms en línea 89; derivada sin dividir por tiempo | El PID no usa el mismo tiempo que la medición de velocidad. Pasar el tiempo real en segundos al controlador y revisar las ganancias al migrar. |
| M2 / Alta | Líneas 106–107 y 1407: salida limitada siempre a 60–200 | No permite ordenar menos de 60 durante el control, aun con exceso de velocidad. Si un motor requiere más para arrancar o menos para sostenerse, el ajuste común falla. Medir arranque y mantenimiento por motor/sentido; permitir cero cuando corresponda. |
| M3 / Alta | Líneas 1499–1514 y 1603–1618: se apagan motores, pero `prevPWMRight/Left` conservan el último PWM distinto de cero; líneas 1464–1489 y 1578–1594: se escribe al puente solo si cambia el PWM o, en recta, el sentido | El estado guardado puede diferir de la salida real. Un nuevo movimiento puede omitir la activación de una rueda si coincide el PWM; el giro tampoco comprueba cambio de sentido. Forzar ambas salidas al iniciar y mantener una única representación de PWM, dirección y modo realmente aplicados. |
| M4 / Alta | Estado `DETENERSE`, líneas 784–820; entradas a movimientos, líneas 667–688 | STOP/obstáculo no limpian integrales ni cuentas anteriores de velocidad. Al reiniciar contadores puede resultar una diferencia negativa respecto a `rightPrevTicks/leftPrevTicks`, aunque las ISR solo suman. Unificar inicio, final y aborto de movimientos. |
| M5 / Alta | Líneas 1456–1459, 1493–1496, 1571–1575 y 1597–1600 | Se controla velocidad por rueda, pero se termina usando el promedio de las distancias. Una rueda puede adelantarse y la otra atrasarse sin corregir el error acumulado de trayectoria. Añadir seguimiento de distancia por rueda y corrección de diferencia de recorridos. |
| M6 / Alta | Mismas funciones: objetivo constante hasta cruzar la distancia/ángulo final | No hay rampa de aceleración ni reducción por distancia restante. La parada depende de inercia, rozamiento y carga. Añadir perfil de velocidad y medir recorrido posterior a ordenar cero. Esperar 500 ms tras apagar no compensa ese recorrido. |
| M7 / Media | Líneas 27–29 y 1458–1459: mismas ganancias para ambos motores; velocidad, PWM y geometría son constantes | Se guardan PPR separados, pero no ganancias por rueda, umbrales de motor ni geometría individual. Extender el perfil persistente donde las mediciones demuestren necesidad. |
| M8 / Alta | `advanceDesiredDistance` y `turnDesiredAngle` finalizan por distancia; no tienen tiempo máximo ni detección de falta de avance por rueda | Con motor o encoder fallando, el control puede seguir intentando avanzar; con una sola rueda funcionando el promedio incluso puede completar la orden con una trayectoria incorrecta. Agregar detección por rueda y aborto con diagnóstico. |

M1 no significa que un robot nunca pueda funcionar con las ganancias actuales: pueden haberse ajustado empíricamente a esa implementación. A 25 ms, la integral actual incorpora 40% de lo que incorporaría `error * dt`. Cambiar a tiempo real manteniendo `ki=2` multiplica su contribución por 2.5 a esa cadencia. `kd` predeterminado es cero, por lo que la derivada no influye salvo configuración distinta. Versionar las ganancias y volver a validarlas al corregir la fórmula.

M3 es una condición reproducible de lógica, no una afirmación de que todos los arranques fallen: después de parar, PWM físico = 0 y PWM recordado = último valor. Si el siguiente cálculo devuelve ese valor, la comprobación de cambio no escribe la salida. La coincidencia puede ocurrir solo en una rueda y provocar arranques desiguales.

M4 tiene una segunda parte: `previousTime` solo se actualiza dentro del movimiento. La primera muestra tras una pausa incluye el tiempo de reposo. Iniciar con contadores, referencias y tiempo coherentes evita mezclar ventanas de medición.

**3. Medición y adquisición**

- Las ISR de líneas 343–358 solo incrementan; las cuatro interrupciones usan `CHANGE` en líneas 548–552. Esto cuenta flancos de ambos canales, pero no decodifica dirección ni valida transiciones de cuadratura. No basta con copiar un PPR de catálogo que represente pulsos de un solo canal. Rebotes, inversión real y ruido pueden sumar recorrido aparente.
- Las lecturas de contadores, su copia a cuentas anteriores y su reinicio ocurren sin una captura conjunta protegida. Un pulso entre leer el delta y guardar la referencia puede quedar fuera de la estimación de velocidad. Tomar una instantánea coherente de ambos contadores y operar sobre ella; evitar resets concurrentes con las ISR.
- Con radio 22 mm y 820 cuentas/vuelta, una cuenta equivale aproximadamente a 0.1686 mm y a 6.74 mm/s en una ventana de 25 ms. A 90 mm/s hay unas 13.35 cuentas por muestra. Estos cálculos explican cierta variación de velocidad instantánea incluso sin fallo mecánico; no prueban ruido eléctrico. Evaluar filtrado con su retardo antes de aumentar ganancias o activar D.
- El encoder izquierdo B está en GPIO35 y se configura con `INPUT_PULLUP`. En el ESP32 clásico, GPIO34–39 no tienen resistencias internas de pull-up/pull-down. Comprobar el circuito del encoder y de la placa antes de atribuir una entrada flotante: puede haber resistencias externas o una salida activa. La misma limitación aplica a los trackers 34/39. [Documentación oficial de GPIO](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/peripherals/gpio.html).
- El código lee una señal digital de batería baja para el LED, pero no registra tensión de alimentación de motores. Medir tensión bajo carga permite comprobar si las diferencias vienen de batería, regulador, conectores o cableado; la señal binaria no permite cuantificarlas.

**4. Límites del PID actual**

El límite de integral ±255 evita crecimiento ilimitado, pero no detiene la acumulación cuando la salida ya está saturada. Con `ki=2`, el término integral puede alcanzar ±510, frente al máximo de salida de 200. Implementar anti-windup relacionado con la saturación real, por integración condicional o realimentación de saturación.

Con valores predeterminados y un arranque desde velocidad cero, el primer cálculo entrega aproximadamente PWM 181: `2*90 + 2*(90*0.01)`. El arranque es un escalón considerable, no una aceleración gradual. Esto puede hacer más visibles diferencias de tracción y carga.

Propuesta: empezar con PI por rueda, una orden PWM base obtenida de la respuesta medida del motor y una corrección por error. Mantener D desactivado inicialmente. Separar PWM necesario para arrancar del necesario para mantenerse moviendo; no reemplazar el piso 60 por otro piso universal. Escoger la velocidad común de la flota dentro del rango viable de sus motores, dejando margen para corregir errores sin permanecer en PWM máximo.

No se puede recomendar todavía un nuevo `kp`, `ki`, `kd`, PWM mínimo o velocidad definitiva: faltan curvas y pruebas bajo carga.

**5. El banco de pruebas no equivale al firmware operativo**

| Aspecto | Principal | BancoDePruebasPID |
|---|---|---|
| Velocidad objetivo | 90 mm/s | 120 mm/s |
| PPR | NVS, 820/820 si faltan claves | 834/834 fijos |
| Ganancias | NVS | 2/2/0 fijas |
| Corrección de distancia | Sin factor global | `correctionFactorLines=0.95` aplicado a rectas y giros |
| Bluetooth | BLE nativo ESP32 | ArduinoBLE |
| Trackers siempre activos | false | true |
| Telemetría de velocidad | No expuesta por el firmware principal | Objetivo, velocidad izquierda, velocidad derecha |

Evidencia: cabeceras de ambos sketches; banco líneas 186–191, 768, 803, 881 y 1085. El script `Lectura_y_Escritura_PID_Script.py` imprime esos tres datos; no almacena un registro CSV ni recibe PWM, integral o tensión. El firmware principal no crea la característica Notify que espera ese script.

Usar el mismo controlador y configuración para calibración y operación. Preferiblemente incorporar un modo de diagnóstico al principal para evitar mantener dos algoritmos divergentes. Registrar tiempo real de muestra, ID, estado, sentido, objetivos por rueda, cuentas, velocidades, PWM y saturación; guardar en la computadora, no escribir telemetría continuamente en NVS.

**6. Auditoría del calibrador de PPR**

`CalibracionMotores/CalibracionMotores.ino` sí utiliza cambios en A y B, compatible en cantidad de flancos con el principal. No se encontró una discrepancia automática ×4 entre estos dos sketches.

Sin embargo, calcula `PPR = pulsesCount * 2` al medir un recorrido supuesto de media vuelta (línea 285). La precisión depende de que los topes representen realmente 180°, de la holgura y de cómo detecta el rebote. Promedia diez mediciones y descarta valores ≤100, pero no comprueba dispersión ni un error sistemático de la plantilla.

Además, los pines M1/M2 izquierdos están intercambiados respecto del principal: 15/13 frente a 13/15. Eso no cambia por sí solo las cuentas por vuelta, pero exige verificar el sentido físico antes de trasladar medidas de arranque o dirección.

Validación propuesta: marcar la rueda/eje de salida, contar varias vueltas completas conocidas y dividir cuentas totales entre vueltas; repetir en ambos sentidos. Comparar contra el útil de media vuelta. Si da distinto según velocidad o sentido, investigar adquisición, topes y holgura antes de guardar el promedio. Con encoder y reductora idénticos se espera una relación de cuentas/vuelta similar; diferencias grandes requieren explicar el hardware o la medición.

**7. Preferences y calibración del pilot**

El principal ya crea únicamente claves faltantes en `Atta-Creds` (líneas 54–86). Conserva nombre, PPR derecho/izquierdo, ganancias compartidas y seis valores de servo. **Modificar un valor inicial en el código no cambia una clave existente:** al arrancar, `loadConfig()` carga el valor guardado.

Para el servo del pilot, usar el Monitor Serial a 115200 baudios con nueva línea, abrir `DEV <clave configurada>`, consultar `SHOW`, probar `TEST <ángulo>` y guardar el valor medido mediante `SET active <ángulo>`, `SET inactive <ángulo>` o `SET neutral <ángulo>`. Los marcadores entre `< >` se sustituyen por valores reales. `TEST` no guarda. El sketch separado `CalibracionServoHerramienta` tampoco guarda en NVS: solo permite encontrar posiciones.

Preferences conserva datos en memoria no volátil entre reinicios y cortes de energía. La carga habitual puede conservarlos si no borra o reemplaza NVS y el nuevo firmware respeta las mismas claves. No es una garantía frente a cualquier firmware: un borrado total o una escritura explícita los elimina/sustituye. Mantener `Erase All Flash Before Sketch Upload` desactivado y conservar el esquema de particiones para este flujo. [Preferences](https://docs.espressif.com/projects/arduino-esp32/en/latest/api/preferences.html), [opciones de carga de Espressif](https://docs.espressif.com/projects/arduino-esp32/en/latest/guides/tools_menu.html#erase-all-flash-before-sketch-upload).

Faltan validaciones: `parseFloatValue` acepta representaciones no finitas como `nan`/`inf` y la rama de PPR/PID no usa `isfinite`; al cargar tampoco se validan límites físicos. `begin` y `put*` no se comprueban, y `SHOW` imprime variables de RAM, no una relectura independiente. Se puede anunciar guardado sin verificar éxito. Tampoco se impide cambiar PPR/PID y escribir NVS durante un movimiento. Corregir validación, verificación de escritura y permitir calibración solamente detenido.

Perfil propuesto, todavía no implementado: versión de esquema y de controlador; PPR por rueda; radio efectivo por rueda; separación efectiva; PI/PID por rueda; arranque/mantenimiento por sentido; velocidad de recta/giro y aceleración/desaceleración. Conservar los campos de servo existentes. Guardar además una copia externa por ID para los 13 robots y validar la persistencia con reinicio y recarga normal del mismo firmware.

**8. Procedimiento para los 13 robots**

1. **Inventario y referencia.** Etiquetar los 13 Attas; respaldar `SHOW`, identificar firmware/librerías y anotar batería, motores/reductoras y ruedas. Ensayar inicialmente uno que funciona bien y dos que fallan de forma distinta. Registrar qué significa “mal”: curva, tirones, poco avance, exceso de distancia, giro incorrecto o fallo tras STOP.
2. **Separar carga y alimentación.** Misma superficie y condiciones de batería; comparar con pilot levantado y apoyado. Medir tensión de motores durante arranque y marcha. Revisar roce, rueda floja, engranajes y presión del pilot. Si solo falla dibujando, investigar carga del pilot antes de cambiar todas las ganancias.
3. **Validar encoders y PPR.** Vueltas completas y ambos sentidos; revisar cuentas en reposo y consistencia. Confirmar señales eléctricas si aparecen cuentas espurias. No calibrar velocidad sobre un contador dudoso.
4. **Corregir M1–M4 y añadir diagnóstico de M8.** Unificar estado y tiempo del controlador. Incorporar telemetría del mismo firmware operativo. Ejecutar regresión de avance→avance, avance→giro, giro→giro opuesto, STOP→nuevo movimiento y obstáculo→retroceso.
5. **Caracterizar cada motor.** Medir por rueda y sentido PWM de arranque, mantenimiento y velocidad en varios puntos, primero con ruedas elevadas para diagnóstico y luego en suelo con carga real. Usar duración y límites controlados; abortar ante falta de avance. La medida en vacío no es la calibración final.
6. **Ajustar PI y perfil de movimiento.** Comenzar por una velocidad sostenible con margen; ajustar respuesta por rueda, rampa y frenado. Observar error medio, oscilación y tiempo saturado. Una rueda saturada que no alcanza el objetivo requiere revisar carga/capacidad o reducir objetivo, no subir indiscriminadamente ganancias.
7. **Calibrar geometría y trayectoria.** Con PPR validado y frenado estable, medir distancias de varias longitudes y giros en ambos sentidos. Separar error proporcional al recorrido de un exceso casi constante al parar. Ajustar radios efectivos y separación; introducir corrección de recorrido entre ruedas. Los encoders no detectan por sí solos deslizamiento en el suelo.
8. **Extender a la flota y conservar resultados.** Aplicar el mismo firmware, guardar perfiles individuales y repetir una batería común de pruebas. No copiar ganancias o umbrales a los 13 sin comprobarlos.

**9. Pruebas de aceptación propuestas**

Estas metas son iniciales para acordar calidad de dibujo; no son prestaciones medidas ni garantías del hardware.

| Prueba | Medida / criterio inicial |
|---|---|
| Rectas 100, 300 y 500 mm, adelante y atrás | Cinco repeticiones; registrar error longitudinal y lateral; meta inicial en 500 mm: ambos ≤10 mm |
| Giros 90°, 180° y 360°, en ambos sentidos | Cinco repeticiones; meta inicial para 90°: error ≤3°; registrar también desplazamiento del centro |
| Cuadrado de 200 mm de lado, ambos sentidos | Error de cierre ≤15 mm como meta inicial; medir orientación final |
| Pilot arriba/abajo | Repetir la misma trayectoria y cuantificar degradación |
| STOP y reanudación, obstáculo y retroceso | Sin arranque unilateral ni muestra de velocidad negativa artificial; estado del control reiniciado |
| Persistencia | Mismos parámetros después de apagar/encender y recargar firmware sin borrar NVS |
| Velocidad estable | Meta inicial: error medio ≤5%; sin saturación sostenida; evaluar oscilación considerando cuantización |

En cada ensayo registrar ID, configuración, condición de batería, superficie, pilot, orden, resultado real, media y dispersión. La repetibilidad importa: un sesgo estable permite calibrar geometría; un resultado muy variable exige resolver control, alimentación, adquisición o tracción.

**10. Orden recomendado de implementación**

Primero, coherencia de inicio/parada, tiempo real del PI y diagnóstico por rueda. Después, telemetría y perfiles persistentes validados. Luego, caracterización de motores, compensación de arranque, rampas y frenado. Finalmente, geometría, corrección de trayectoria y validación de los 13 Attas. Priorizar un buen comportamiento repetible antes de afinar precisión de dibujo.

Esta auditoría se verificó contra el código local y mediante cálculos de unidades, cuantización y salida inicial del controlador. No se compiló ni ejecutó el firmware; la magnitud real de cada efecto queda pendiente de mediciones físicas.

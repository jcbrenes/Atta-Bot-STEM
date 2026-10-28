---
tags: [funcion]
archivo: CalibracionMotores.ino
linea: 205
---
# CalibracionMotores.loop

> Atiende los comandos del Monitor Serie y avanza la máquina de estados de la medición.
>
> estado 0 (reposo): motor apagado, cuentas en cero.
> estado 1 (preparación): lleva el brazo contra un tope. En la primera medición elige el PWM
>   de medición (pwmMotores) a partir del PWM con que arrancó el motor (ver arranque).
> estado 2 (medición): mueve el brazo lento hasta el otro tope contando pulsos. Termina cuando
>   pasan waitTime ms sin pulsos o el encoder indica cambio de sentido (rebote); PPR = pulsos·2.
>   Repite hasta tener numMedicionesPorRealizar mediciones válidas e imprime el promedio.

**Archivo:** [[CalibracionMotores.ino]] · línea 205

```cpp
void loop()
```

## Llama a
- [[CalibracionMotores.arranque]]

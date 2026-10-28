---
tags: [funcion]
archivo: MotionRuntime.h
linea: 219
---
# runMotion

> Ejecuta una recta o un giro sin bloquear; la máquina de estados la llama en cada vuelta.
>
> En la primera llamada (sin maniobra activa) arranca la maniobra con motion.begin; en las
> siguientes avanza el control con motion.update y aplica el PWM. Al terminar un giro imprime
> TURN_RESULT (COMPLETE, OVERSHOOT o INCOMPLETE) con el ángulo estimado por los encoders, que
> no es una medición del chasis. Si hay paro_emergencia no hace nada; si la configuración no
> está lista o hay un fallo pendiente, lo informa con reportMotionFault.
>
> @param amount mm (recta) o grados (giro); negativo = atrás o a la izquierda.
> @param turning true para giro.
>
> @return true cuando la maniobra terminó (bien o con fallo) y se puede pasar a DETENERSE.

**Archivo:** [[MotionRuntime.h]] · línea 219

```cpp
bool runMotion(float amount, bool turning)
```

## Llama a
- [[Controller.begin]]
- [[Controller.fail]]
- [[Controller.leftReverse]]
- [[Controller.rightReverse]]
- [[Controller.update]]
- [[applyMotorOutputs]]
- [[reportMotionFault]]
- `readEncoderCounts`

## La llaman
- [[advanceDesiredDistance]]
- [[turnDesiredAngle]]

## Emite
- [[Mensaje TURN_RESULT]]

## Campos SET que usa
- [[SET track]]

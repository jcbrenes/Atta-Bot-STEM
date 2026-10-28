---
tags: [metodo]
archivo: MotionControl.h
linea: 419
---
# Controller.update

> Un paso de control; se llama en cada vuelta de loop() y actúa cada 25 ms o más.
>
> Orden: revisa tiempos (más de 250 ms entre pasos → Timing; maniobra más larga que timeoutMs
> → Timeout), mide las dos ruedas, marca las que llegaron y, cuando llegan las dos, termina
> (recta) o pasa a asentamiento (giro). Si no, revisa trabas (stallMs sin pulsos → Stall),
> reparte la velocidad entre las ruedas según cuál va adelantada (syncGain) y calcula el PWM
> de cada una.
>
> Asentamiento de giros: con PWM en cero sigue midiendo hasta que pasen 500 ms y 150 ms sin
> pulsos nuevos; entonces marca turnSettled y si alguna rueda pasó objetivo + tolerance,
> turnOvershoot. Si en 2 s no se quedan quietas → Settling. Que no haya pulsos no prueba que
> el chasis no se deslizó.
>
> @param now millis() actual.
> @param r Cuenta actual del encoder derecho.
> @param l Cuenta actual del encoder izquierdo.
> @param c Perfil de movimiento.
>
> @return true si en esta llamada cambió algo (hay que aplicar right.pwm y left.pwm).

**Archivo:** [[MotionControl.h]] · línea 419

```cpp
bool update(uint32_t now, uint32_t r, uint32_t l, const MotionConfig& c)
```

## Llama a
- [[Controller.fail]]
- [[Controller.leftReverse]]
- [[Controller.reference]]
- [[Controller.rightReverse]]
- [[Controller.sample]]
- [[Controller.stop]]
- [[wheelPWM]]
- `clamp`

## La llaman
- [[auditar_giros.main]]
- [[runMotion]]

## Campos SET que usa
- [[SET filterms]]
- [[SET maxpwm]]
- [[SET speed]]
- [[SET stallms]]
- [[SET startms]]
- [[SET sync]]
- [[SET tolerance]]
- [[SET turnspeed]]

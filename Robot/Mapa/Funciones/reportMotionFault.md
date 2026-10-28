---
tags: [funcion]
archivo: MotionRuntime.h
linea: 160
---
# reportMotionFault

> Informa un fallo del controlador por Serial (FAULT,<motivo>) y decide cómo seguir.
>
> Si el fallo es recuperable (rueda trabada, tiempo agotado, control atrasado o giro sin
> asentar) y viene de un programa BLE normal, se omite solo esa instrucción: se despeja el
> fallo, se pasa a DETENERSE y el programa sigue con la siguiente (PROGRAM_CONTINUE). Así un
> chico no pierde todo el programa porque una rueda rozó algo. En cualquier otro caso (fallo de
> configuración, movimiento de la consola, prueba MOTOR, STOP) se detiene todo con
> requestMotionStop y el fallo queda hasta un CLEAR.

**Archivo:** [[MotionRuntime.h]] · línea 160

```cpp
void reportMotionFault()
```

## Llama a
- [[Controller.clear]]
- [[requestMotionStop]]
- [[stopMotion]]

## La llaman
- [[runMotion]]
- [[updateMotorTest]]

## Emite
- [[Mensaje FAULT]]
- [[Mensaje PROGRAM_CONTINUE]]

## Estados que asigna
- [[Estado DETENERSE]]

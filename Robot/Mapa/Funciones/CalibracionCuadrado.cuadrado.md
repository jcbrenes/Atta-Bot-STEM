---
tags: [funcion]
archivo: CalibracionCuadrado.h
linea: 56
---
# CalibracionCuadrado.cuadrado

> Simula dónde termina el lápiz tras el cuadrado, con un robot que tiene los errores e.
>
> Cuatro veces: avanzar lado mm y girar 90°; el firmware manda por rueda el arco que calcula
> con su track, pero las ruedas recorren kR y kL veces eso, sobre la vía real.
>
> @param e Errores del robot real.
> @param trackFirmware track configurado en el firmware, mm.
> @param lado Lado del cuadrado, mm.
> @param horario true si los giros son a la derecha.
> @param lapiz mm del lápiz por delante del centro del eje (negativo si va detrás).
>
> @return Posición final del lápiz respecto al punto de partida (x adelante, y a la izquierda).

**Archivo:** [[CalibracionCuadrado.h]] · línea 56

```cpp
inline Punto cuadrado(const Errores& e, double trackFirmware, double lado, bool horario, double lapiz)
```

## Llama a
- [[CalibracionCuadrado.tramo]]

## La llaman
- [[CalibracionCuadrado.estimar]]

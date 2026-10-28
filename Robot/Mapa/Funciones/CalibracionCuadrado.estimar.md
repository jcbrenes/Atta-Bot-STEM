---
tags: [funcion]
archivo: CalibracionCuadrado.h
linea: 91
---
# CalibracionCuadrado.estimar

> Estima los errores del robot a partir de dónde terminó el cuadrado en cada sentido.
>
> Ajuste por mínimos cuadrados (Gauss-Newton) de 2 incógnitas con 4 mediciones (x e y de cada
> sentido): delta = (kR − kL)/2 con kR + kL = 2 (la escala media no cambia, así las rectas ya
> calibradas se mantienen) y la vía efectiva. La vía da el mismo error en ambos sentidos; la
> diferencia entre ruedas cambia de signo.
>
> @param horario Punto final medio de las corridas en sentido horario, mm.
> @param antihorario Punto final medio en sentido antihorario, mm.
> @param trackFirmware track configurado, mm.
> @param lado Lado del cuadrado, mm.
> @param lapiz Distancia del lápiz al eje, mm.
>
> @return Errores estimados, residuo RMS (lo que el modelo no explica) y si convergió.

**Archivo:** [[CalibracionCuadrado.h]] · línea 91

```cpp
inline Resultado estimar(Punto horario, Punto antihorario, double trackFirmware, double lado, double lapiz)
```

## Llama a
- [[CalibracionCuadrado.cuadrado]]

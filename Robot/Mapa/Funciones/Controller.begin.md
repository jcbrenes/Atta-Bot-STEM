---
tags: [metodo]
archivo: MotionControl.h
linea: 345
---
# Controller.begin

> Prepara una maniobra nueva a partir de la orden.
>
> En una recta el objetivo por rueda es |amount| mm. En un giro es el arco que recorre cada
> rueda alrededor del centro: |amount|·pi·track/360 mm. El signo de amount solo define el
> sentido (reverse). Calcula también el tiempo máximo: 5 s más 4 veces el tiempo nominal a
> velocidad de crucero (en giros contando el tramo lento), entre 5 y 120 s.
>
> No arranca si hay un fallo sin despejar; si la configuración o la orden es inválida, deja
> Fault::Config. Una orden menor que tolerance no mueve nada (active queda en false).
>
> @param amount Distancia en mm (recta) o ángulo en grados (giro); negativo = atrás/izquierda.
> @param turn true para giro.
> @param now millis() actual.
> @param r Cuenta actual del encoder derecho (se toma como origen).
> @param l Cuenta actual del encoder izquierdo.
> @param c Perfil de movimiento.
> @param turnConfig Perfil de giro.
>
> @return true si quedó una maniobra activa.

**Archivo:** [[MotionControl.h]] · línea 345

```cpp
bool begin(float amount, bool turn, uint32_t now, uint32_t r, uint32_t l, const MotionConfig& c, const TurnConfig& turnConfig = TurnConfig{})
```

## Llama a
- [[Controller.fail]]
- [[Controller.stop]]
- [[validConfig]]
- [[validTurnConfig]]
- `clamp`

## La llaman
- [[auditar_giros.main]]
- [[runMotion]]

## Campos SET que usa
- [[SET speed]]
- [[SET tolerance]]
- [[SET track]]
- [[SET turnapproach]]
- [[SET turnspeed]]
- [[SET turnzone]]

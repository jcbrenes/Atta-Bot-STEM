---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 859
---
# validacionIf

> Decide si se ejecuta la rama IF o se salta hasta ELSE/IFFIN.
>
> Si ambas condiciones se cumplen, marca ejecutandoRamaIf[anidamientoIF] para que un
> ELSE posterior sepa que la rama ya se ejecutó. Si no, activa ignorarHastaElse y guarda
> el nivel de anidamiento actual para saltar solo hasta la marca correspondiente.
>
> @param condicionSensorIzquierdo true si el tracker izquierdo cumple la condición pedida.
> @param condicionSensorDerecho true si el tracker derecho cumple la condición pedida.

**Archivo:** [[CodigoESP32.ino]] · línea 859

```cpp
void validacionIf(bool condicionSensorIzquierdo, bool condicionSensorDerecho)
```

## La llaman
- [[condicionesIF]]

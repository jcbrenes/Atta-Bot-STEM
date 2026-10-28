---
tags: [funcion]
archivo: CodigoESP32.ino
linea: 1143
---
# Interpreta_mensajeBLE

> Traduce el programa que manda la app a la lista de instrucciones del robot.
>
> El mensaje se lee en bloques de 5 caracteres. Hay bloques de control de 5 letras (ATINI
> inicio, ATFIN fin del programa, PARAR, y marcas sin valor como CIFIN, OBINI/OBFIN,
> HEINI/HEFIN, IFFIN, WHFIN) y bloques de 2 letras + 3 dígitos de valor (AV avanzar y RE
> retroceder en cm, GD/GI girar en grados, CI ciclo con repeticiones, IF/EL/WH condiciones
> de los trackers, HE acción de garra/grúa). Cada instrucción se guarda en
> lista_instrucciones como [constante inst_..., valor]; ATFIN fija inst_final y al terminar
> inst_actual vuelve a 0 para que LEE_MEMORIA empiece desde el principio.
> Ejemplo: ATINIAV020GD030CI003RE010GI090CIFINATFIN.
>
> @param mensaje Mensaje completo, de hasta 500 caracteres (onWrite descarta los más largos).

**Archivo:** [[CodigoESP32.ino]] · línea 1143

```cpp
void Interpreta_mensajeBLE (string mensaje)
```

## La llaman
- [[leerBluetooth]]

---
tags: [funcion]
archivo: auditar_giros.cpp
linea: 16
---
# auditar_giros.main

> Simula giros con el controlador real y una planta hipotética e imprime un CSV.
>
> Barre respuesta de la planta, ángulo y período de control, y reporta ángulo al cortar,
> al terminar y 500 ms después, para ver cuánto se pasa el giro por inercia. Sirve para
> comparar cambios del controlador, no para calibrar un robot. Ver Auditoria_giros_V2.md.
>
> @return 0.

**Archivo:** [[auditar_giros.cpp]] · línea 16

```cpp
int main()
```

## Llama a
- [[Controller.begin]]
- [[Controller.update]]
- [[faultName]]

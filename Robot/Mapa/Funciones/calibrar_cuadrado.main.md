---
tags: [funcion]
archivo: calibrar_cuadrado.cpp
linea: 57
---
# calibrar_cuadrado.main

> Lee el archivo de mediciones, estima los errores e imprime las líneas SET corregidas.
>
> El archivo acepta la salida de SHOW tal cual (toma rppr, lppr, track y device) más las
> líneas lado, lapiz, horario <x> <y> y antihorario <x> <y>. Ver Calibracion_cuadrado.md.
>
> @param argc Debe ser 2.
> @param argv argv[1] es la ruta del archivo.
>
> @return 0 si calculó la corrección; distinto de 0 si faltan datos o no convergió.

**Archivo:** [[calibrar_cuadrado.cpp]] · línea 57

```cpp
int main(int argc, char** argv)
```

## Llama a
- [[Serie.dispersion]]
- [[Serie.media]]
- [[calibrar_cuadrado.minusculas]]

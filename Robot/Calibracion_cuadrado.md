# Calibración con la prueba del cuadrado

Calibrar solo con giros sueltos mezcla dos errores distintos en `track`:

- **Vía efectiva** (`track`): hace que *todos* los giros se queden cortos o se pasen.
- **Diferencia entre ruedas** (proporción `rppr`/`lppr`): curva las rectas.

Un cuadrado recorrido en ambos sentidos los separa (método UMBmark, Borenstein y
Feng 1996). La vía produce el mismo error en horario y antihorario; la curva
de las rectas cambia de signo. La calculadora ajusta ambos y conserva la escala
media de distancia, así que no deshace la calibración de las rectas.

## Material

- Superficie plana de al menos 70 × 70 cm, la misma que se usará en clase.
- Cinta de papel, regla o cinta métrica, lápiz del robot con papel debajo.

## Procedimiento por robot

1. Anote los valores actuales: en modo DEV, `SHOW`, y copie la salida a un
   archivo de texto (se puede pegar entera).
2. Mida `lapiz`: distancia en mm desde la punta del lápiz hasta la línea que une
   los centros de las dos ruedas; positiva si el lápiz está por delante.
3. Pegue una tira de cinta recta en el piso: será el eje **x**. Coloque el robot
   con el lápiz sobre un punto marcado de la cinta y mirando a lo largo de ella.
4. Programa en la app, **horario**: `Repetir 4 { Avanzar 50 ; Girar derecha 90 }`
   con lápiz abajo. Al terminar, mida dónde quedó la punta del lápiz respecto al
   punto inicial:
   - `x`: a lo largo de la cinta, **+** hacia donde miraba el robot al empezar.
   - `y`: perpendicular a la cinta, **+** hacia la **izquierda** del robot al empezar.
5. Repita 3 veces horario y 3 veces **antihorario** (`Girar izquierda 90`),
   siempre desde el mismo punto y orientación.
6. Escriba las mediciones en el archivo (ver `tools/ejemplo_cuadrado.txt`):

   ```
   robot Atta-A-02
   SET rppr 822.000000
   SET lppr 808.000000
   SET track 125.000000
   lado 500
   lapiz 0
   horario      -64  -87
   antihorario  -10   11
   ```

7. Ejecute la calculadora y aplique las tres líneas `SET` que propone. Después
   `VERIFY` y un cuadrado en cada sentido para confirmar. Si mejora pero no
   alcanza, repita el ciclo una vez más con los valores nuevos.

## Compilar y ejecutar

Desde la raíz del repositorio:

```sh
g++ -std=c++17 -Wall -Wextra Robot/tools/calibrar_cuadrado.cpp -o /tmp/calibrar-cuadrado
/tmp/calibrar-cuadrado Robot/tools/ejemplo_cuadrado.txt
```

## Cómo leer el resultado

- **Giros**: cuántos grados gira realmente cuando se piden 90.
- **Rectas**: cuánto se desvía lateralmente por metro recorrido.
- **No explicado por el modelo**: error que la calibración no puede quitar
  (deslizamiento, rueda loca, roce del lápiz, medición). Si es grande respecto
  al cierre medido, la calculadora avisa: corregir ese robot no ayudará mucho.
- **Dispersión**: diferencia típica entre corridas del mismo sentido. Es el
  error aleatorio del robot; ninguna constante lo elimina.
- Un aviso de **corrección muy grande** suele indicar signos de `x`/`y`
  invertidos o un problema de hardware (encoders, motores), no de calibración.

## Validación

`tests/square_calibration_test.cpp` ejecuta el controlador real del firmware
sobre un chasis simulado con ruedas y vía distintas a las configuradas, y
comprueba que la corrección estimada cierra el cuadrado (215,6 → 2,5 mm en la
simulación). No modela deslizamiento ni el roce del lápiz; la validación física
es el cuadrado de confirmación del paso 7.

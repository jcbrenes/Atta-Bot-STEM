# Estándar de código para contribuciones a Atta-Bot STEM

_Elaborado por Juan Carlos Brenes_

Esta es una guía de formato y documentación para el código en C++ del proyecto PROE.
Se solicita seguir esta guía para tener código que sea leíble y entendible por otras personas. Esto ayuda a que el proyecto más sostenible en el tiempo.


# Variables:

- El nombre inicia siempre con minúscula

- Utilizar nombres descriptivos. No importa que sean largos. Ejemplo: 
```sh
contadorPulsosMotorDerecho // **bueno**
sum, j, pos // **malo**
```

- Si la variable nunca va a ser modificada en el código, se debe declarar como const. Esto ayuda al compilador a hacer el código 
más eficiente. Ejemplo: 
```sh
const int velocidadRefDerecha
```

- NO deben aparecer en el código constantes (números). Esos números se entienden en el momento pero se olvidan luego de 48 horas. Se 
debe crear una variable al inicio del código tipo constante. Ejemplo: 
```sh
if (contadorPulsosMotorDerecho > 100) // **malo** 
if (contadorPulsosMotorDerecho > velocidadRefDerecha) // **bueno**
```


# Funciones y clases:

- El nombre inicia con mayúscula

- Utilizar nombres descriptivos.

- Cada función debe tener una caja de descripción de lo que hace la función. Se pone arriba del nombre de la función. Se especifican los parámetros y lo que retorna la función.
Este formato permite que las herramientas de documentación lo reconozcan. Ejemplo:
```sh
//******************************************************************************************************************
//Función que incrementa un contador con cada pulso del enconder. (Una frase resumen) 
//
//Se puede poner un párrafo que explique en detalle la función (opcional)
//
//@param contadorPulsosMotorDerecho Variable que lleva el conteo de los pulsos de encoder.
//@param incrementoPulso Variable que especifica la magnitud del incremento de pulsos.
//
//@return contadorIncrementado Retorna un entero que es el contador general de pulsos mas el incremento del encoder. (No poner si es void)
//******************************************************************************************************************
int IncrementoContador (int contadorPulsosMotorDerecho, int incrementoPulso){
  int contadorIncrementado = contadorPulsosMotorDerecho + incrementoPulso);
  return contadorIncrementado;
}
```

# Otras consideraciones:

- Si los nombres son descriptivos, el código se puede entender por si solo. Igual se pueden agregar comentarios extras en el código.

- Hacer los comentarios con // y no con /* */ , esto facilita la vida al hacer debug.

- Se recomienda usar espacios para hacer el código más leíble. Ejemplo: 
```sh
buffer=contador+indice;  //  **enredado**
buffer = contador + indice;  // **más claro**
```

- Recordar mantener la indentación. Usar solamente tab para indentar. No usar espacios.

- Utilizar siempre las llaves {} en if, for, while, etc. A pesar de que cuando se usa una sola línea esto funcione, se pueden tener 
muchos errores por no usar las llaves.


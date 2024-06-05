# Lista de mensajes

Distribución de los mensajes:
- Los mensajes se componen de 7 valores separados por ";" y el orden de lectura es:
	- ID: número de identificación del robot
	- Coordenada X
	- Coordenada Y
	- Orientación
	- Tipo de mensaje
	- Distancia a obstaculo: para sensor sharp
	- Ángulo de obstaculo: para sensor sharp

El tipo de mensaje indica a que se refiere el resto de la información en el mensaje.

Lista de tipos de mensajes que se van a recibir en la base:
- 0: Identifica posición sin obstaculo
- 1: Sharp, da medida de distancia y ángulo
- 2: IR frontal
- 3: IR derecho
- 4: IR izquierdo
- 5: Temperatura
- 6: Batería baja 
- 15: El Atta completó la función avanzarCoordenada y deja de avanzar
- 20: Medición de distancia inicial para coordinación de coordenadas
- 40: Falla de magnetómetro
- 41: Falla de MPU
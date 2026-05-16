import asyncio
from bleak import BleakClient

# UUIDs idénticos a los del código de tu ESP32
RX_CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8" # Buzón para enviar comandos al robot (Write)
TX_CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a9" # Buzón para leer telemetría (Notify)

# Esta función se activa automáticamente cada vez que el ESP32 manda datos (cada 50ms)
def handle_telemetry(sender, data):
    # La data llega como bytes, así que la decodificamos a texto
    texto = data.decode('utf-8')
    # Aquí en un futuro puedes separar el texto por las comas para meterlo en matplotlib
    print(f" -> [Datos PID] Objetivo, Izquierda, Derecha: {texto}")

async def run(address):
    print(f"Buscando e intentando conectar a {address}...")
    
    # Inicia la conexión con el robot
    async with BleakClient(address) as client:
        print("¡Conectado exitosamente al Atta STEM Lab!")
        
        # Le decimos al ESP32 que queremos empezar a recibir la telemetría
        await client.start_notify(TX_CHARACTERISTIC_UUID, handle_telemetry)
        print("Suscrito a la telemetría. Puedes empezar a operar.")
        print("-" * 50)
        
        # Bucle infinito para recibir texto tuyo en la terminal y mandarlo
        loop = asyncio.get_event_loop()
        while True:
            # await loop.run_in_executor permite usar el input() sin congelar la recepción de datos
            comando = await loop.run_in_executor(None, input, "Escribe un comando (ej. ATINIAV050ATFIN) o 'salir': \n")
            
            if comando.lower() == 'salir':
                break
            
            if comando:
                # Transforma tu texto a bytes y se lo envía a la característica original de la máquina de estados
                await client.write_gatt_char(RX_CHARACTERISTIC_UUID, comando.encode('utf-8'))
                print(f"[PC] Comando enviado: {comando}")

        # Si sales del bucle, desconecta la telemetría por orden
        await client.stop_notify(TX_CHARACTERISTIC_UUID)
        print("Desconectando...")

if __name__ == "__main__":
    # IMPORTANTE: Reemplaza esto con la dirección MAC de tu ESP32
    # En Windows/Linux tiene formato "XX:XX:XX:XX:XX:XX"
    # En macOS es un UUID largo que te da el sistema
    DIRECCION_MAC_ROBOT = "XX:XX:XX:XX:XX:XX" 
    
    asyncio.run(run(DIRECCION_MAC_ROBOT))

#!/usr/bin/env python3
"""Consola Serial y captura CSV del firmware V2. Requiere pyserial."""
import argparse
import csv
import getpass
from pathlib import Path
import queue
import threading
import time

COLUMNS = "record,ms,device,mode,reverse,dt_s,right_ticks,left_ticks,right_mm,left_mm,right_ref,left_ref,right_speed,left_speed,right_pwm,left_pwm,right_integral,left_integral,right_saturated,left_saturated,fault".split(",")


def main():
    """Abre la consola DEV del Atta por USB y guarda la telemetría en CSV.

    Pide la clave DEV sin mostrarla, entra en modo desarrollador y envía SHOW, VERIFY y
    TELEMETRY ON. Cada fila "T,..." que llega se escribe en el CSV (columnas de COLUMNS, las
    mismas de emitTelemetry en MotionRuntime.h); el resto de lo que imprime el robot va a
    pantalla y a un .log junto al CSV, igual que los comandos tecleados (MOVE 300, TURN 90,
    MOTOR R F 80 1000...). Con "salir" o Ctrl+C manda STOP, TELEMETRY OFF y EXIT.
    No sobrescribe ensayos: si el CSV o su .log ya existen, se niega.

    Parámetros (línea de comandos):
    - --port: puerto serie del Atta (/dev/ttyUSB0, COM3).
    - --output: CSV nuevo; el .log se crea con el mismo nombre.
    """
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", required=True, help="Puerto, por ejemplo /dev/ttyUSB0 o COM3")
    parser.add_argument("--output", type=Path, required=True, help="Archivo CSV nuevo; también crea un .log")
    args = parser.parse_args()
    try:
        import serial
    except ImportError:
        parser.error("Instale pyserial: python3 -m pip install pyserial")
    if args.output.exists() or args.output.with_suffix(".log").exists():
        parser.error("El CSV o su .log ya existe; use otro nombre para conservar el ensayo.")
    password = getpass.getpass("Clave DEV: ")
    commands = queue.Queue()

    def keyboard():
        """Lee el teclado en un hilo aparte y encola cada línea para enviarla al robot."""
        try:
            while True:
                text = input()
                commands.put(text)
                if text.lower() == "salir":
                    return
        except EOFError:
            commands.put("salir")

    with args.output.open("x", newline="", encoding="utf-8") as output, \
            args.output.with_suffix(".log").open("x", encoding="utf-8") as log, \
            serial.Serial(args.port, 115200, timeout=0.05, write_timeout=1) as port:
        writer = csv.writer(output)
        writer.writerow(COLUMNS)
        # Abrir USB puede reiniciar la placa; esperar a que termine setup/BLE.
        time.sleep(3)
        port.write(f"DEV {password}\nSHOW\nVERIFY\nTELEMETRY ON\n".encode())
        print("Conectado. Escriba comandos (HELP, MOVE 300, STOP...). 'salir' detiene y cierra.")
        threading.Thread(target=keyboard, daemon=True).start()
        pending = bytearray()
        try:
            while True:
                if not commands.empty():
                    command = commands.get_nowait()
                    if command.lower() == "salir":
                        break
                    port.write((command + "\n").encode())
                    log.write(f"> {command}\n")
                    log.flush()
                pending.extend(port.read(port.in_waiting or 1))
                while b"\n" in pending:
                    raw, _, pending = pending.partition(b"\n")
                    line = raw.decode("utf-8", errors="replace").strip()
                    if line.startswith("T,"):
                        row = next(csv.reader([line]))
                        if len(row) == len(COLUMNS):
                            writer.writerow(row)
                            output.flush()
                        else:
                            log.write(f"INVALID_TELEMETRY {line}\n")
                    else:
                        print(line)
                        log.write(line + "\n")
                        log.flush()
        except KeyboardInterrupt:
            pass
        finally:
            port.write(b"STOP\nTELEMETRY OFF\nEXIT\n")
            port.flush()


if __name__ == "__main__":
    main()

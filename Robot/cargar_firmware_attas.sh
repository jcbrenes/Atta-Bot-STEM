#!/usr/bin/env bash
# Compila el firmware una sola vez y carga el mismo binario a los Attas por USB,
# sin pasar por Arduino IDE. Escribe lo mismo que "Subir" del IDE (bootloader,
# particiones, boot_app0 y app) y NO borra la NVS, así que la calibración
# (líneas SET) de cada robot se conserva.
#
# Uso (desde la raíz del repositorio):
#   bash Robot/cargar_firmware_attas.sh compilar   # genera Robot/Binarios/
#   bash Robot/cargar_firmware_attas.sh            # carga a todos los conectados
#   bash Robot/cargar_firmware_attas.sh continuo   # carga cada Atta que se conecte
#   bash Robot/cargar_firmware_attas.sh configurar [campo=valor ...]
#       sin cargar firmware: respaldo SHOW + PERFIL + valores extra a cada Atta
#       que se conecte (p. ej. track=120 para todos, una sola vez)
set -u

FQBN="esp32:esp32:esp32"
BAUD=921600
# Se fijan en cada Atta al cargar: los valores por defecto del firmware solo
# aplican a un robot que nunca guardó perfil. No toca la calibración propia de
# cada robot (PPR, radios, track, start, servos).
PWM_HZ=20000
# Perfil validado en V-02 el 2026-10-15 (octágono y cuadrado con lápiz).
PERFIL="speed=150 turnspeed=120 accel=350 decel=400 maxpwm=230 turnaccel=120 turndecel=120
  turnapproach=40 turnzone=5 kp=2.1 ki=2.1 kd=0"
SKETCH="Robot/CodigoESP32"
RESPALDOS="Robot/Respaldos_SHOW"  # SHOW de cada Atta antes de aplicar PERFIL
BIN="Robot/Binarios"
CLI=/opt/arduino-ide/resources/app/lib/backend/resources/arduino-cli
CORE=$(ls -d ~/.arduino15/packages/esp32/hardware/esp32/*/ | tail -n1)
ESPTOOL=$(ls -d ~/.arduino15/packages/esp32/tools/esptool_py/*/ | tail -n1)esptool

puertos() {
  ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null
}

compilar() {
  rm -rf "$BIN" && mkdir -p "$BIN"
  "$CLI" compile --fqbn "$FQBN" --output-dir "$BIN" "$SKETCH" || exit 1
  cp "${CORE}tools/partitions/boot_app0.bin" "$BIN/"
  rm -f "$BIN"/*.merged.bin "$BIN"/*.map  # el merged ocupa todo el flash y borraría la NVS
  { echo "commit: $(git rev-parse --short HEAD)"
    git diff --quiet HEAD -- "$SKETCH" || echo "con cambios sin commitear en $SKETCH"
    echo "compilado: $(date '+%F %T')"; } > "$BIN/version.txt"
  echo "Binarios listos en $BIN/"
  cat "$BIN/version.txt"
}

cargar() {  # $1 = puerto
  "$ESPTOOL" --chip esp32 --port "$1" --baud "$BAUD" \
    --before default-reset --after hard-reset write-flash -z \
    --flash-mode keep --flash-freq keep --flash-size keep \
    0x1000 "$BIN/CodigoESP32.ino.bootloader.bin" \
    0x8000 "$BIN/CodigoESP32.ino.partitions.bin" \
    0xe000 "$BIN/boot_app0.bin" \
    0x10000 "$BIN/CodigoESP32.ino.bin" > "/tmp/attas_$(basename "$1").log" 2>&1 || return 1
  fijar_config "$1" >> "/tmp/attas_$(basename "$1").log" 2>&1
}

configurar() {  # $1 = puerto
  fijar_config "$1" > "/tmp/attas_$(basename "$1").log" 2>&1
}

# Aplica PERFIL y pwmhz por serie; reinicia para aplicar pwmhz y falla si el
# arranque no lo confirma.
fijar_config() {  # $1 = puerto
  python3 - "$1" "$PWM_HZ" "$RESPALDOS" $PERFIL <<'PY'
import os, re, serial, sys, time
port, hz, respaldos = sys.argv[1], int(sys.argv[2]), sys.argv[3]
perfil = [a.split("=") for a in sys.argv[4:]]
s = serial.Serial(port, 115200, timeout=0.5)
s.dtr = False; s.rts = False
def cmd(c, t=1.0):
    s.write(c.encode() + b"\n"); time.sleep(t)
    return s.read(4000).decode(errors="replace")
def reiniciar():
    s.rts = True; time.sleep(0.2); s.rts = False; time.sleep(3.5)
    return s.read(8000).decode(errors="replace")
def pwm_ok(log):  # el divisor del temporizador redondea (15000 -> 15001 Hz)
    m = re.search(r"PWM motores: (\d+) Hz", log)
    return bool(m) and abs(int(m.group(1)) - hz) <= 0.02 * hz
arranque = reiniciar()
if "SHOW" not in cmd("DEV AttaDev2026", 1.2): sys.exit("DEV no aceptado")
show = cmd("SHOW", 1.5)  # respaldo antes de cambiar nada
nombre = (re.search(r"device=(\S+)", show) or re.search(r"(Atta\S*)", arranque))
nombre = nombre.group(1) if nombre else os.path.basename(port)
os.makedirs(respaldos, exist_ok=True)
archivo = os.path.join(respaldos, f"{nombre}_{time.strftime('%Y-%m-%d_%H%M%S')}.txt")
open(archivo, "w").write(show)
print(f"Respaldo SHOW: {archivo}")
for campo, valor in perfil + ([] if pwm_ok(arranque) else [("pwmhz", hz)]):
    r = cmd(f"SET {campo} {valor}")
    print(f"SET {campo} {valor} -> {r.strip()}")
    if "Guardado y verificado" not in r: sys.exit(f"SET {campo} falló")
if "VERIFY OK" not in cmd("VERIFY"): sys.exit("VERIFY falló")
cmd("EXIT")
if not pwm_ok(arranque): arranque = reiniciar()
print(arranque)
sys.exit(0 if pwm_ok(arranque) else "PWM no confirmado al arrancar")
PY
}

if [ "${1:-}" = "compilar" ]; then
  compilar
  exit 0
fi

ACCION=cargar
if [ "${1:-}" = "configurar" ]; then
  shift
  PERFIL="$PERFIL $*"  # los valores extra van después y prevalecen
  ACCION=configurar
  echo "Configurar sin cargar firmware: $PERFIL"
  set -- continuo
elif [ ! -f "$BIN/CodigoESP32.ino.bin" ]; then
  echo "No hay binarios. Corre primero: bash $0 compilar" >&2
  exit 1
else
  echo "Firmware: $(head -n1 "$BIN/version.txt")"
fi

if [ "${1:-}" = "continuo" ]; then
  echo "Conecta los Attas uno por uno (Ctrl+C para terminar)."
  declare -A hecho
  n=0
  while true; do
    actuales=$(puertos)
    for p in $actuales; do
      [ -n "${hecho[$p]:-}" ] && continue
      # udev asigna permisos al puerto un instante después de crearlo.
      [ -r "$p" ] && [ -w "$p" ] || continue
      sleep 1
      hecho[$p]=1
      echo -n "[$p] $ACCION... "
      if "$ACCION" "$p"; then n=$((n+1)); echo "OK (#$n) $(grep -ao 'Respaldo SHOW: .*' "/tmp/attas_$(basename "$p").log"). Desconéctalo."
      else echo "FALLÓ (ver /tmp/attas_$(basename "$p").log)"; fi
    done
    # Un puerto que desaparece queda libre para el siguiente Atta.
    for p in "${!hecho[@]}"; do
      echo "$actuales" | grep -qx "$p" || unset "hecho[$p]"
    done
    sleep 1
  done
fi

PUERTOS=$(puertos)
if [ -z "$PUERTOS" ]; then
  echo "No hay Attas conectados." >&2
  exit 1
fi
declare -A pid
for p in $PUERTOS; do
  echo "[$p] $ACCION..."
  "$ACCION" "$p" & pid[$p]=$!
done
fallos=0
for p in $PUERTOS; do
  if wait "${pid[$p]}"; then echo "[$p] OK"
  else echo "[$p] FALLÓ (ver /tmp/attas_$(basename "$p").log)"; fallos=$((fallos+1)); fi
done
exit $fallos

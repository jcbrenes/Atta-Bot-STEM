#!/usr/bin/env bash
# Instala Atta-Bot en todas las tabletas conectadas por USB y activa el kiosko:
#   1. Sale del modo kiosko, desinstala la versión anterior solo si su firma no
#      coincide, copia el APK a Descargas y abre el instalador.
#   2. Espera a que se toque "Instalar"/"Actualizar" en cada tableta.
#   3. Hace a la app Device Owner (si aún no lo es) y la abre en modo kiosko.
#
# Uso (desde la raíz del repositorio):
#   bash App/instalar_apk_tablets.sh [ruta/al.apk]
set -u

APK="${1:-App/APKs/Atta-Bot-1.1.17.apk}"
PAQUETE="com.example.proyecto_tec"
ADMIN="$PAQUETE/.DeviceAdminReceiver"
DESTINO="/sdcard/Download/$(basename "$APK")"
ESPERA_MAX=300  # segundos para tocar "Instalar" en las tabletas
BUILD_TOOLS=$(ls -d ~/Android/Sdk/build-tools/*/ 2>/dev/null | tail -n1)
APKSIGNER="${BUILD_TOOLS}apksigner"
AAPT="${BUILD_TOOLS}aapt"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

firma() {
  "$APKSIGNER" verify --print-certs "$1" 2>/dev/null | grep -m1 'SHA-256' | awk '{print $NF}'
}

version_instalada() {
  adb -s "$1" shell dumpsys package "$PAQUETE" | grep -m1 -o 'versionCode=[0-9]*' | cut -d= -f2
}

if [ ! -f "$APK" ]; then
  echo "No se encontró el APK: $APK" >&2
  exit 1
fi
FIRMA_NUEVA=$(firma "$APK")
VERSION_NUEVA=$("$AAPT" dump badging "$APK" | grep -m1 -o "versionCode='[0-9]*'" | tr -dc '0-9')

for s in $(adb devices | awk 'NR>1 && $2=="unauthorized" {print $1}'); do
  echo "[$s] Sin autorizar: desbloquea la tableta y acepta la depuración USB."
done

SERIALES=$(adb devices | awk 'NR>1 && $2=="device" {print $1}')
if [ -z "$SERIALES" ]; then
  echo "No hay tabletas listas. Revisa el cable y la depuración USB." >&2
  exit 1
fi

echo "== Paso 1: preparar instalación"
for s in $SERIALES; do
  modelo=$(adb -s "$s" shell getprop ro.product.model | tr -d '\r')
  echo "[$s] $modelo"

  # El kiosko solo escucha la señal de salida con la app en pantalla.
  adb -s "$s" shell input keyevent KEYCODE_WAKEUP
  sleep 1
  adb -s "$s" shell am broadcast -a "$PAQUETE.EXIT_KIOSK" >/dev/null
  sleep 1

  ruta=$(adb -s "$s" shell pm path "$PAQUETE" | head -n1 | sed 's/^package://' | tr -d '\r')
  if [ -n "$ruta" ]; then
    adb -s "$s" pull "$ruta" "$TMP/instalada.apk" >/dev/null 2>&1
    if [ -n "$FIRMA_NUEVA" ] && [ "$(firma "$TMP/instalada.apk")" = "$FIRMA_NUEVA" ]; then
      if [ "$(version_instalada "$s")" = "$VERSION_NUEVA" ]; then
        echo "  Ya tiene esta versión."
        continue
      fi
      echo "  Misma firma: se actualizará conservando datos."
    else
      echo "  Firma distinta: desinstalando versión anterior (borra sus datos locales)..."
      adb -s "$s" uninstall "$PAQUETE" >/dev/null
    fi
  fi

  echo "  Copiando APK a Descargas..."
  if ! adb -s "$s" push "$APK" "$DESTINO" >/dev/null 2>&1; then
    echo "  ERROR al copiar el APK." >&2
    continue
  fi
  # Fecha actual e indexado para que aparezca arriba en Descargas.
  adb -s "$s" shell touch "$DESTINO"
  adb -s "$s" shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE \
    -d "file://$DESTINO" >/dev/null
  sleep 2

  id=$(adb -s "$s" shell content query --uri content://media/external/file \
        --projection _id:_data | grep "_data=.*$(basename "$DESTINO")" \
        | sed -n 's/.*_id=\([0-9]*\),.*/\1/p' | tail -n1)
  if [ -n "$id" ] && ! adb -s "$s" shell am start -a android.intent.action.VIEW \
      -t application/vnd.android.package-archive \
      -d "content://media/external/file/$id" --grant-read-uri-permission 2>&1 \
      | grep -q Error \
      && sleep 3 \
      && adb -s "$s" shell dumpsys window | grep -m1 mCurrentFocus | grep -q packageinstaller; then
    echo "  Instalador abierto: toca \"Instalar\"/\"Actualizar\" en la tableta."
  else
    # Algunas Xiaomi cierran el instalador si se abre por USB.
    adb -s "$s" shell monkey -p com.mi.android.globalFileexplorer \
      -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
    echo "  Ábrelo desde Archivos > Descargas > $(basename "$DESTINO")."
  fi
done

echo
echo "== Paso 2: esperando instalación en las tabletas (máx. ${ESPERA_MAX}s)"
pendientes="$SERIALES"
inicio=$(date +%s)
while [ -n "$pendientes" ] && [ $(( $(date +%s) - inicio )) -lt "$ESPERA_MAX" ]; do
  siguen=""
  for s in $pendientes; do
    if [ "$(adb -s "$s" get-state 2>/dev/null)" != "device" ]; then
      echo "[$s] Se desconectó; conéctala y vuelve a ejecutar el script." >&2
      desconectadas="${desconectadas:-} $s"
    elif [ "$(version_instalada "$s")" = "$VERSION_NUEVA" ]; then
      echo "[$s] Instalada."
    else
      siguen="$siguen $s"
    fi
  done
  pendientes=$(echo $siguen)
  [ -n "$pendientes" ] && sleep 3
done
for s in $pendientes; do
  echo "[$s] No se instaló a tiempo; se omite el kiosko. Vuelve a ejecutar el script." >&2
done

echo
echo "== Paso 3: activar kiosko"
for s in $SERIALES; do
  case " $pendientes ${desconectadas:-} " in *" $s "*) continue ;; esac

  if adb -s "$s" shell dpm list-owners | grep -q "$PAQUETE"; then
    echo "[$s] Ya es Device Owner."
  else
    salida=$(adb -s "$s" shell dpm set-device-owner "$ADMIN" 2>&1 | tr -d '\r')
    if echo "$salida" | grep -q '^Success'; then
      echo "[$s] Device Owner activado."
    else
      echo "[$s] ERROR al activar Device Owner:" >&2
      echo "$salida" | sed 's/^/    /' >&2
      if echo "$salida" | grep -qi 'accounts'; then
        echo "    Quita las cuentas en Ajustes > Cuentas (o restablece la tableta) y repite." >&2
      fi
      continue
    fi
  fi

  adb -s "$s" shell input keyevent KEYCODE_WAKEUP
  # A veces el gestor de archivos queda encima; se reintenta una vez.
  for intento in 1 2; do
    adb -s "$s" shell am start -W -n "$PAQUETE/.MainActivity" >/dev/null 2>&1
    sleep 3
    estado=$(adb -s "$s" shell dumpsys activity activities | grep -m1 -o 'mLockTaskModeState=[A-Z]*' | cut -d= -f2)
    [ "$estado" = "LOCKED" ] && break
  done
  if [ "$estado" = "LOCKED" ]; then
    echo "[$s] Kiosko activo."
  else
    echo "[$s] App abierta, pero el kiosko no se activó (estado: ${estado:-desconocido}). Desbloquea la pantalla y revisa." >&2
  fi
done

#!/usr/bin/env bash
# Publica un APK como GitHub Release junto con latest.json, que es lo que
# consulta el menú de administración de la app para actualizarse sola.
#
# Uso (desde la raíz del repositorio, con el commit del build ya en GitHub):
#   bash App/publicar_release_apk.sh App/AttabotAndroidIOS/build/app/outputs/flutter-apk/app-release.apk
# Con --prerelease no pasa a ser "latest": las tabletas solo la ven si se escribe
# su dirección exacta en el menú (…/releases/download/app-vX.Y.Z/latest.json).
set -euo pipefail

REPO="${ATTA_REPO:-jcbrenes/Atta-Bot-STEM}"  # repo oficial del proyecto
# Las tabletas solo aceptan actualizaciones con esta firma (clave debug de la laptop de compilación).
FIRMA_ESPERADA="34f0efd4fb561de69dcaad826487fa6f1c06db4bb3eda7eb4ac1520b7da5f84b"
PAQUETE="com.example.proyecto_tec"

APK="${1:?Uso: $0 ruta/al.apk [--prerelease]}"
TIPO=(--latest)
[ "${2:-}" = "--prerelease" ] && TIPO=(--prerelease --latest=false)
BUILD_TOOLS=$(ls -d ~/Android/Sdk/build-tools/*/ 2>/dev/null | tail -n1)
[ -f "$APK" ] || { echo "No existe $APK" >&2; exit 1; }

# awk lee toda la salida: head/grep -m1 cortarían el pipe y pipefail abortaría.
INFO=$("${BUILD_TOOLS}aapt" dump badging "$APK" | awk 'NR==1')
NOMBRE=$(sed -n "s/.*name='\([^']*\)'.*versionCode.*/\1/p" <<<"$INFO")
CODIGO=$(sed -n "s/.*versionCode='\([0-9]*\)'.*/\1/p" <<<"$INFO")
VERSION=$(sed -n "s/.*versionName='\([^']*\)'.*/\1/p" <<<"$INFO")
FIRMA=$("${BUILD_TOOLS}apksigner" verify --print-certs "$APK" 2>/dev/null | awk '/SHA-256/ && !f {print $NF; f=1}')

[ "$NOMBRE" = "$PAQUETE" ] || { echo "Paquete inesperado: $NOMBRE" >&2; exit 1; }
[ "$FIRMA" = "$FIRMA_ESPERADA" ] || { echo "Firma distinta ($FIRMA): las tabletas la rechazarían." >&2; exit 1; }

TAG="app-v$VERSION"
DESTINO=$(mktemp -d)
trap 'rm -rf "$DESTINO"' EXIT
ARCHIVO="Atta-Bot-$VERSION.apk"
cp "$APK" "$DESTINO/$ARCHIVO"
SHA=$(sha256sum "$DESTINO/$ARCHIVO" | awk '{print $1}')
cat > "$DESTINO/latest.json" <<EOF
{"versionName": "$VERSION", "versionCode": $CODIGO, "apk": "$ARCHIVO", "sha256": "$SHA"}
EOF

# Si la etiqueta ya está en GitHub se usa tal cual; si no, se crea en HEAD (debe estar publicado).
if git ls-remote --exit-code --tags "https://github.com/$REPO" "refs/tags/$TAG" >/dev/null; then
  ORIGEN=(--verify-tag)
else
  ORIGEN=(--target "$(git rev-parse HEAD)")
fi
echo "Publicando $TAG en $REPO (versionCode $CODIGO, sha256 $SHA)"
gh release create "$TAG" -R "$REPO" "${ORIGEN[@]}" "${TIPO[@]}" \
  --title "Atta-Bot app $VERSION" \
  --notes "APK de la app Atta-Bot $VERSION (versionCode $CODIGO) para las tabletas en modo kiosko.

Repositorio oficial: https://github.com/$REPO

- Firma SHA-256: \`$FIRMA\`
- APK SHA-256: \`$SHA\`

Las tabletas se actualizan desde el menú de administración, que lee latest.json de este release." \
  "$DESTINO/$ARCHIVO" "$DESTINO/latest.json"
echo "latest.json: https://github.com/$REPO/releases/download/$TAG/latest.json"

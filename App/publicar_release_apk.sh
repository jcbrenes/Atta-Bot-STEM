#!/usr/bin/env bash
# Publica un APK como GitHub Release junto con latest.json, que es lo que
# consulta el menú de administración de la app para actualizarse sola.
#
# Uso (desde la raíz del repositorio, con el commit del build ya en GitHub):
#   bash App/publicar_release_apk.sh App/AttabotAndroidIOS/build/app/outputs/flutter-apk/app-release.apk
# Con --prerelease no pasa a ser "latest": las tabletas solo la ven si se escribe
# su dirección exacta en el menú (…/releases/download/app-vX.Y.Z/latest.json).
set -euo pipefail

REPO="${ATTA_REPO:-eduardo00-fv/Atta-Bot-STEM}"
# Las tabletas solo aceptan actualizaciones con esta firma (clave debug de la laptop de compilación).
FIRMA_ESPERADA="34f0efd4fb561de69dcaad826487fa6f1c06db4bb3eda7eb4ac1520b7da5f84b"
PAQUETE="com.example.proyecto_tec"

APK="${1:?Uso: $0 ruta/al.apk [--prerelease]}"
TIPO=(--latest)
[ "${2:-}" = "--prerelease" ] && TIPO=(--prerelease --latest=false)
BUILD_TOOLS=$(ls -d ~/Android/Sdk/build-tools/*/ 2>/dev/null | tail -n1)
[ -f "$APK" ] || { echo "No existe $APK" >&2; exit 1; }

INFO=$("${BUILD_TOOLS}aapt" dump badging "$APK" | head -n1)
NOMBRE=$(sed -n "s/.*name='\([^']*\)'.*versionCode.*/\1/p" <<<"$INFO")
CODIGO=$(sed -n "s/.*versionCode='\([0-9]*\)'.*/\1/p" <<<"$INFO")
VERSION=$(sed -n "s/.*versionName='\([^']*\)'.*/\1/p" <<<"$INFO")
FIRMA=$("${BUILD_TOOLS}apksigner" verify --print-certs "$APK" 2>/dev/null | grep -m1 'SHA-256' | awk '{print $NF}')

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

echo "Publicando $TAG en $REPO (versionCode $CODIGO, sha256 $SHA)"
gh release create "$TAG" -R "$REPO" --target "$(git rev-parse HEAD)" "${TIPO[@]}" \
  --title "Atta-Bot app $VERSION" \
  --notes "APK $VERSION (versionCode $CODIGO). Firma SHA-256: \`$FIRMA\`. APK SHA-256: \`$SHA\`." \
  "$DESTINO/$ARCHIVO" "$DESTINO/latest.json"
echo "latest.json: https://github.com/$REPO/releases/download/$TAG/latest.json"

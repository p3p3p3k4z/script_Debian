#!/usr/bin/env bash
# lan_share.sh
# Comparte un archivo o carpeta mediante un servidor HTTP local y genera un codigo QR.

set -euo pipefail

source ./decorador/color.sh

if ! command -v python3 &> /dev/null; then
    echo -e "${colorRojo}[!] Error: python3 es requerido para crear el servidor web.${finColor}"
    exit 1
fi

if ! command -v qrencode &> /dev/null; then
    echo -e "${colorAmarillo}[!] 'qrencode' no está instalado. Intentando instalar...${finColor}"
    if command -v apt &> /dev/null; then sudo apt install -y qrencode
    elif command -v dnf &> /dev/null; then sudo dnf install -y qrencode
    elif command -v zypper &> /dev/null; then sudo zypper in -y qrencode
    else
        echo -e "${colorRojo}[!] No se pudo instalar qrencode automáticamente. Instálalo manualmente.${finColor}"
        exit 1
    fi
fi

if [[ $# -eq 0 ]]; then
    echo -e "Uso: $0 <archivo_o_directorio>"
    exit 1
fi

TARGET="$1"
if [[ ! -e "$TARGET" ]]; then
    echo -e "${colorRojo}[!] El archivo o directorio '$TARGET' no existe.${finColor}"
    exit 1
fi

# Obtener IP local (ignora loopback y docker)
IP=$(ip route get 1.1.1.1 | awk '{print $7}' | head -n 1)
PORT=8080

if [[ -z "$IP" ]]; then
    echo -e "${colorRojo}[!] No se pudo determinar la IP de red local.${finColor}"
    exit 1
fi

if [[ -f "$TARGET" ]]; then
    DIR_TO_SERVE=$(dirname "$(realpath "$TARGET")")
    FILE_NAME=$(basename "$TARGET")
    URL="http://${IP}:${PORT}/${FILE_NAME}"
elif [[ -d "$TARGET" ]]; then
    DIR_TO_SERVE=$(realpath "$TARGET")
    URL="http://${IP}:${PORT}/"
fi

echo -e "\n${colorTurquesa}====================================================${finColor}"
echo -e "${colorVerde}Escanea este código QR desde tu celular u otro PC:${finColor}"
echo -e "${colorTurquesa}====================================================${finColor}\n"

qrencode -t UTF8 "$URL"

echo -e "\n${colorAmarillo}URL directa: ${URL}${finColor}"
echo -e "${colorTurquesa}Presiona Ctrl+C para detener el servidor web y dejar de compartir.${finColor}\n"

cd "$DIR_TO_SERVE"
python3 -m http.server $PORT

#!/usr/bin/env bash
# screen_recorder.sh
# Grabador de pantalla silencioso usando ffmpeg (X11)

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

clear
divisor azul
imprimir_color "azul" "\t       Grabador de Pantalla CLI (FFmpeg)       "
divisor azul

if ! command -v ffmpeg &> /dev/null; then
    imprimir_color "amarillo" "\t[i] Instalando 'ffmpeg'..."
    instalar_paquetes "ffmpeg"
fi

if [[ -z "${DISPLAY:-}" ]]; then
    imprimir_color "rojo" "\t[!] No se detectó un entorno gráfico (DISPLAY no definido)."
    sleep 2
    exit 1
fi

OUT_FILE="$HOME/Descargas/grabacion_$(date +%s).mp4"
if [[ -n "${SUDO_USER:-}" ]]; then
    OUT_FILE="$(eval echo "~$SUDO_USER")/Descargas/grabacion_$(date +%s).mp4"
fi

imprimir_color "verde" "\t[*] Preparando grabación del escritorio principal ($DISPLAY)..."
imprimir_color "rojo" "\n\t[!] LA GRABACIÓN INICIARÁ AL PRESIONAR ENTER."
imprimir_color "rojo" "\t[!] PARA DETENER LA GRABACIÓN, PRESIONA CTRL+C EN ESTA TERMINAL."
echo -e "\n\t${colorTurquesa}El archivo se guardará en: $OUT_FILE${finColor}"

echo -e "\n${colorGris}Presiona Enter para INICIAR...${finColor}"
read -r

set +e
# Graba la pantalla X11 sin audio a 30fps
ffmpeg -video_size 1920x1080 -framerate 30 -f x11grab -i "$DISPLAY" -c:v libx264 -preset ultrafast "$OUT_FILE" 2>/dev/null
set -e

imprimir_color "verde" "\n\t[V] Grabación finalizada y guardada en $OUT_FILE"
sleep 3

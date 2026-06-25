#!/usr/bin/env bash
# yt_downloader.sh
# Descarga videos o listas de reproducción como MP4 o MP3.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

clear
divisor azul
imprimir_color "azul" "\t       Descargador Multimedia (yt-dlp)     "
divisor azul

if ! command -v yt-dlp &> /dev/null; then
    imprimir_color "amarillo" "\t[i] Instalando 'yt-dlp' y 'ffmpeg'..."
    instalar_paquetes "yt-dlp"
    instalar_paquetes "ffmpeg"
fi

DIR_DEF="$HOME/Descargas"

echo -e "\t${colorTurquesa}1. Descargar como Video (MP4) - Mejor Calidad${finColor}"
echo -e "\t${colorTurquesa}2. Descargar como Audio (MP3) - Extraer música${finColor}"
echo -e "\t${colorTurquesa}0. Volver${finColor}"
divisor azul
read -rp "        Opción: " opt

if [[ "$opt" == "0" ]]; then exit 0; fi

echo -e "\n\t${colorAmarillo}Ingresa la URL del video o Lista de Reproducción:${finColor}"
read -rp "        URL: " URL

if [[ -z "$URL" ]]; then exit 0; fi

imprimir_color "verde" "\n\t[*] Descargando en $DIR_DEF..."
cd "$DIR_DEF" || exit 1

if [[ "$opt" == "1" ]]; then
    yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --merge-output-format mp4 -o "%(title)s.%(ext)s" "$URL"
elif [[ "$opt" == "2" ]]; then
    yt-dlp -x --audio-format mp3 -o "%(title)s.%(ext)s" "$URL"
else
    imprimir_color "rojo" "\tOpción inválida."
fi

imprimir_color "verde" "\n\t[V] Descarga finalizada en $DIR_DEF"

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

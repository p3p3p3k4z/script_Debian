#!/usr/bin/env bash
# gif_maker.sh
# Convierte videos o fragmentos de video a GIF.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

clear
divisor azul
imprimir_color "azul" "\t       Generador de GIFs Animados (FFmpeg)     "
divisor azul

if ! command -v ffmpeg &> /dev/null; then
    imprimir_color "amarillo" "\t[i] Instalando 'ffmpeg'..."
    instalar_paquetes "ffmpeg"
fi

echo -e "\t${colorAmarillo}Ingresa la ruta absoluta del archivo de video original:${finColor}"
read -rp "        Ruta: " VIDEO

if [[ ! -f "$VIDEO" ]]; then
    imprimir_color "rojo" "\t[!] El video no existe."
    sleep 2
    exit 1
fi

echo -e "\n\t${colorTurquesa}Opciones de Conversión:${finColor}"
echo -e "\t1. Convertir todo el video a GIF (Puede ser muy pesado)"
echo -e "\t2. Extraer un fragmento específico (Recomendado)"
echo -e "\t0. Cancelar"
divisor azul
read -rp "        Opción: " opt

if [[ "$opt" == "0" ]]; then exit 0; fi

OUT_FILE="${VIDEO%.*}.gif"

imprimir_color "verde" "\n\t[*] Generando GIF optimizado (15 fps, ancho 640px max)..."
sleep 1

if [[ "$opt" == "1" ]]; then
    ffmpeg -y -i "$VIDEO" -vf "fps=15,scale=640:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "$OUT_FILE" >/dev/null 2>&1
    imprimir_color "verde" "\n\t[V] GIF creado: $OUT_FILE"

elif [[ "$opt" == "2" ]]; then
    read -rp "        Minuto de inicio (Ej: 00:01:20): " T_START
    read -rp "        Duración en segundos (Ej: 5): " T_DUR
    
    ffmpeg -y -ss "$T_START" -t "$T_DUR" -i "$VIDEO" -vf "fps=15,scale=640:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "$OUT_FILE" >/dev/null 2>&1
    imprimir_color "verde" "\n\t[V] Fragmento convertido a GIF: $OUT_FILE"
fi

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

#!/usr/bin/env bash
# media_optimizer.sh
# Optimiza imágenes y convierte videos usando ffmpeg y optipng

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

clear
divisor azul
imprimir_color "azul" "\t        Optimizador Multimedia (FFmpeg/Opti)     "
divisor azul

if ! command -v ffmpeg &> /dev/null; then
    imprimir_color "amarillo" "\t[i] Instalando dependencias (ffmpeg)..."
    instalar_paquetes "ffmpeg"
fi

echo -e "\t${colorTurquesa}1. Extraer Audio (MP3) de un Video${finColor}"
echo -e "\t${colorTurquesa}2. Convertir Video (.mkv/.avi) a MP4${finColor}"
echo -e "\t${colorTurquesa}3. Comprimir todas las imágenes PNG/JPG en una carpeta (Web)${finColor}"
echo -e "\t${colorTurquesa}0. Volver${finColor}"
divisor azul
read -rp "        Opción: " opt

if [[ "$opt" == "0" ]]; then exit 0; fi

if [[ "$opt" == "1" || "$opt" == "2" ]]; then
    echo -e "\n\t${colorAmarillo}Ingresa la ruta del archivo de video:${finColor}"
    read -rp "        Ruta absoluta: " VIDEO
    
    if [[ ! -f "$VIDEO" ]]; then
        imprimir_color "rojo" "\t[!] El archivo no existe."
        sleep 2
        exit 1
    fi
    
    if [[ "$opt" == "1" ]]; then
        OUT="${VIDEO%.*}.mp3"
        imprimir_color "verde" "\t[*] Extrayendo audio a $OUT..."
        ffmpeg -i "$VIDEO" -q:a 0 -map a "$OUT" -y >/dev/null 2>&1
    elif [[ "$opt" == "2" ]]; then
        OUT="${VIDEO%.*}.mp4"
        imprimir_color "verde" "\t[*] Convirtiendo a $OUT..."
        ffmpeg -i "$VIDEO" -c:v libx264 -preset fast -c:a aac "$OUT" -y >/dev/null 2>&1
    fi
    
    imprimir_color "verde" "\t[V] Proceso finalizado."
    
elif [[ "$opt" == "3" ]]; then
    echo -e "\n\t${colorAmarillo}Ingresa la ruta de la carpeta con imágenes:${finColor}"
    read -rp "        Ruta absoluta: " CARPETA
    
    if [[ ! -d "$CARPETA" ]]; then
        imprimir_color "rojo" "\t[!] La carpeta no existe."
        sleep 2
        exit 1
    fi
    
    if ! command -v optipng &> /dev/null || ! command -v jpegoptim &> /dev/null; then
        imprimir_color "amarillo" "\t[i] Instalando optipng y jpegoptim..."
        instalar_paquetes "optipng"
        instalar_paquetes "jpegoptim"
    fi
    
    imprimir_color "turquesa" "\t[*] Comprimiendo PNGs..."
    find "$CARPETA" -iname "*.png" -exec optipng -o2 -quiet {} \;
    imprimir_color "turquesa" "\t[*] Comprimiendo JPGs..."
    find "$CARPETA" -iname "*.jpg" -o -iname "*.jpeg" -exec jpegoptim -m80 --strip-all --quiet {} \;
    
    imprimir_color "verde" "\t[V] Imágenes optimizadas para web."
fi

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

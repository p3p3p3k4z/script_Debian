#!/usr/bin/env bash
# exif_cleaner.sh
# Limpia metadatos (GPS, modelo cámara) de las fotos.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

clear
divisor azul
imprimir_color "azul" "\t       Limpiador de Metadatos (EXIF)       "
divisor azul

if ! command -v exiftool &> /dev/null; then
    imprimir_color "amarillo" "\t[i] Instalando 'exiftool'..."
    instalar_paquetes "libimage-exiftool-perl" "perl-Image-ExifTool" "exiftool"
fi

imprimir_color "turquesa" "\tEliminaremos datos ocultos como tu ubicación y modelo de celular."
echo -e "\n\t${colorAmarillo}Ingresa la ruta absoluta de la imagen o de una carpeta entera:${finColor}"
read -rp "        Ruta: " TARGET

if [[ ! -e "$TARGET" ]]; then
    imprimir_color "rojo" "\t[!] La ruta no existe."
    sleep 2
    exit 1
fi

imprimir_color "verde" "\n\t[*] Limpiando metadatos..."
if [[ -d "$TARGET" ]]; then
    exiftool -all= -overwrite_original -r "$TARGET"
else
    exiftool -all= -overwrite_original "$TARGET"
fi

imprimir_color "verde" "\n\t[V] Operación exitosa. Privacidad asegurada."

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

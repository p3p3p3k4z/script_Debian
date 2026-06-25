#!/usr/bin/env bash
# ascii_art.sh
# Generador de arte ASCII a partir de texto o imágenes JPG.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

clear
divisor azul
imprimir_color "azul" "\t       Generador de Arte ASCII (Figlet/JP2A)     "
divisor azul

# Instalar dependencias
if ! command -v figlet &> /dev/null || ! command -v jp2a &> /dev/null; then
    imprimir_color "amarillo" "\t[i] Instalando dependencias (figlet, jp2a)..."
    instalar_paquetes "figlet"
    instalar_paquetes "jp2a"
fi

echo -e "\t${colorTurquesa}1. Generar Letrero ASCII Gigante (Texto)${finColor}"
echo -e "\t${colorTurquesa}2. Convertir Foto a Pintura ASCII (JPG)${finColor}"
echo -e "\t${colorTurquesa}0. Volver${finColor}"
divisor azul
read -rp "        Opción: " opt

if [[ "$opt" == "0" ]]; then exit 0; fi

if [[ "$opt" == "1" ]]; then
    echo -e "\n\t${colorAmarillo}Ingresa la frase que deseas convertir:${finColor}"
    read -rp "        Texto: " FRASE
    echo ""
    imprimir_color "verde" "\tResultado:"
    echo -e "${colorTurquesa}"
    figlet "$FRASE"
    echo -e "${finColor}"
    
elif [[ "$opt" == "2" ]]; then
    echo -e "\n\t${colorAmarillo}Ingresa la ruta absoluta de la foto (Solo formatos soportados por jp2a como JPEG/JPG):${finColor}"
    read -rp "        Ruta: " FOTO
    
    if [[ ! -f "$FOTO" ]]; then
        imprimir_color "rojo" "\t[!] La foto no existe."
    else
        echo ""
        # jp2a lo convierte a color en la terminal
        jp2a --colors "$FOTO" || echo -e "\t[!] Error al convertir. Asegúrate de que sea JPG."
    fi
fi

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

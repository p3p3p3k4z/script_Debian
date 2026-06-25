#!/usr/bin/env bash
# file_shredder.sh
# Destrucción segura de archivos usando shred

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

clear
divisor azul
imprimir_color "rojo" "\t        Destructor de Archivos Forense (shred)     "
divisor azul

imprimir_color "amarillo" "\t[!] PRECAUCIÓN: Los archivos destruidos NO pueden ser recuperados."
echo -e "\n\t${colorTurquesa}Introduce la ruta absoluta del archivo a destruir:${finColor}"
read -rp "        " FILE_PATH

if [[ -z "$FILE_PATH" || ! -e "$FILE_PATH" ]]; then
    imprimir_color "rojo" "\t[!] El archivo o ruta no existe."
    sleep 2
    exit 1
fi

if [[ -d "$FILE_PATH" ]]; then
    imprimir_color "amarillo" "\t[i] Es un directorio. Se destruirán todos los archivos dentro."
    read -rp "        ¿Estás completamente seguro? (escribe 'SI'): " confirm
    if [[ "$confirm" != "SI" ]]; then
        imprimir_color "verde" "\tOperación cancelada."
        sleep 2
        exit 0
    fi
    
    imprimir_color "turquesa" "\t[*] Destruyendo contenido del directorio..."
    find "$FILE_PATH" -type f -exec shred -v -u -z -n 3 {} \;
    rm -rf "$FILE_PATH"
else
    read -rp "        ¿Estás completamente seguro de destruir este archivo? (escribe 'SI'): " confirm
    if [[ "$confirm" != "SI" ]]; then
        imprimir_color "verde" "\tOperación cancelada."
        sleep 2
        exit 0
    fi
    
    imprimir_color "turquesa" "\t[*] Destruyendo archivo..."
    shred -v -u -z -n 3 "$FILE_PATH"
fi

imprimir_color "verde" "\n\t[V] Destrucción completada. Datos irrecoverables."

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

#!/usr/bin/env bash
# batch_rename.sh
# Renombrador masivo de archivos en un directorio.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

clear
divisor azul
imprimir_color "azul" "\t       Renombrador Masivo de Archivos      "
divisor azul

echo -e "\t${colorAmarillo}Ingresa la ruta de la carpeta que contiene los archivos:${finColor}"
read -rp "        Ruta absoluta: " CARPETA

if [[ ! -d "$CARPETA" ]]; then
    imprimir_color "rojo" "\t[!] La carpeta no existe."
    sleep 2
    exit 1
fi

echo -e "\n\t${colorTurquesa}Elige la operación a realizar:${finColor}"
echo -e "\t1. Añadir prefijo a todos los archivos (ej. 'foto_')"
echo -e "\t2. Añadir sufijo a todos los archivos (ej. '_backup')"
echo -e "\t3. Reemplazar texto en los nombres (Buscar y Reemplazar)"
echo -e "\t0. Volver"
divisor azul
read -rp "        Opción: " opt

if [[ "$opt" == "0" ]]; then exit 0; fi

cd "$CARPETA" || exit 1

if [[ "$opt" == "1" ]]; then
    read -rp "        Prefijo a añadir: " pref
    for f in *; do
        if [[ -f "$f" ]]; then mv "$f" "${pref}${f}"; fi
    done
    imprimir_color "verde" "\t[V] Prefijo añadido correctamente a todos los archivos."
    
elif [[ "$opt" == "2" ]]; then
    read -rp "        Sufijo a añadir (antes de la extensión): " suf
    for f in *; do
        if [[ -f "$f" ]]; then
            nom="${f%.*}"
            ext="${f##*.}"
            if [[ "$nom" == "$ext" ]]; then
                mv "$f" "${f}${suf}"
            else
                mv "$f" "${nom}${suf}.${ext}"
            fi
        fi
    done
    imprimir_color "verde" "\t[V] Sufijo añadido correctamente."

elif [[ "$opt" == "3" ]]; then
    read -rp "        Texto a BUSCAR: " buscar
    read -rp "        Texto a REEMPLAZAR (puede estar vacío): " reempl
    
    if ! command -v rename &> /dev/null; then
        # Renombrado manual en bash puro
        for f in *; do
            if [[ -f "$f" ]]; then
                nuevo="${f//$buscar/$reempl}"
                if [[ "$f" != "$nuevo" ]]; then mv "$f" "$nuevo"; fi
            fi
        done
    else
        # Usar la herramienta rename si está instalada (perl regex)
        rename "s/$buscar/$reempl/g" *
    fi
    imprimir_color "verde" "\t[V] Nombres modificados correctamente."
else
    imprimir_color "rojo" "\tOpción inválida."
fi

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

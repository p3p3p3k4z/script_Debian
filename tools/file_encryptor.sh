#!/usr/bin/env bash
# file_encryptor.sh
# Cifra y descifra archivos usando OpenSSL (AES-256-CBC)

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

clear
divisor azul
imprimir_color "azul" "\t       Cifrador de Archivos (AES-256)      "
divisor azul

if ! command -v openssl &> /dev/null; then
    imprimir_color "amarillo" "\t[i] Instalando 'openssl'..."
    instalar_paquetes "openssl"
fi

echo -e "\t${colorTurquesa}1. Cifrar (Proteger un archivo con contraseña)${finColor}"
echo -e "\t${colorTurquesa}2. Descifrar (Desbloquear archivo .enc)${finColor}"
echo -e "\t${colorTurquesa}0. Volver${finColor}"
divisor azul
read -rp "        Opción: " opt

if [[ "$opt" == "0" ]]; then exit 0; fi

echo -e "\n\t${colorAmarillo}Ingresa la ruta absoluta del archivo:${finColor}"
read -rp "        Ruta: " FILE

if [[ ! -f "$FILE" ]]; then
    imprimir_color "rojo" "\t[!] El archivo no existe."
    sleep 2
    exit 1
fi

if [[ "$opt" == "1" ]]; then
    OUT="${FILE}.enc"
    imprimir_color "verde" "\t[*] Cifrando usando aes-256-cbc. Te pedirá una contraseña."
    # PBKDF2 es necesario en OpenSSL moderno
    openssl enc -aes-256-cbc -salt -pbkdf2 -in "$FILE" -out "$OUT"
    imprimir_color "verde" "\n\t[V] Archivo cifrado creado: $OUT"
    imprimir_color "amarillo" "\t[i] No olvides borrar el original si quieres máxima seguridad (puedes usar el File Shredder)."

elif [[ "$opt" == "2" ]]; then
    OUT="${FILE%.enc}"
    if [[ "$OUT" == "$FILE" ]]; then OUT="${FILE}.dec"; fi
    
    imprimir_color "verde" "\t[*] Descifrando. Ingresa la contraseña original:"
    openssl enc -d -aes-256-cbc -pbkdf2 -in "$FILE" -out "$OUT"
    imprimir_color "verde" "\n\t[V] Archivo recuperado: $OUT"
fi

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

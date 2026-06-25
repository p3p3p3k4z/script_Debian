#!/usr/bin/env bash
# password_gen.sh
# Generador de contraseñas seguras offline.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

clear
divisor azul
imprimir_color "azul" "\t       Generador de Contraseñas (Offline)      "
divisor azul

echo -e "\t${colorTurquesa}Selecciona la longitud de la contraseña:${finColor}"
echo -e "\t1. 16 caracteres (Estándar)"
echo -e "\t2. 32 caracteres (Ultra Seguro)"
echo -e "\t3. 64 caracteres (Paranoico)"
echo -e "\t0. Volver"
divisor azul
read -rp "        Opción: " opt

LEN=16
case "$opt" in
    1) LEN=16 ;;
    2) LEN=32 ;;
    3) LEN=64 ;;
    0) exit 0 ;;
    *) echo "Inválido"; exit 1 ;;
esac

# Generar usando /dev/urandom y base64
PASS=$(head -c 100 /dev/urandom | base64 | tr -dc 'A-Za-z0-9!@#$%^&*()_+-=' | head -c "$LEN")

echo ""
divisor2 turquesa
imprimir_color "verde" "\tTu contraseña segura es:"
echo -e "\n\t${colorRojo}${PASS}${finColor}\n"
divisor2 turquesa

# Intentar copiar al portapapeles
if command -v xclip &> /dev/null; then
    echo -n "$PASS" | xclip -selection clipboard
    imprimir_color "amarillo" "\t[V] Copiada al portapapeles (X11)."
elif command -v wl-copy &> /dev/null; then
    echo -n "$PASS" | wl-copy
    imprimir_color "amarillo" "\t[V] Copiada al portapapeles (Wayland)."
else
    imprimir_color "turquesa" "\t[i] Para copiar automáticamente, instala 'xclip' o 'wl-copy'."
fi

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

#!/usr/bin/env bash
# ephemeral_container.sh
# Inicia contenedores de usar y tirar.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

clear
divisor azul
imprimir_color "azul" "\t       Contenedores Efímeros (Docker)      "
divisor azul

if ! command -v docker &> /dev/null; then
    imprimir_color "rojo" "\t[!] Docker no está instalado."
    exit 1
fi

imprimir_color "turquesa" "\tElige la imagen para lanzar un entorno aislado temporal."
imprimir_color "turquesa" "\tAl escribir 'exit', el contenedor se autodestruirá (--rm)."
echo ""

echo -e "\t1. Alpine Linux (Ligero, 5MB)"
echo -e "\t2. Ubuntu (Completo, apt)"
echo -e "\t3. Debian (Estable)"
echo -e "\t4. Arch Linux (pacman)"
echo -e "\t0. Volver"
divisor azul
read -rp "        Opción: " opt

IMAGE=""
case "$opt" in
    1) IMAGE="alpine" ;;
    2) IMAGE="ubuntu" ;;
    3) IMAGE="debian" ;;
    4) IMAGE="archlinux" ;;
    0) exit 0 ;;
    *) echo "Inválido"; exit 1 ;;
esac

imprimir_color "verde" "\n\t[*] Descargando (si es necesario) y lanzando $IMAGE..."
sleep 1

if [[ "$IMAGE" == "alpine" ]]; then
    sudo docker run --rm -it "$IMAGE" /bin/sh
else
    sudo docker run --rm -it "$IMAGE" /bin/bash
fi

imprimir_color "amarillo" "\n\t[i] Contenedor destruido."
sleep 2

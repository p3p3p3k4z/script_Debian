#!/usr/bin/env bash
# sys_benchmark.sh
# Mide rendimiento de red y discos.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

clear
divisor azul
imprimir_color "azul" "\t      Benchmarker de Sistema (Red y Discos)    "
divisor azul

# 1. Velocidad de Internet
imprimir_color "turquesa" "\t[1] Midiendo Velocidad de Internet (Esto tomará 30 segs)..."
if ! command -v speedtest-cli &> /dev/null; then
    imprimir_color "amarillo" "\t[i] Instalando speedtest-cli..."
    instalar_paquetes "speedtest-cli"
fi

if command -v speedtest-cli &> /dev/null; then
    speedtest-cli --simple | awk '{print "\t    " $0}'
else
    imprimir_color "rojo" "\t[!] Speedtest omitido."
fi

# 2. Velocidad de Discos
imprimir_color "turquesa" "\n\t[2] Midiendo Velocidad de Escritura del Disco Duro (Creando archivo 1GB)..."
TEST_FILE=$(mktemp)
dd if=/dev/zero of="$TEST_FILE" bs=1G count=1 oflag=dsync 2>&1 | awk '/copied/ {print "\t    Escritura: " $(NF-1) " " $NF}' || true
rm -f "$TEST_FILE"

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

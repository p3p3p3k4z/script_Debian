#!/usr/bin/env bash
# mini_shark.sh
# Monitor de tráfico de red en tiempo real.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

if [[ "$EUID" -ne 0 ]]; then
    echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para sniffer de red...${finColor}"
    exec sudo "$0" "$@"
fi

clear
divisor azul
imprimir_color "azul" "\t       Analizador de Tráfico (Mini-Shark)      "
divisor azul

if ! command -v tcpdump &> /dev/null; then
    imprimir_color "amarillo" "\t[i] Instalando 'tcpdump'..."
    instalar_paquetes "tcpdump"
fi

imprimir_color "turquesa" "\tEste modo intercepta paquetes en la interfaz principal."
echo -e "\t${colorTurquesa}1. Escuchar peticiones web (HTTP - Puerto 80)${finColor}"
echo -e "\t${colorTurquesa}2. Escuchar peticiones DNS (Puerto 53 - Webs que visitas)${finColor}"
echo -e "\t${colorTurquesa}3. Escuchar TODO el tráfico (Muy rápido)${finColor}"
echo -e "\t${colorTurquesa}0. Volver${finColor}"
divisor azul
read -rp "        Opción: " opt

if [[ "$opt" == "0" ]]; then exit 0; fi

IFACE=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//" | xargs)

imprimir_color "rojo" "\n\t[!] ESCANEANDO INTERFAZ: $IFACE"
imprimir_color "rojo" "\t[!] PRESIONA CTRL+C PARA DETENER LA CAPTURA"
echo ""
sleep 2

if [[ "$opt" == "1" ]]; then
    tcpdump -i "$IFACE" -n tcp port 80
elif [[ "$opt" == "2" ]]; then
    tcpdump -i "$IFACE" -n udp port 53
elif [[ "$opt" == "3" ]]; then
    tcpdump -i "$IFACE" -n
else
    imprimir_color "rojo" "\tOpción inválida."
fi

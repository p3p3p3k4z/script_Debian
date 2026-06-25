#!/usr/bin/env bash
# ssh_proxy.sh
# Crea un túnel SOCKS5 rápido vía SSH.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

clear
divisor azul
imprimir_color "azul" "\t       Túnel SOCKS5 vía SSH (Proxy Seguro)     "
divisor azul

imprimir_color "turquesa" "\tEnrutará tu tráfico a través de un servidor remoto de forma cifrada."
imprimir_color "turquesa" "\tIdeal para Wi-Fi público. Puerto local por defecto: 1080."
echo ""

echo -e "\t${colorAmarillo}Ingresa el Usuario Remoto (ej. root):${finColor}"
read -rp "        Usuario: " usr
if [[ -z "$usr" ]]; then exit 0; fi

echo -e "\t${colorAmarillo}Ingresa la IP o Dominio del Servidor Remoto:${finColor}"
read -rp "        Host: " host
if [[ -z "$host" ]]; then exit 0; fi

imprimir_color "verde" "\n\t[*] Iniciando Túnel Dinámico (SOCKS5) en localhost:1080..."
imprimir_color "amarillo" "\t    Configura tu navegador (ej. Firefox) para usar Proxy SOCKS5 en 127.0.0.1:1080"
imprimir_color "rojo" "\t    [!] Presiona Ctrl+C para detener el túnel y salir."
echo ""

# Ejecutar ssh con -D 1080 -N (No ejecutar comandos remotos) -C (Comprimir)
ssh -D 1080 -N -C "${usr}@${host}"

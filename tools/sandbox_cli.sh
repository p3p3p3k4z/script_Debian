#!/usr/bin/env bash
# sandbox_cli.sh
# Ejecuta comandos en un entorno aislado usando firejail

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

clear
divisor azul
imprimir_color "azul" "\t        Entorno Aislado CLI (Sandbox)      "
divisor azul

if ! command -v firejail &> /dev/null; then
    imprimir_color "amarillo" "\t[i] Instalando 'firejail'..."
    instalar_paquetes "firejail"
fi

imprimir_color "turquesa" "\tEste modo ejecuta cualquier programa de forma segura."
imprimir_color "turquesa" "\tEl programa no tendrá acceso a tu carpeta personal ni a contraseñas."
echo ""

echo -e "\t${colorAmarillo}Ingresa el comando a ejecutar de forma aislada:${finColor}"
read -rp "        (Ej: firefox, wget url, ./script_sospechoso.sh) > " cmd

if [[ -z "$cmd" ]]; then
    exit 0
fi

imprimir_color "verde" "\n\t[*] Iniciando Sandbox..."
sleep 1

# Usar firejail con perfil default restringido
firejail --private --netfilter $cmd || echo -e "\n\t${colorRojo}[!] El comando terminó o falló.${finColor}"

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

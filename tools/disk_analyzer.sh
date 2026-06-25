#!/usr/bin/env bash
# disk_analyzer.sh
# Analizador visual de uso de disco en consola (ncdu)

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

clear
divisor azul
imprimir_color "azul" "\t       Analizador Visual de Disco (NCDU)       "
divisor azul

if ! command -v ncdu &> /dev/null; then
    imprimir_color "amarillo" "\t[i] Instalando 'ncdu'..."
    instalar_paquetes "ncdu"
fi

imprimir_color "turquesa" "\tUsa las FLECHAS para navegar y 'q' para salir de la interfaz."
echo -e "\n\t${colorAmarillo}Ingresa la ruta absoluta del directorio a analizar (ej. / o /home/user):${finColor}"
read -rp "        Ruta: " DIR_PATH

if [[ ! -d "$DIR_PATH" ]]; then
    imprimir_color "rojo" "\t[!] El directorio no existe."
    sleep 2
    exit 1
fi

imprimir_color "verde" "\n\t[*] Calculando pesos... Esto puede tomar unos segundos."
sleep 1

# Lanzar ncdu
ncdu "$DIR_PATH"

imprimir_color "verde" "\n\t[V] Análisis finalizado."
sleep 2

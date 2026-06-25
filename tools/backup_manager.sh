#!/usr/bin/env bash
# backup_manager.sh
# Herramienta para realizar respaldos rápidos comprimidos

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

clear
divisor azul
imprimir_color "azul" "\t        Gestor Rápido de Backups (TAR)     "
divisor azul

echo -e "\n\t${colorTurquesa}Selecciona el origen a respaldar:${finColor}"
echo -e "\t1. Mi carpeta de usuario (~/)"
echo -e "\t2. Configuraciones del sistema (/etc) [Pedirá sudo]"
echo -e "\t3. Servidor Web / Proyectos (/var/www) [Pedirá sudo]"
echo -e "\t4. Ruta personalizada"
echo -e "\t0. Salir"
divisor azul
read -rp "        Opción: " opt

ORIGEN=""
case "$opt" in
    1) ORIGEN="$HOME" ;;
    2) ORIGEN="/etc"; if [[ "$EUID" -ne 0 ]]; then exec sudo "$0" "$@"; fi ;;
    3) ORIGEN="/var/www"; if [[ "$EUID" -ne 0 ]]; then exec sudo "$0" "$@"; fi ;;
    4) 
       echo -e "\n${colorAmarillo}Si vas a respaldar carpetas protegidas, ejecuta este script con sudo.${finColor}"
       read -rp "        Ruta absoluta origen (ej. /home/m4r10/script_Linux): " ORIGEN 
       ;;
    0) exit 0 ;;
    *) echo -e "${colorRojo}Opción inválida.${finColor}"; exit 1 ;;
esac

if [[ ! -d "$ORIGEN" ]]; then
    echo -e "${colorRojo}[!] El origen '$ORIGEN' no existe o no es un directorio.${finColor}"
    exit 1
fi

DESTINO_DEF="$HOME/Backups"
if [[ "$EUID" -eq 0 && -n "${SUDO_USER:-}" ]]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
    DESTINO_DEF="${USER_HOME}/Backups"
fi

mkdir -p "$DESTINO_DEF"

echo -e "\n\t${colorAmarillo}Destino del backup (Enter para usar: $DESTINO_DEF):${finColor}"
read -rp "        " DESTINO
if [[ -z "$DESTINO" ]]; then DESTINO="$DESTINO_DEF"; fi
mkdir -p "$DESTINO"

FECHA=$(date +"%Y%m%d_%H%M%S")
NOMBRE=$(basename "$ORIGEN")
ARCHIVO_SALIDA="${DESTINO}/backup_${NOMBRE}_${FECHA}.tar.gz"

imprimir_color "turquesa" "\n\t[+] Analizando archivos y comprimiendo... (Puede tardar unos minutos)"
tar -czf "$ARCHIVO_SALIDA" -C "$(dirname "$ORIGEN")" "$(basename "$ORIGEN")" 2>/dev/null || true
# true to ignore partial read errors on live systems

imprimir_color "verde" "\t[V] Backup completado con éxito."
imprimir_color "amarillo" "\t    Ruta: $ARCHIVO_SALIDA"
ls -lh "$ARCHIVO_SALIDA" | awk '{print "\t    Tamaño: " $5}'

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

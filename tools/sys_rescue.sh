#!/usr/bin/env bash
# sys_rescue.sh
# Médico del Sistema. Intenta reparar gestor de paquetes y enlaces rotos.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

if [[ "$EUID" -ne 0 ]]; then
    echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para reparar el sistema...${finColor}"
    exec sudo "$0" "$@"
fi

clear
divisor azul
imprimir_color "azul" "\t        Médico del Sistema (System Rescue)      "
divisor azul

imprimir_color "turquesa" "\t[*] Iniciando rutinas de reparación y recuperación...\n"

if command -v apt &> /dev/null; then
    imprimir_color "amarillo" "\t[1] Reparando dependencias rotas e instalaciones interrumpidas (APT)..."
    dpkg --configure -a || true
    apt --fix-broken install -y || true
    apt update -y || true
    imprimir_color "verde" "\t[V] Gestor de paquetes APT estabilizado.\n"
    
elif command -v dnf &> /dev/null; then
    imprimir_color "amarillo" "\t[1] Reconstruyendo base de datos RPM y limpiando metadatos (DNF)..."
    rpm --rebuilddb || true
    dnf clean all || true
    imprimir_color "verde" "\t[V] Gestor de paquetes DNF estabilizado.\n"
fi

imprimir_color "amarillo" "\t[2] Buscando y eliminando enlaces simbólicos rotos en /usr/local/bin..."
find /usr/local/bin -xtype l -delete 2>/dev/null || true
imprimir_color "verde" "\t[V] Enlaces rotos eliminados.\n"

imprimir_color "amarillo" "\t[3] Verificando permisos de /tmp y /var/tmp..."
chmod 1777 /tmp || true
chmod 1777 /var/tmp || true
imprimir_color "verde" "\t[V] Permisos de temporales restablecidos.\n"

divisor azul
imprimir_color "verde" "\t      ¡Reparación del sistema completada!      "
divisor azul

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

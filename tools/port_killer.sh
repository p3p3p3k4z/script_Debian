#!/usr/bin/env bash
# port_killer.sh
# Muestra procesos usando puertos y permite matarlos.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

if [[ "$EUID" -ne 0 ]]; then
    echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para listar PIDs...${finColor}"
    exec sudo "$0" "$@"
fi

clear
divisor azul
imprimir_color "rojo" "\t       Cazador de Puertos (Netstat / SS)       "
divisor azul

imprimir_color "turquesa" "\tProcesos actualmente escuchando en puertos locales:"
echo ""

if command -v ss &> /dev/null; then
    ss -tulpn | grep LISTEN | awk '{print "    Puerto: " $5 " | Proceso: " $7}' | sed 's/users:(("//g' | sed 's/".*pid=//g' | sed 's/,fd=.*))//g' || echo -e "\tNingún puerto a la escucha."
elif command -v netstat &> /dev/null; then
    netstat -tulpn | grep LISTEN | awk '{print "    Puerto: " $4 " | PID/Nombre: " $7}' || echo -e "\tNingún puerto a la escucha."
else
    imprimir_color "rojo" "\t[!] Instala 'iproute2' o 'net-tools' para ver puertos."
    exit 1
fi

echo -e "\n\t${colorAmarillo}Ingresa el PID del proceso que deseas destruir (o presiona Enter para salir):${finColor}"
read -rp "        PID: " target_pid

if [[ -n "$target_pid" ]]; then
    if kill -9 "$target_pid" 2>/dev/null; then
        imprimir_color "verde" "\t[V] Proceso $target_pid destruido con éxito."
    else
        imprimir_color "rojo" "\t[!] Fallo al destruir el proceso $target_pid (Puede que no exista o requiera más permisos)."
    fi
fi

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

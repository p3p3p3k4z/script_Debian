#!/usr/bin/env bash
# firewall_manager.sh
# Interfaz simple para UFW

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

if [[ "$EUID" -ne 0 ]]; then
    echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para gestionar Firewall...${finColor}"
    exec sudo "$0" "$@"
fi

if ! command -v ufw &> /dev/null; then
    echo -e "${colorRojo}[!] UFW no está instalado.${finColor}"
    echo -e "${colorAmarillo}[i] ¿Deseas instalarlo? (s/N)${finColor}"
    read -rp " " inst_ufw
    if [[ "${inst_ufw,,}" == "s" ]]; then
        imprimir_color "amarillo" "\t[i] Instalando 'ufw'..."
        instalar_paquetes "ufw"
    else
        exit 1
    fi
fi

while true; do
    clear
    divisor azul
    imprimir_color "azul" "\t        Gestor Rápido de Firewall (UFW)    "
    divisor azul
    
    status=$(ufw status | grep "Status" | awk '{print $2}' || echo "inactive")
    if [[ "$status" == "active" ]]; then
        imprimir_color "verde" "\n\t[+] Estado actual: ACTIVADO"
    else
        imprimir_color "rojo" "\n\t[-] Estado actual: DESACTIVADO"
    fi
    echo ""
    divisor azul
    echo -e "\t1. Activar Firewall"
    echo -e "\t2. Desactivar Firewall"
    echo -e "\t3. Ver reglas y puertos abiertos"
    echo -e "\t4. Abrir un puerto (Permitir Entrada)"
    echo -e "\t5. Cerrar/Borrar una regla (por número)"
    echo -e "\t0. Volver"
    divisor azul
    read -rp "        Elige una opción: " opt
    
    case "$opt" in
        1) ufw enable; sleep 2 ;;
        2) ufw disable; sleep 2 ;;
        3) 
           echo ""
           ufw status numbered
           echo -e "\n${colorAmarillo}Presiona Enter para continuar...${finColor}"
           read -r
           ;;
        4) 
           echo -e "\n${colorTurquesa}Ejemplos: 80, 22/tcp, 443/udp${finColor}"
           read -rp "    Ingresa el puerto a ABRIR: " port
           if [[ -n "$port" ]]; then ufw allow "$port"; fi
           sleep 2
           ;;
        5) 
           echo -e "\n${colorAmarillo}Revisa la opción 3 para ver los números de regla.${finColor}"
           read -rp "    Ingresa el NÚMERO de regla a BORRAR: " regla
           if [[ -n "$regla" ]]; then ufw delete "$regla"; fi
           sleep 2
           ;;
        0) exit 0 ;;
        *) echo -e "${colorRojo}Opción inválida.${finColor}"; sleep 1 ;;
    esac
done

#!/usr/bin/env bash
# iso_usb_manager.sh
# Montador de ISOs y Creador de USBs Booteables

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

if [[ "$EUID" -ne 0 ]]; then
    echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para gestión de discos...${finColor}"
    exec sudo "$0" "$@"
fi

flashear_usb() {
    clear
    divisor azul
    imprimir_color "azul" "\t       Quemador de USB Booteable (Flasheador)   "
    divisor azul
    
    imprimir_color "rojo" "\t[!] ADVERTENCIA: Se borrarán TODOS los datos de la memoria USB."
    echo ""
    imprimir_color "turquesa" "\tDiscos USB Conectados detectados:"
    
    # Listar discos omitiendo el principal (sda/nvme0n1) para mayor seguridad
    lsblk -d -o NAME,SIZE,MODEL,TRAN | grep -i "usb" | awk '{print "\t  /dev/" $1 " - " $2 " - " $3}' || echo -e "\t  No se detectaron discos USB conectados."
    
    echo -e "\n\t${colorAmarillo}Ingresa la ruta de tu archivo .ISO:${finColor}"
    read -rp "        Ruta absoluta: " iso_path
    
    if [[ ! -f "$iso_path" ]]; then
        imprimir_color "rojo" "\t[!] El archivo ISO no existe."
        sleep 2
        return
    fi
    
    echo -e "\n\t${colorAmarillo}Ingresa el dispositivo destino (Ejemplo: /dev/sdb o /dev/sdc):${finColor}"
    read -rp "        Destino: " usb_dev
    
    if [[ ! -b "$usb_dev" ]]; then
        imprimir_color "rojo" "\t[!] El dispositivo $usb_dev no existe o no es un bloque."
        sleep 2
        return
    fi
    
    if [[ "$usb_dev" == *"/dev/sda"* || "$usb_dev" == *"/dev/nvme0n1"* ]]; then
        imprimir_color "rojo" "\t[!] BLOQUEADO: Seleccionaste el disco principal del sistema."
        sleep 2
        return
    fi
    
    imprimir_color "rojo" "\n\tEstás a punto de formatear $usb_dev con el archivo $iso_path"
    read -rp "        ¿Estás 100% seguro? Escribe 'QUEMAR' para proceder: " conf
    
    if [[ "$conf" != "QUEMAR" ]]; then
        imprimir_color "verde" "\tOperación cancelada de forma segura."
        sleep 2
        return
    fi
    
    imprimir_color "turquesa" "\t[*] Flasheando USB... Por favor NO desconectes la memoria."
    dd if="$iso_path" of="$usb_dev" bs=4M status=progress oflag=sync
    
    imprimir_color "verde" "\n\t[V] ¡USB Booteable creado con éxito!"
    sleep 3
}

montar_iso() {
    clear
    divisor azul
    imprimir_color "azul" "\t           Montador Virtual de ISOs             "
    divisor azul
    
    MNT_DIR="/mnt/iso_virtual"
    mkdir -p "$MNT_DIR"
    
    echo -e "\t${colorAmarillo}Ingresa la ruta de tu archivo .ISO:${finColor}"
    read -rp "        Ruta absoluta: " iso_path
    
    if [[ ! -f "$iso_path" ]]; then
        imprimir_color "rojo" "\t[!] El archivo ISO no existe."
        sleep 2
        return
    fi
    
    umount "$MNT_DIR" 2>/dev/null || true
    mount -o loop "$iso_path" "$MNT_DIR"
    
    imprimir_color "verde" "\t[V] ISO montada correctamente en $MNT_DIR"
    imprimir_color "turquesa" "\t    Puedes abrir otra terminal para explorar sus archivos."
    echo -e "\n${colorGris}Presiona Enter cuando desees DESMONTAR la ISO...${finColor}"
    read -r
    
    umount "$MNT_DIR"
    imprimir_color "verde" "\t[V] ISO desmontada correctamente."
    sleep 2
}

while true; do
    clear
    divisor azul
    imprimir_color "azul" "\t        Gestor de Discos e Imágenes (ISO/USB)    "
    divisor azul
    
    echo -e "\t1. Crear USB Booteable (Flashear ISO a USB)"
    echo -e "\t2. Montar ISO virtualmente (Explorar archivos)"
    echo -e "\t0. Volver"
    divisor azul
    read -rp "        Elige una opción: " opt
    
    case "$opt" in
        1) flashear_usb ;;
        2) montar_iso ;;
        0) exit 0 ;;
        *) echo -e "\t${colorRojo}Opción inválida.${finColor}"; sleep 1 ;;
    esac
done

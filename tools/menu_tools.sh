#!/usr/bin/env bash

source ./decorador/color.sh
source ./decorador/separador.sh 2>/dev/null || true

function mostrar_menu_tools() {
    while true; do
        clear
        divisor
        echo -e "\t\t    - - - HERRAMIENTAS Y UTILIDADES - - -"
        echo -e "\t\t1- Limpieza de Disco Personal (mantenimiento)"
        echo -e "\t\t2- Optimizador de Sistema Profundo"
        echo -e "\t\t3- Limpiador de Docker (Janitor)"
        echo -e "\t\t4- Iniciar Alerta Ligera de Recursos en segundo plano"
        echo -e "\t\t5- Escáner Multiprotocolo (Red Teaming)"
        echo -e "\t\t6- Escáner SSH Rápido"
        echo -e "\t\t7- Gestor Inalámbrico y Privacidad MAC"
        echo -e "\t\t8- Compartir archivo por LAN con QR"
        echo -e "\t\t9- Gestor de Virtualización (KVM/VirtualBox)"
        echo -e "\t\t10- Interruptor de Servicios (Modo Ahorro Batería)"
        echo -e "\t\t11- Sincronización Automática de Dotfiles (Git)"
        echo -e "\t\t0- Volver al menú anterior"
        divisor
        echo -e "${colorGris}Teclea una opción${finColor}"; read -r op_tools

        case $op_tools in
            1) ./tools/mantenimiento.sh ;;
            2) sudo ./tools/sys_optimizer.sh ;;
            3) ./tools/docker_janitor.sh ;;
            4) 
               nohup ./tools/monitor_alert.sh > /dev/null 2>&1 & 
               echo -e "${colorVerde}[V] Monitor iniciado en segundo plano. Te alertará si la RAM pasa del 90% o batería baja del 15%.${finColor}" 
               ;;
            5) 
               echo -e "${colorAmarillo}Escribe la IP base para escanear (ej. 192.168.1):${finColor}"
               read -r ip_base
               echo -e "${colorAmarillo}Escribe el servicio a probar (ssh, sftp, scp, rsync, smb, webdav, rdp):${finColor}"
               read -r protocolo
               ./tools/multi_scanner.sh -b "$ip_base" -s 1 -e 254 -m "$protocolo"
               ;;
            6) 
               echo -e "${colorAmarillo}Escribe la IP base para escanear SSH (ej. 192.168.1):${finColor}"
               read -r ip_base
               echo -e "${colorAmarillo}Usuario SSH a intentar (ej. root, admin):${finColor}"
               read -r usuario
               ./tools/ssh_scanner.sh -b "$ip_base" -u "$usuario"
               ;;
            7) ./tools/wifi_manager.sh ;;
            8) 
               echo -e "${colorAmarillo}Ingresa la ruta absoluta o relativa del archivo o carpeta a compartir:${finColor}"
               read -r ruta_compartir
               ./tools/lan_share.sh "$ruta_compartir"
               ;;
            9) ./tools/toggle_kvm.sh ;;
            10) sudo ./tools/dev_mode_toggle.sh ;;
            11) ./tools/dotfiles_sync.sh ;;
            0) break ;;
            *) echo -e "${colorRojo}Opción no válida.${finColor}" ;;
        esac
        echo -e "\n${colorAmarillo}Presiona cualquier tecla para continuar...${finColor}"
        read -n 1
    done
}

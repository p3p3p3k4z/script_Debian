#!/usr/bin/env bash
# menu_tools.sh
# Menú de herramientas y utilidades organizado por categorías.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

function mostrar_menu_tools() {
    while true; do
    clear
    divisor rojo
    imprimir_color "rojo" "\t\t    - - - HERRAMIENTAS Y UTILIDADES - - -    "
    divisor rojo

    echo -e "\n\t${colorVerde}MANTENIMIENTO Y SISTEMA${finColor}"
    echo -e "\t  1. Limpieza de Disco Personal (Mantenimiento)"
    echo -e "\t  2. Optimizador de Sistema Profundo (Caché/Flatpak/Snap)"
    echo -e "\t  3. Limpiador de Docker (Janitor)"
    echo -e "\t  4. Médico del Sistema (Reparar Paquetes Rotos)"
    echo -e "\t  5. Sincronización Automática de Dotfiles (Git)"
    echo -e "\t  6. Creador Automático de Servicios (Systemd)"
    echo -e "\t  7. Analizador Visual de Disco (NCDU)"

    echo -e "\n\t${colorAzul}HARDWARE Y RENDIMIENTO${finColor}"
    echo -e "\t  8. Monitor de Salud Térmica y Batería"
    echo -e "\t  9. Benchmarker de Sistema (Internet y Discos)"
    echo -e "\t 10. Iniciar Alerta Ligera de Recursos en segundo plano"
    echo -e "\t 11. Interruptor de Servicios (Modo Ahorro Batería)"
    echo -e "\t 12. Cazador de Puertos y Procesos"

    echo -e "\n\t${colorTurquesa}REDES Y CONECTIVIDAD${finColor}"
    echo -e "\t 13. Escáner de Dispositivos LAN (Inventario)"
    echo -e "\t 14. Gestor Inalámbrico y Privacidad MAC"
    echo -e "\t 15. Compartir archivo por LAN con QR"
    echo -e "\t 16. Túnel SOCKS5 vía SSH (Proxy Seguro)"
    echo -e "\t 17. Cambiador Rápido de DNS (Privacidad)"
    echo -e "\t 18. Desplegador de Entornos Web (LAMP/LEMP)"

    echo -e "\n\t${colorRojo}SEGURIDAD Y PRIVACIDAD${finColor}"
    echo -e "\t 19. Gestor de Firewall (UFW)"
    echo -e "\t 20. Auditoría Básica de Seguridad (Hardening)"
    echo -e "\t 21. Escáner Multiprotocolo (Red Teaming)"
    echo -e "\t 22. Escáner SSH Rápido (Fuerza Bruta/Auditoría)"
    echo -e "\t 23. Destructor Forense de Archivos (Shredder)"
    echo -e "\t 24. Gestor de Llaves Criptográficas (SSH)"
    echo -e "\t 25. Analizador Inteligente de Logs (Log-Hunter)"
    echo -e "\t 26. Entorno Aislado CLI (Sandbox Firejail)"
    echo -e "\t 27. Cifrador de Archivos (AES-256)"
    echo -e "\t 28. Analizador de Tráfico en tiempo real (Mini-Shark)"
    echo -e "\t 29. Limpiador de Metadatos (EXIF)"

    echo -e "\n\t${colorAmarillo}PRODUCTIVIDAD Y MULTIMEDIA${finColor}"
    echo -e "\t 30. Descargador Multimedia (yt-dlp Video/Música)"
    echo -e "\t 31. Optimizador Multimedia (FFmpeg/Imágenes)"
    echo -e "\t 32. Calculadora Científica CLI (bc)"
    echo -e "\t 33. Generador de Contraseñas Seguras (Offline)"
    echo -e "\t 34. Renombrador Masivo de Archivos"
    echo -e "\t 35. Cazador de Archivos Duplicados"
    echo -e "\t 36. Asistente de Tareas Programadas (Cron)"
    echo -e "\t 37. Grabador de Pantalla CLI"
    echo -e "\t 38. Generador de GIFs Animados"

    echo -e "\n\t${colorMorado}VIRTUALIZACIÓN Y DISCOS${finColor}"
    echo -e "\t 39. Gestor de Discos e Imágenes (ISOs y USB Booteables)"
    echo -e "\t 40. Creador de Backups Rápidos (TAR)"
    echo -e "\t 41. Gestor de Virtualización (KVM/VirtualBox)"
    echo -e "\t 42. Contenedores Efímeros (Usar y Tirar)"
    
    echo -e "\n\t${colorGris}ARTE Y DISEÑO CLI${finColor}"
    echo -e "\t 43. Generador de Arte ASCII (Figlet/JP2A)"
    
    echo -e "\n\t${colorGris}  0. Volver al menú anterior${finColor}"
    divisor rojo
    echo -e "${colorGris}Teclea una opción${finColor}"; read -r op_tools

    if [[ "$op_tools" == "0" ]]; then
        break
    fi

    # Ejecución de scripts
    case "$op_tools" in
        1) ./tools/mantenimiento.sh ;;
        2) sudo ./tools/sys_optimizer.sh ;;
        3) sudo ./tools/docker_janitor.sh ;;
        4) sudo ./tools/sys_rescue.sh ;;
        5) ./tools/dotfiles_sync.sh ;;
        6) sudo ./tools/systemd_maker.sh ;;
        7) ./tools/disk_analyzer.sh ;;
        
        8) ./tools/hw_monitor.sh ;;
        9) ./tools/sys_benchmark.sh ;;
        10) ./tools/monitor_alert.sh ;;
        11) sudo ./tools/dev_mode_toggle.sh ;;
        12) sudo ./tools/port_killer.sh ;;
        
        13) ./tools/lan_scanner.sh ;;
        14) sudo ./tools/wifi_manager.sh ;;
        15) ./tools/lan_share.sh ;;
        16) ./tools/ssh_proxy.sh ;;
        17) ./tools/dns_changer.sh ;;
        18) sudo ./tools/web_stack_deployer.sh ;;
        
        19) ./tools/firewall_manager.sh ;;
        20) ./tools/security_audit.sh ;;
        21) ./tools/multi_scanner.sh ;;
        22) ./tools/ssh_scanner.sh ;;
        23) ./tools/file_shredder.sh ;;
        24) ./tools/ssh_key_manager.sh ;;
        25) sudo ./tools/log_hunter.sh ;;
        26) ./tools/sandbox_cli.sh ;;
        27) ./tools/file_encryptor.sh ;;
        28) sudo ./tools/mini_shark.sh ;;
        29) ./tools/exif_cleaner.sh ;;
        
        30) ./tools/yt_downloader.sh ;;
        31) ./tools/media_optimizer.sh ;;
        32) ./tools/cli_calculator.sh ;;
        33) ./tools/password_gen.sh ;;
        34) ./tools/batch_rename.sh ;;
        35) ./tools/duplicate_finder.sh ;;
        36) ./tools/cron_maker.sh ;;
        37) ./tools/screen_recorder.sh ;;
        38) ./tools/gif_maker.sh ;;
        
        39) sudo ./tools/iso_usb_manager.sh ;;
        40) ./tools/backup_manager.sh ;;
        41) ./tools/toggle_kvm.sh ;;
        42) ./tools/ephemeral_container.sh ;;
        
        43) ./tools/ascii_art.sh ;;
        
        *) echo -e "${colorRojo}Opción no válida.${finColor}"; sleep 1 ;;
    esac
    done
}

#!/usr/bin/env bash
# log_hunter.sh
# Analizador inteligente de logs del sistema

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

if [[ "$EUID" -ne 0 ]]; then
    echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para leer logs del sistema...${finColor}"
    exec sudo "$0" "$@"
fi

clear
divisor azul
imprimir_color "azul" "\t        Analizador de Logs (Log Hunter)        "
divisor azul

# 1. Fallos de inicio de sesión SSH
imprimir_color "turquesa" "\t[1] Intentos fallidos recientes de conexión (SSH/Local):"
if [[ -f /var/log/auth.log ]]; then
    LOG_FILE="/var/log/auth.log"
elif [[ -f /var/log/secure ]]; then
    LOG_FILE="/var/log/secure"
else
    LOG_FILE=""
fi

if [[ -n "$LOG_FILE" ]]; then
    fails=$(grep -i "failed" "$LOG_FILE" | tail -n 10 || true)
    if [[ -n "$fails" ]]; then
        echo "$fails" | awk '{print "\t    " $0}'
    else
        imprimir_color "verde" "\t    No se encontraron fallos recientes en $LOG_FILE."
    fi
elif command -v journalctl &>/dev/null; then
    fails=$(journalctl -u ssh -u sshd --since "today" | grep -i "failed" | tail -n 10 || true)
    if [[ -n "$fails" ]]; then
        echo "$fails" | awk '{print "\t    " $0}'
    else
        imprimir_color "verde" "\t    No se encontraron fallos SSH hoy."
    fi
else
    imprimir_color "amarillo" "\t    No se pudo encontrar archivo de logs de autenticación."
fi

echo ""

# 2. Servicios fallidos
imprimir_color "turquesa" "\t[2] Servicios de Systemd que fallaron:"
if command -v systemctl &>/dev/null; then
    failed_svcs=$(systemctl --failed --no-legend --no-pager)
    if [[ -n "$failed_svcs" ]]; then
        echo "$failed_svcs" | awk '{print "\t    " $1 " - " $2 " - " $3}'
    else
        imprimir_color "verde" "\t    Todos los servicios funcionan correctamente."
    fi
fi

echo ""

# 3. Advertencias del Kernel (Hardware/Memoria)
imprimir_color "turquesa" "\t[3] Advertencias críticas del Kernel (Últimas 5):"
if command -v dmesg &>/dev/null; then
    kerr=$(dmesg -l err,crit,alert,emerg | tail -n 5 || true)
    if [[ -n "$kerr" ]]; then
        echo "$kerr" | awk '{print "\t    " $0}'
    else
        imprimir_color "verde" "\t    No hay errores de hardware o de kernel."
    fi
fi

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

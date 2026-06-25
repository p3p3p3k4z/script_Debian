#!/usr/bin/env bash
# dns_changer.sh
# Permite cambiar los DNS de la máquina rápidamente.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

if [[ "$EUID" -ne 0 ]]; then
    echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para modificar la resolución DNS...${finColor}"
    exec sudo "$0" "$@"
fi

RESOLV_CONF="/etc/resolv.conf"

cambiar_dns() {
    local primary=$1
    local secondary=$2
    local prov=$3

    imprimir_color "amarillo" "\n\t[+] Guardando copia de seguridad en /etc/resolv.conf.bak..."
    if [[ -L "$RESOLV_CONF" ]]; then
        # Es un symlink (probablemente systemd-resolved)
        cp --remove-destination "$(realpath "$RESOLV_CONF")" "/etc/resolv.conf.bak" 2>/dev/null || true
    else
        cp "$RESOLV_CONF" "/etc/resolv.conf.bak" 2>/dev/null || true
    fi

    # Desvincular si es symlink temporalmente para forzar el cambio inmediato
    rm -f "$RESOLV_CONF"
    echo "# Configurado por dns_changer.sh ($prov)" > "$RESOLV_CONF"
    echo "nameserver $primary" >> "$RESOLV_CONF"
    echo "nameserver $secondary" >> "$RESOLV_CONF"
    
    imprimir_color "verde" "\t[V] ¡DNS cambiados a $prov con éxito!"
    imprimir_color "turquesa" "\t    Servidores: $primary y $secondary"
    sleep 3
}

restaurar_dns() {
    if [[ -f "/etc/resolv.conf.bak" ]]; then
        imprimir_color "amarillo" "\n\t[+] Restaurando backup anterior..."
        cp "/etc/resolv.conf.bak" "$RESOLV_CONF"
        imprimir_color "verde" "\t[V] DNS Restaurados con éxito."
    else
        imprimir_color "rojo" "\n\t[!] No se encontró copia de seguridad (/etc/resolv.conf.bak)."
    fi
    sleep 3
}

while true; do
    clear
    divisor azul
    imprimir_color "azul" "\t        Cambiador Rápido de DNS (Privacidad)     "
    divisor azul
    
    actual=$(grep "^nameserver" /etc/resolv.conf | head -n1 | awk '{print $2}' || echo "Desconocido")
    imprimir_color "turquesa" "\t    DNS Principal Actual: $actual\n"

    echo -e "\t1. Cloudflare (1.1.1.1) - Rapidez y Privacidad"
    echo -e "\t2. Google (8.8.8.8) - Confiabilidad Estándar"
    echo -e "\t3. Quad9 (9.9.9.9) - Bloqueo de Malware"
    echo -e "\t4. AdGuard (94.140.14.14) - Bloqueo de Anuncios y Trackers"
    echo -e "\t5. Restaurar DNS Anterior (Copia de Seguridad)"
    echo -e "\t0. Volver"
    divisor azul
    read -rp "        Elige una opción: " opt

    case "$opt" in
        1) cambiar_dns "1.1.1.1" "1.0.0.1" "Cloudflare" ;;
        2) cambiar_dns "8.8.8.8" "8.8.4.4" "Google" ;;
        3) cambiar_dns "9.9.9.9" "149.112.112.112" "Quad9" ;;
        4) cambiar_dns "94.140.14.14" "94.140.15.15" "AdGuard" ;;
        5) restaurar_dns ;;
        0) exit 0 ;;
        *) echo -e "\t${colorRojo}Opción inválida.${finColor}"; sleep 1 ;;
    esac
done

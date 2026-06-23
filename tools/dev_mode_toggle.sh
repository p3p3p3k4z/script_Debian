#!/usr/bin/env bash
# dev_mode_toggle.sh
# Permite apagar/encender servicios de desarrollo de forma masiva para ahorrar RAM y bateria.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

# Lista de servicios pesados que suelen quedar en background
SERVICES=("docker" "postgresql" "mysql" "mongod" "redis" "apache2" "httpd" "nginx")

if [[ "$EUID" -ne 0 ]]; then
    echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para modificar servicios...${finColor}"
    exec sudo "$0" "$@"
fi

check_status() {
    echo -e "\n${colorAzul}--- Estado Actual de Servicios de Desarrollo ---${finColor}"
    for svc in "${SERVICES[@]}"; do
        if systemctl list-unit-files "${svc}.service" &>/dev/null; then
            if systemctl is-active --quiet "${svc}"; then
                echo -e "  [${colorVerde}ON${finColor}]  ${svc}"
            else
                echo -e "  [${colorRojo}OFF${finColor}] ${svc}"
            fi
        else
            echo -e "  [---] ${svc} (No instalado)"
        fi
    done
    echo ""
}

encender_todo() {
    echo -e "${colorVerde}[+] Encendiendo Modo Desarrollo (Levantando servicios)...${finColor}"
    for svc in "${SERVICES[@]}"; do
        if systemctl list-unit-files "${svc}.service" &>/dev/null; then
            systemctl start "${svc}"
            echo "  -> Iniciado: $svc"
        fi
    done
    echo -e "${colorVerde}[V] ¡Listo para programar!${finColor}"
    sleep 2
}

apagar_todo() {
    echo -e "${colorAmarillo}[+] Apagando Modo Desarrollo (Ahorrando RAM/Batería)...${finColor}"
    for svc in "${SERVICES[@]}"; do
        if systemctl list-unit-files "${svc}.service" &>/dev/null; then
            if systemctl is-active --quiet "${svc}"; then
                systemctl stop "${svc}"
                echo "  -> Detenido: $svc"
            fi
        fi
    done
    echo -e "${colorAmarillo}[V] ¡Modo de bajo consumo activado!${finColor}"
    sleep 2
}

while true; do
    clear
    divisor azul
    imprimir_color "azul" "\t      Interruptor de Modo Desarrollo     "
    divisor azul
    check_status
    echo -e "\t1. Modo Desarrollo ON (Encender todo)"
    echo -e "\t2. Modo Ahorro OFF (Apagar todo)"
    echo -e "\t0. Salir"
    divisor azul
    read -rp "        Elige una opción [0-2]: " opt

    case "$opt" in
        1) encender_todo ;;
        2) apagar_todo ;;
        0) exit 0 ;;
        *) echo -e "${colorRojo}Opción inválida.${finColor}"; sleep 1 ;;
    esac
done

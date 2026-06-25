#!/usr/bin/env bash
# hw_monitor.sh
# Monitor de temperaturas y estado de bateria

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

clear
divisor azul
imprimir_color "azul" "\t        Monitor de Salud (Térmica y Batería)     "
divisor azul

# 1. Temperaturas
imprimir_color "turquesa" "\t[1] Sensores Térmicos:"
if ! command -v sensors &> /dev/null; then
    imprimir_color "amarillo" "\t    [i] Instalando 'lm-sensors'..."
    instalar_paquetes "lm-sensors" "lm_sensors"
fi

if command -v sensors &> /dev/null; then
    sensors | grep -E "Core|temp1" | awk '{print "\t    " $0}' || echo -e "\t    No se pudieron leer sensores."
else
    echo -e "\t    lm-sensors no disponible."
fi

echo ""

# 2. Batería (Si existe)
imprimir_color "turquesa" "\t[2] Salud de Batería:"
BAT_DIR="/sys/class/power_supply/BAT0"
if [[ ! -d "$BAT_DIR" ]]; then
    BAT_DIR="/sys/class/power_supply/BAT1"
fi

if [[ -d "$BAT_DIR" ]]; then
    status=$(cat "$BAT_DIR/status")
    capacity=$(cat "$BAT_DIR/capacity")
    
    # Intentar leer energía o carga completa
    full=0
    design=0
    if [[ -f "$BAT_DIR/charge_full" && -f "$BAT_DIR/charge_full_design" ]]; then
        full=$(cat "$BAT_DIR/charge_full")
        design=$(cat "$BAT_DIR/charge_full_design")
    elif [[ -f "$BAT_DIR/energy_full" && -f "$BAT_DIR/energy_full_design" ]]; then
        full=$(cat "$BAT_DIR/energy_full")
        design=$(cat "$BAT_DIR/energy_full_design")
    fi
    
    echo -e "\t    Estado: $status"
    echo -e "\t    Carga actual: $capacity%"
    
    if [[ $design -gt 0 ]]; then
        health=$(( full * 100 / design ))
        echo -e "\t    Vida útil de la batería (Health): $health%"
        if [[ $health -lt 50 ]]; then
            imprimir_color "rojo" "\t    [!] Tu batería está muy degradada. Considera cambiarla."
        fi
    fi
else
    imprimir_color "verde" "\t    No se detectó batería (Posible PC de escritorio)."
fi

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

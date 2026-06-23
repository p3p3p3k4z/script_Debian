#!/usr/bin/env bash
# monitor_alert.sh
# Demonio ligero para monitorear RAM y Bateria y lanzar notificaciones de escritorio.

# Para ejecutar en segundo plano y olvidar:
# nohup ./monitor_alert.sh > /dev/null 2>&1 &

# Umbrales
RAM_CRITICAL_PERCENT=90
BATTERY_CRITICAL_PERCENT=15

# Colores terminal (solo si se corre en foreground)
source ./decorador/color.sh

if ! command -v notify-send &> /dev/null; then
    echo -e "${colorRojo}[!] 'notify-send' no instalado. Este script requiere libnotify-bin.${finColor}"
    exit 1
fi

check_ram() {
    # Extraer porcentaje de uso de RAM usando 'free'
    local total_ram
    local used_ram
    local ram_pct
    total_ram=$(free | awk '/Mem:/ {print $2}')
    used_ram=$(free | awk '/Mem:/ {print $3}')
    
    if [[ -n "$total_ram" && -n "$used_ram" && "$total_ram" -gt 0 ]]; then
        ram_pct=$(( 100 * used_ram / total_ram ))
        if [[ "$ram_pct" -ge "$RAM_CRITICAL_PERCENT" ]]; then
            # Enviar notificacion critica
            notify-send -u critical -i dialog-warning "🚨 ALERTA DE SISTEMA" "Uso de RAM Crítico: ${ram_pct}%"
            echo -e "${colorRojo}[$(date +'%H:%M:%S')] ALERTA RAM: ${ram_pct}%${finColor}"
        fi
    fi
}

check_battery() {
    # Revisar estado de la bateria usando la interfaz de sysfs (usualmente en laptops)
    local bat_path="/sys/class/power_supply/BAT0"
    if [[ ! -d "$bat_path" ]]; then
        bat_path="/sys/class/power_supply/BAT1" # Alternativa común
    fi
    
    if [[ -d "$bat_path" ]]; then
        local capacity
        local status
        capacity=$(cat "${bat_path}/capacity")
        status=$(cat "${bat_path}/status")
        
        # Solo alertar si no se esta cargando
        if [[ "$status" == "Discharging" && "$capacity" -le "$BATTERY_CRITICAL_PERCENT" ]]; then
            notify-send -u critical -i battery-empty "🔋 ALERTA DE BATERÍA" "Batería Crítica: ${capacity}%. Conecta el cargador."
            echo -e "${colorAmarillo}[$(date +'%H:%M:%S')] ALERTA BATERÍA: ${capacity}%${finColor}"
        fi
    fi
}

echo "Iniciando monitor ligero en segundo plano. Monitoreando RAM (>$RAM_CRITICAL_PERCENT%) y Batería (<$BATTERY_CRITICAL_PERCENT%)..."

# Bucle principal infinito
while true; do
    check_ram
    check_battery
    
    # Revisar cada 60 segundos
    sleep 60
done

#!/usr/bin/env bash
# lan_scanner.sh
# Escanea la red local y detecta tipos de dispositivos e inventario.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

# Auto elevación de privilegios para escanear MACs (necesita sudo)
if [[ "$EUID" -ne 0 ]]; then
    echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para escaneo profundo de red (MACs/Fabricantes)...${finColor}"
    exec sudo "$0" "$@"
fi

# Instalar dependencias si faltan
if ! command -v nmap &> /dev/null; then
    imprimir_color "amarillo" "\t[i] Instalando 'nmap'..."
    instalar_paquetes "nmap"
fi

clear
divisor azul
imprimir_color "azul" "\t      Escáner de Inventario LAN (Dispositivos)     "
divisor azul

# escaneo de OS
echo -e "\t${colorAmarillo}¿Deseas realizar un escaneo profundo de Sistema Operativo? (Tarda más) [s/N]${finColor}"
read -rp "        " do_os_scan
if [[ "${do_os_scan,,}" == "s" ]]; then
    OS_SCAN=1
else
    OS_SCAN=0
fi
echo ""

# Detectar subred
DEFAULT_IFACE=$(ip route | awk '/default/ {print $5}' | head -n1)
if [[ -z "$DEFAULT_IFACE" ]]; then
    echo -e "${colorRojo}[!] No se pudo detectar la interfaz de red por defecto.${finColor}"
    exit 1
fi
SUBNET=$(ip -o -f inet addr show "$DEFAULT_IFACE" | awk '{print $4}' | head -n1)

imprimir_color "amarillo" "\n\t[+] Interfaz detectada: $DEFAULT_IFACE"
imprimir_color "amarillo" "\t[+] Subred objetivo: $SUBNET"
echo ""

imprimir_color "verde" "\t[*] Fase 1: Descubrimiento de hosts, nombres y fabricantes..."

TMP_NMAP=$(mktemp)
nmap -sn -PR "$SUBNET" > "$TMP_NMAP"

declare -a ALIVE_IPS
declare -A MACS
declare -A VENDORS
declare -A HOSTNAMES

current_ip=""
while IFS= read -r line; do
    if [[ "$line" =~ Nmap\ scan\ report\ for\ (.+)\ \(([0-9\.]+)\) ]]; then
        hostname="${BASH_REMATCH[1]}"
        ip="${BASH_REMATCH[2]}"
        current_ip="$ip"
        HOSTNAMES["$current_ip"]="$hostname"
    elif [[ "$line" =~ Nmap\ scan\ report\ for\ ([0-9\.]+) ]]; then
        ip="${BASH_REMATCH[1]}"
        current_ip="$ip"
        HOSTNAMES["$current_ip"]="N/A"
    elif [[ "$line" =~ Host\ is\ up ]]; then
        ALIVE_IPS+=("$current_ip")
        VENDORS["$current_ip"]="Desconocido"
        MACS["$current_ip"]="Desconocida"
    elif [[ "$line" =~ MAC\ Address:\ ([A-F0-9:]+)\ \((.*)\) ]]; then
        MACS["$current_ip"]="${BASH_REMATCH[1]}"
        VENDORS["$current_ip"]="${BASH_REMATCH[2]}"
    elif [[ "$line" =~ MAC\ Address:\ ([A-F0-9:]+) ]]; then
        MACS["$current_ip"]="${BASH_REMATCH[1]}"
    fi
done < "$TMP_NMAP"

if [[ ${#ALIVE_IPS[@]} -eq 0 ]]; then
    imprimir_color "rojo" "\n\t[!] No se encontraron hosts activos en $SUBNET."
    rm -f "$TMP_NMAP"
    exit 0
fi

imprimir_color "verde" "\t[V] Se encontraron ${#ALIVE_IPS[@]} hosts vivos."
imprimir_color "turquesa" "\t[*] Fase 2: Escaneando puertos clave para deducir tipo de dispositivo..."

declare -A TYPES
declare -A PORTS_OPEN
declare -A OS_GUESS

PORTS="22,80,443,139,445,515,631,3389,9100"

for ip in "${ALIVE_IPS[@]}"; do
    TYPES["$ip"]="Dispositivo Genérico"
    PORTS_OPEN["$ip"]="Ninguno"
    OS_GUESS["$ip"]="N/A"
done

TMP_PORTS=$(mktemp)
if [[ $OS_SCAN -eq 1 ]]; then
    imprimir_color "amarillo" "\t[+] Ejecutando OS Fingerprinting (Esto tomará unos segundos)..."
    nmap -p "$PORTS" -O -T4 --open "${ALIVE_IPS[@]}" -oG "$TMP_PORTS" > /dev/null 2>&1
else
    nmap -p "$PORTS" -T4 --open "${ALIVE_IPS[@]}" -oG "$TMP_PORTS" > /dev/null 2>&1
fi

while IFS= read -r line; do
    if [[ "$line" =~ Host:\ ([0-9\.]+).*Ports:\ (.*) ]]; then
        ip="${BASH_REMATCH[1]}"
        ports_str="${BASH_REMATCH[2]}"
        
        # Extraer listado de puertos abiertos
        open_list=$(echo "$ports_str" | grep -oP '\d+/open' | awk -F'/' '{print $1}' | paste -sd "," - || true)
        if [[ -n "$open_list" ]]; then
            PORTS_OPEN["$ip"]="$open_list"
        fi
        
        # Deduccion
        is_printer=0
        is_pc_win=0
        is_pc_linux=0
        is_router=0

        if [[ "$ports_str" == *"9100/open"* || "$ports_str" == *"631/open"* || "$ports_str" == *"515/open"* ]]; then
            is_printer=1
        fi
        if [[ "$ports_str" == *"445/open"* || "$ports_str" == *"3389/open"* || "$ports_str" == *"139/open"* ]]; then
            is_pc_win=1
        fi
        if [[ "$ports_str" == *"22/open"* ]]; then
            is_pc_linux=1
        fi
        if [[ "$ports_str" == *"80/open"* || "$ports_str" == *"443/open"* ]]; then
            is_router=1
        fi
        
        if [[ $is_printer -eq 1 ]]; then
            TYPES["$ip"]="Impresora"
        elif [[ $is_pc_win -eq 1 ]]; then
            TYPES["$ip"]="PC (Windows)"
        elif [[ $is_pc_linux -eq 1 ]]; then
            TYPES["$ip"]="Servidor/PC (Linux)"
        elif [[ $is_router -eq 1 ]]; then
            TYPES["$ip"]="Router / Web / IoT"
        fi
        
        # OS Guess from nmap -oG if OS was enabled
        if [[ "$line" =~ OS:\ (.*?)[\t$] ]]; then
            OS_GUESS["$ip"]="${BASH_REMATCH[1]}"
        fi
    fi
done < "$TMP_PORTS"

echo ""
divisor azul
printf "${colorTurquesa}  %-15s | %-15s | %-17s | %-19s | %s${finColor}\n" "IP ADDRESS" "HOSTNAME" "MAC ADDRESS" "TIPO" "FABRICANTE"
divisor azul

for ip in "${ALIVE_IPS[@]}"; do
    mac="${MACS[$ip]:-Desconocida}"
    vendor="${VENDORS[$ip]:-Desconocido}"
    dtype="${TYPES[$ip]:-Desconocido}"
    hname="${HOSTNAMES[$ip]:-N/A}"
    # Truncate hostname to 15 chars for display
    hname_disp="${hname:0:15}"
    
    printf "  %-15s | %-15s | %-17s | %-19s | %s\n" "$ip" "$hname_disp" "$mac" "$dtype" "$vendor"
    if [[ $OS_SCAN -eq 1 && "${OS_GUESS[$ip]}" != "N/A" ]]; then
        printf "  ↳ OS: %-30s | Puertos: %s\n" "${OS_GUESS[$ip]}" "${PORTS_OPEN[$ip]}"
    else
        if [[ "${PORTS_OPEN[$ip]}" != "Ninguno" ]]; then
            printf "  ↳ Puertos Abiertos: %s\n" "${PORTS_OPEN[$ip]}"
        fi
    fi
done

divisor azul

# Preguntar por CSV
echo -e "\n\t${colorAmarillo}¿Exportar resultados a un archivo CSV? [s/N]${finColor}"
read -rp "        " export_csv
if [[ "${export_csv,,}" == "s" ]]; then
    FECHA=$(date +"%Y%m%d_%H%M%S")
    CSV_FILE="inventario_lan_${FECHA}.csv"
    
    echo "IP,Hostname,MAC,Fabricante,Tipo_Deducido,Sistema_Operativo,Puertos_Abiertos" > "$CSV_FILE"
    for ip in "${ALIVE_IPS[@]}"; do
        mac="${MACS[$ip]:-Desconocida}"
        vendor="${VENDORS[$ip]:-Desconocido}"
        vendor_clean=$(echo "$vendor" | sed 's/,/;/g') # Evitar comas en CSV
        dtype="${TYPES[$ip]:-Desconocido}"
        hname="${HOSTNAMES[$ip]:-N/A}"
        ports="${PORTS_OPEN[$ip]}"
        os_g="${OS_GUESS[$ip]}"
        
        echo "$ip,$hname,$mac,$vendor_clean,$dtype,$os_g,\"$ports\"" >> "$CSV_FILE"
    done
    imprimir_color "verde" "\n\t[V] Reporte guardado exitosamente en: $(pwd)/$CSV_FILE"
fi

rm -f "$TMP_NMAP" "$TMP_PORTS"

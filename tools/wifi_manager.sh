#!/bin/bash

# ==============================================================================
# Herramienta Avanzada de Gestion de MAC y Conectividad para Fedora
# ==============================================================================

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

if ! command -v nmcli &> /dev/null; then
    echo -e "${colorRojo}[!] Error: NetworkManager (nmcli) no está instalado.${finColor}"
    exit 1
fi

trap ctrl_c INT
function ctrl_c() {
    echo -e "\n${colorAmarillo}[!] Script cancelado por el usuario. Saliendo...${finColor}"
    stty echo # Asegurar que la terminal vuelva a mostrar lo que se escribe
    exit 0
}

mostrar_ayuda() {
    divisor azul
    imprimir_color "azul" "\t=== GESTOR DE CONEXIONES Y MAC PARA FEDORA ==="
    divisor azul
    echo -e "Uso: $0 [OPCIÓN]\n"
    echo "Opciones:"
    echo "  -h, --help        Muestra este menú de ayuda."
    echo "  -g, --global      Configura la MAC física (permanente) de forma GLOBAL (Requiere sudo)."
    echo "  -u, --un-global   Elimina la regla global y restaura el comportamiento por defecto de Fedora."
    echo "  Sin opciones      Inicia el modo interactivo de escaneo en tiempo real."
    exit 0
}

configuracion_global() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para configuración global...${finColor}"
        exec sudo "$0" "$@"
    fi
    echo -e "${colorAmarillo}[+] Aplicando configuración MAC física global en NetworkManager...${finColor}"
    echo -e "[device]\nwifi.scan-rand-mac-address=no\n\n[connection]\nwifi.cloned-mac-address=permanent\nethernet.cloned-mac-address=permanent" > /etc/NetworkManager/conf.d/00-mac-fija.conf
    systemctl restart NetworkManager
    echo -e "${colorVerde}[V] Éxito. Ahora todas las redes Wi-Fi and Ethernet usarán tu MAC de fábrica.${finColor}"
    exit 0
}

revertir_global() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para revertir configuración...${finColor}"
        exec sudo "$0" "$@"
    fi
    if [ -f /etc/NetworkManager/conf.d/00-mac-fija.conf ]; then
        rm -f /etc/NetworkManager/conf.d/00-mac-fija.conf
        systemctl restart NetworkManager
        echo -e "${colorVerde}[V] Configuración global eliminada. Fedora volverá a usar MAC aleatoria por defecto.${finColor}"
    else
        echo -e "${colorAmarillo}[!] No se encontró ninguna configuración global previa.${finColor}"
    fi
    exit 0
}

probar_internet() {
    echo -e "${colorAzul}[+] Verificando conectividad externa...${finColor}"
    if ping -c 2 www.google.com > /dev/null 2>&1; then
        echo -e "${colorVerde}[V] ¡Internet activo y respondiendo!${finColor}"
    else
        echo -e "${colorAmarillo}[!] Sin respuesta de Internet. Podría requerir inicio de sesión en portal cautivo o red interna.${finColor}"
    fi
}

# --- PROCESAMIENTO DE ARGUMENTOS DE LINEA DE COMANDOS ---
case "$1" in
    -h|--help) mostrar_ayuda ;;
    -g|--global) configuracion_global ;;
    -u|--un-global) revertir_global ;;
    "") ;; # Si no hay argumentos, continúa al modo interactivo
    *) echo -e "${colorRojo}[!] Opción desconocida: $1${finColor}"; mostrar_ayuda ;;
esac

# --- MODO INTERACTIVO (ESCANEO DINAMICO) ---

# Verificar estado del Wi-Fi antes de escanear
if [[ $(nmcli radio wifi) == "disabled" ]]; then
    echo -e "${colorAmarillo}[+] El Wi-Fi está apagado. Encendiéndolo...${finColor}"
    nmcli radio wifi on
    sleep 1
fi

echo -e "${colorAzul}[+] Escaneando redes Wi-Fi del entorno en tiempo real...${finColor}"
nmcli device wifi rescan 2>/dev/null
sleep 2 

# Extraer SSIDs limpios de espacios al final, eliminando duplicados y vacios
IFS=$'\n' read -r -d '' -a redes < <(nmcli --fields SSID device wifi list | grep -v -E '^(SSID|--|^$)' | sed -e 's/[[:space:]]*$//' | sort -u && printf '\0')

echo ""
divisor2 turquesa
imprimir_color "turquesa" "\t=== REDES DISPONIBLES ENCONTRADAS ==="
for i in "${!redes[@]}"; do
    echo -e "\t[$((i+1))] ${redes[$i]}"
done
echo -e "\t[$(( ${#redes[@]} + 1 ))] ${colorAmarillo}Conectarse a una Red Oculta (Escribir SSID manualmente)${finColor}"
divisor2 turquesa

echo -n "Selecciona una opción: "
read -r opcion

# Validar seleccion
opcion_oculta=$(( ${#redes[@]} + 1 ))

if [[ ! "$opcion" =~ ^[0-9]+$ ]] || [ "$opcion" -lt 1 ] || [ "$opcion" -gt "$opcion_oculta" ]; then
    echo -e "${colorRojo}[!] Opción inválida. Saliendo...${finColor}"
    exit 1
fi

if [ "$opcion" -eq "$opcion_oculta" ]; then
    echo -n "Escribe el nombre exacto (SSID) de la red oculta: "
    read -r red_seleccionada
else
    red_seleccionada="${redes[$((opcion-1))]}"
fi

echo -e "\n[+] Objetivo: ${colorVerde}\"${red_seleccionada}\"${finColor}"

# --- POLITICA DE MAC ---
echo -e "\n¿Qué política de dirección MAC deseas aplicar para esta red?"
echo "  [1] MAC Física de fábrica (Permanente / Requerida por la institución)"
echo "  [2] MAC Aleatoria estándar (Privacidad / Comportamiento por defecto)"
echo -n "Selección (1 o 2): "
read -r modo_mac

case "$modo_mac" in
    1) mac_policy="permanent" ;;
    *) mac_policy="random" ;;
esac

# --- COMPROBACION / CREACION DEL PERFIL ---
if ! nmcli connection show | grep -q "^$red_seleccionada "; then
    echo -e "${colorAzul}[+] Red nueva. Creando perfil de conexión preliminar...${finColor}"
    echo -n "¿Esta red utiliza contraseña? (s/n): "
    read -r requiere_pass
    
    if [[ "$requiere_pass" =~ ^[sS]$ ]]; then
        echo -n "Introduce la contraseña de la red: "
        stty -echo # Ocultar caracteres por seguridad
        read -r password
        stty echo
        echo ""
        nmcli connection add type wifi ifname "*" con-name "$red_seleccionada" ssid "$red_seleccionada" -- wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$password" > /dev/null
    else
        nmcli connection add type wifi ifname "*" con-name "$red_seleccionada" ssid "$red_seleccionada" > /dev/null
    fi
fi

# --- APLICACION DE REGLAS Y CONEXION ---
echo -e "${colorAmarillo}[+] Asignando política de MAC '${mac_policy}' al perfil...${finColor}"
nmcli connection modify "$red_seleccionada" wifi.cloned-mac-address "$mac_policy"

echo -e "${colorAzul}[+] Levantando la interfaz de red...${finColor}"
if nmcli connection up "$red_seleccionada"; then
    echo -e "\n${colorVerde}[V] ¡Conexión establecida con éxito!${finColor}"
    probar_internet
else
    echo -e "${colorRojo}[!] Error al activar la conexión. Revisa credenciales o nivel de señal.${finColor}"
    echo -e "${colorAmarillo}[i] Tip: Si cambiaste la contraseña de la red, puedes borrar el perfil viejo usando: nmcli connection delete \"$red_seleccionada\"${finColor}"
fi

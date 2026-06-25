#!/usr/bin/env bash
# systemd_maker.sh
# Crea servicios de systemd para scripts.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

if [[ "$EUID" -ne 0 ]]; then
    echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para crear servicios...${finColor}"
    exec sudo "$0" "$@"
fi

clear
divisor azul
imprimir_color "azul" "\t       Creador Automático de Servicios (Systemd)     "
divisor azul

echo -e "\t${colorAmarillo}Ingresa la ruta absoluta del script/programa a demonizar:${finColor}"
read -rp "        Ruta (Ej. /home/user/script.sh): " SCRIPT_PATH

if [[ ! -f "$SCRIPT_PATH" ]]; then
    imprimir_color "rojo" "\t[!] El script no existe."
    sleep 2
    exit 1
fi

echo -e "\t${colorAmarillo}Ingresa el nombre corto para tu servicio (sin espacios):${finColor}"
read -rp "        Nombre (Ej. mibot): " SVC_NAME

if [[ -z "$SVC_NAME" ]]; then exit 1; fi

SVC_FILE="/etc/systemd/system/${SVC_NAME}.service"

if [[ -f "$SVC_FILE" ]]; then
    imprimir_color "rojo" "\t[!] Ya existe un servicio con ese nombre."
    sleep 2
    exit 1
fi

# Averiguar usuario real
REAL_USER="${SUDO_USER:-root}"

cat <<EOF > "$SVC_FILE"
[Unit]
Description=Servicio auto-generado para $SVC_NAME
After=network.target

[Service]
ExecStart=$SCRIPT_PATH
Restart=always
User=$REAL_USER
Environment=PATH=/usr/bin:/usr/local/bin

[Install]
WantedBy=multi-user.target
EOF

imprimir_color "turquesa" "\t[*] Recargando demonios de systemd..."
systemctl daemon-reload
systemctl enable "$SVC_NAME"
systemctl start "$SVC_NAME"

imprimir_color "verde" "\n\t[V] Servicio creado, habilitado y en ejecución."
echo -e "\t    Puedes ver su estado con: sudo systemctl status $SVC_NAME"

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

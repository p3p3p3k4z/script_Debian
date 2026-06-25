#!/usr/bin/env bash
# cron_maker.sh
# Añade tareas programadas interactivamente.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

clear
divisor azul
imprimir_color "azul" "\t       Asistente de Tareas Programadas (Cron)     "
divisor azul

imprimir_color "turquesa" "\tAñadiremos un script para que se ejecute automáticamente."

echo -e "\n\t${colorAmarillo}Ingresa la ruta absoluta del script o comando a ejecutar:${finColor}"
read -rp "        Ruta: " cmd

if [[ -z "$cmd" ]]; then exit 0; fi

echo -e "\n\t${colorTurquesa}¿Con qué frecuencia deseas ejecutarlo?${finColor}"
echo -e "\t1. Cada minuto"
echo -e "\t2. Cada hora (en el minuto 0)"
echo -e "\t3. Todos los días a medianoche (00:00)"
echo -e "\t4. Cada reinicio del sistema (@reboot)"
echo -e "\t0. Cancelar"
divisor azul
read -rp "        Opción: " opt

CRON_EXP=""
case "$opt" in
    1) CRON_EXP="* * * * *" ;;
    2) CRON_EXP="0 * * * *" ;;
    3) CRON_EXP="0 0 * * *" ;;
    4) CRON_EXP="@reboot" ;;
    0) exit 0 ;;
    *) echo "Inválido"; exit 1 ;;
esac

# Agregar al crontab del usuario actual
TMP_CRON=$(mktemp)
crontab -l > "$TMP_CRON" 2>/dev/null || true
echo "$CRON_EXP $cmd" >> "$TMP_CRON"
crontab "$TMP_CRON"
rm -f "$TMP_CRON"

imprimir_color "verde" "\n\t[V] Tarea añadida exitosamente al Cron."
echo -e "\t${colorGris}Regla: $CRON_EXP $cmd${finColor}"

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

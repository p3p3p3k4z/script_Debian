#!/usr/bin/env bash
# duplicate_finder.sh
# Encuentra archivos duplicados para liberar espacio.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

clear
divisor azul
imprimir_color "azul" "\t        Cazador de Archivos Duplicados     "
divisor azul

if ! command -v fdupes &> /dev/null; then
    imprimir_color "amarillo" "\t[i] Instalando 'fdupes'..."
    instalar_paquetes "fdupes"
fi

DIR_DEF="$HOME/Descargas"
if [[ "$EUID" -eq 0 && -n "${SUDO_USER:-}" ]]; then
    DIR_DEF=$(eval echo "~$SUDO_USER/Descargas")
fi

echo -e "\n\t${colorTurquesa}Ingresa el directorio a escanear (Enter para: $DIR_DEF):${finColor}"
read -rp "        " SCAN_DIR
if [[ -z "$SCAN_DIR" ]]; then SCAN_DIR="$DIR_DEF"; fi

if [[ ! -d "$SCAN_DIR" ]]; then
    imprimir_color "rojo" "\t[!] El directorio '$SCAN_DIR' no existe."
    sleep 2
    exit 1
fi

imprimir_color "verde" "\n\t[*] Escaneando (comparando Hashes MD5) en $SCAN_DIR..."
imprimir_color "gris" "\t    Puede tardar varios minutos si hay muchos archivos grandes."

TMP_OUT=$(mktemp)
# -S muestra el tamaño
fdupes -S -q -r "$SCAN_DIR" > "$TMP_OUT" || true

if [[ -s "$TMP_OUT" ]]; then
    echo ""
    cat "$TMP_OUT" | sed 's/^/\t/' | head -n 30
    
    line_count=$(wc -l < "$TMP_OUT")
    if [[ $line_count -gt 30 ]]; then
        imprimir_color "gris" "\t... y muchos más."
    fi

    echo -e "\n\t${colorRojo}¿Deseas iniciar el modo de BORRADO INTERACTIVO? (Te preguntará qué copias borrar) [s/N]${finColor}"
    read -rp "        " ddel
    if [[ "${ddel,,}" == "s" ]]; then
        fdupes -d -r "$SCAN_DIR"
    fi
else
    imprimir_color "verde" "\t[V] ¡Felicidades! No se encontraron archivos duplicados en $SCAN_DIR."
fi

rm -f "$TMP_OUT"
echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

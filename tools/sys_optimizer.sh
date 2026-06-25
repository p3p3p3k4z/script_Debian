#!/usr/bin/env bash
# sys_optimizer.sh
# Limpia caches y archivos basura del sistema operativo para liberar espacio.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

if [[ "$EUID" -ne 0 ]]; then
    echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para limpiar el sistema...${finColor}"
    exec sudo "$0" "$@"
fi

divisor azul
imprimir_color "azul" "\t        Optimizador de Sistema         "
divisor azul
echo ""

# 1. Limpieza del gestor de paquetes
echo -e "${colorAmarillo}[1/4] Limpiando caché del gestor de paquetes...${finColor}"
if command -v apt &> /dev/null; then
    apt autoremove -y
    apt clean
elif command -v dnf &> /dev/null; then
    dnf autoremove -y
    dnf clean all
elif command -v zypper &> /dev/null; then
    zypper clean -a
fi
echo -e "${colorVerde}[V] Caché de paquetes limpia.${finColor}\n"

# 2. Limpieza de logs de systemd (journal)
echo -e "${colorAmarillo}[2/4] Rotando y limpiando logs del sistema (journalctl)...${finColor}"
if command -v journalctl &> /dev/null; then
    # Retener solo los ultimos 3 dias de logs
    journalctl --vacuum-time=3d
    echo -e "${colorVerde}[V] Logs de systemd optimizados.${finColor}\n"
else
    echo -e "${colorRojo}[!] journalctl no encontrado.${finColor}\n"
fi

# 3. Limpieza de Flatpak (si existe)
echo -e "${colorAmarillo}[3/5] Limpiando runtimes huérfanos de Flatpak...${finColor}"
if command -v flatpak &> /dev/null; then
    flatpak uninstall --unused -y
    echo -e "${colorVerde}[V] Flatpak optimizado.${finColor}\n"
else
    echo -e "${colorAzul}[i] Flatpak no está instalado. Omitiendo.${finColor}\n"
fi

# 4. Limpieza de Snap (si existe)
echo -e "${colorAmarillo}[4/5] Limpiando versiones antiguas de paquetes Snap...${finColor}"
if command -v snap &> /dev/null; then
    # Retiene solo la versión más reciente de cada snap
    snap list all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
        snap remove "$snapname" --revision="$revision"
    done
    echo -e "${colorVerde}[V] Snap optimizado.${finColor}\n"
else
    echo -e "${colorAzul}[i] Snap no está instalado. Omitiendo.${finColor}\n"
fi

# 5. Limpieza de cache de usuario (Thumbnails)
echo -e "${colorAmarillo}[5/5] Limpiando caché de miniaturas de imágenes del usuario...${finColor}"
# Ya que corremos como root, necesitamos encontrar la carpeta de cache real del usuario que lanzo sudo
if [[ -n "${SUDO_USER:-}" ]]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
    THUMB_DIR="${USER_HOME}/.cache/thumbnails"
    if [[ -d "$THUMB_DIR" ]]; then
        rm -rf "${THUMB_DIR:?}/"*
        echo -e "${colorVerde}[V] Caché de miniaturas de $SUDO_USER purgada.${finColor}\n"
    fi
else
    echo -e "${colorAzul}[i] No se detectó SUDO_USER. Omitiendo caché personal.${finColor}\n"
fi

divisor azul
imprimir_color "verde" "\t      ¡Optimización Completada!        "
divisor azul

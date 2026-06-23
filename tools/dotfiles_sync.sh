#!/usr/bin/env bash
# dotfiles_sync.sh
# Respalda automaticamente archivos de configuracion clave en un repositorio git local.

set -euo pipefail

source ./decorador/color.sh

# Directorio de respaldo (ajusta esto si ya tienes un repo existente)
BACKUP_DIR="${HOME}/dotfiles_backup"

# Lista de archivos/carpetas a respaldar relativos a $HOME
DOTFILES=(
    ".bashrc"
    ".zshrc"
    ".vimrc"
    ".tmux.conf"
    ".config/nvim"
    ".config/bspwm"
    ".config/sxhkd"
    ".config/kitty"
    ".config/alacritty"
)

echo -e "${colorAzul}=== Gestor de Sincronización de Dotfiles ===${finColor}"

# Inicializar directorio si no existe
if [[ ! -d "$BACKUP_DIR" ]]; then
    echo -e "${colorAmarillo}[+] Creando directorio de respaldo en $BACKUP_DIR...${finColor}"
    mkdir -p "$BACKUP_DIR"
    cd "$BACKUP_DIR"
    git init
    echo "# Mis Dotfiles" > README.md
    git add README.md
    git commit -m "Initial commit"
fi

cd "$BACKUP_DIR"

echo -e "${colorVerde}[+] Copiando configuraciones...${finColor}"
for item in "${DOTFILES[@]}"; do
    TARGET="${HOME}/${item}"
    if [[ -e "$TARGET" ]]; then
        # Preservar la estructura de directorios interna
        DEST_DIR="$(dirname "${BACKUP_DIR}/${item}")"
        mkdir -p "$DEST_DIR"
        cp -r "$TARGET" "$DEST_DIR/"
        echo -e "  -> Respaldado: ${item}"
    else
        echo -e "  -> Ignorado (no existe): ${item}"
    fi
done

echo -e "\n${colorAzul}[+] Verificando cambios en Git...${finColor}"
if [[ -z $(git status -s) ]]; then
    echo -e "${colorAmarillo}[!] No hay cambios nuevos para respaldar.${finColor}"
    exit 0
fi

git add .
git commit -m "Auto-backup: $(date +'%Y-%m-%d %H:%M:%S')"

echo -e "${colorVerde}[V] ¡Respaldo local completado!${finColor}"
echo -e "${colorAmarillo}[i] Si tienes un remoto configurado (GitHub/GitLab), empujando cambios...${finColor}"
if git remote -v | grep -q "origin"; then
    git push origin main || git push origin master
    echo -e "${colorVerde}[V] Sincronización en la nube completada.${finColor}"
else
    echo -e "${colorRojo}[!] No hay repositorio remoto configurado. Ejecuta: git remote add origin <URL>${finColor}"
fi

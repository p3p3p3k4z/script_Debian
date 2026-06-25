#!/usr/bin/env bash
# ssh_key_manager.sh
# Gestor de llaves SSH (Generar, ver, enviar al servidor)

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

# Asegurar carpeta ~/.ssh
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

generar_llave() {
    imprimir_color "turquesa" "\t[*] Generando una nueva llave moderna (ED25519)..."
    read -rp "        Nombre del archivo (ej. id_ed25519_github): " nombre_llave
    read -rp "        Comentario (ej. tu_email@correo.com): " comentario
    
    if [[ -z "$nombre_llave" ]]; then nombre_llave="id_ed25519_personal"; fi
    
    local path_llave="$HOME/.ssh/$nombre_llave"
    if [[ -f "$path_llave" ]]; then
        imprimir_color "rojo" "\t[!] Ya existe una llave con ese nombre."
        sleep 2
        return
    fi
    
    ssh-keygen -t ed25519 -C "$comentario" -f "$path_llave"
    imprimir_color "verde" "\t[V] Llave generada con éxito en $path_llave"
    sleep 2
}

enviar_llave() {
    imprimir_color "turquesa" "\n\t[+] Llaves públicas disponibles en ~/.ssh:"
    ls -1 "$HOME/.ssh"/*.pub 2>/dev/null | awk -F/ '{print "\t    " $NF}' || echo "\t    No hay llaves públicas."
    
    read -rp "        Ingresa el nombre de la llave pública a enviar (ej. id_ed25519.pub): " llave
    local path_llave="$HOME/.ssh/$llave"
    if [[ ! -f "$path_llave" ]]; then
        imprimir_color "rojo" "\t[!] La llave no existe."
        sleep 2
        return
    fi
    
    read -rp "        Usuario remoto (ej. root): " usr
    read -rp "        IP o Host remoto (ej. 192.168.1.5): " host
    
    imprimir_color "amarillo" "\t[*] Ejecutando ssh-copy-id. Te pedirá la contraseña del servidor una vez."
    ssh-copy-id -i "$path_llave" "${usr}@${host}"
    
    imprimir_color "verde" "\t[V] Operación completada."
    sleep 2
}

copiar_portapapeles() {
    imprimir_color "turquesa" "\n\t[+] Llaves públicas disponibles:"
    ls -1 "$HOME/.ssh"/*.pub 2>/dev/null | awk -F/ '{print "\t    " $NF}' || echo "\t    No hay llaves públicas."
    
    read -rp "        Ingresa la llave a copiar: " llave
    local path_llave="$HOME/.ssh/$llave"
    if [[ ! -f "$path_llave" ]]; then
        imprimir_color "rojo" "\t[!] La llave no existe."
        sleep 2
        return
    fi
    
    if command -v xclip &> /dev/null; then
        cat "$path_llave" | xclip -selection clipboard
        imprimir_color "verde" "\t[V] Llave copiada al portapapeles (X11)."
    elif command -v wl-copy &> /dev/null; then
        cat "$path_llave" | wl-copy
        imprimir_color "verde" "\t[V] Llave copiada al portapapeles (Wayland)."
    else
        if ! command -v xclip &> /dev/null; then
            imprimir_color "amarillo" "\t[i] Instalando 'xclip' para copiar al portapapeles..."
            instalar_paquetes "xclip"
        fi
        cat "$path_llave" | xclip -selection clipboard || imprimir_color "rojo" "\t[!] Falló la copia. Aquí tienes la llave:"
        echo ""
        cat "$path_llave"
    fi
    sleep 2
}

while true; do
    clear
    divisor azul
    imprimir_color "azul" "\t      Gestor de Llaves Criptográficas (SSH)      "
    divisor azul
    
    echo -e "\t1. Generar nueva llave segura (ED25519)"
    echo -e "\t2. Copiar llave pública al Portapapeles (Para GitHub/GitLab)"
    echo -e "\t3. Enviar llave pública a un Servidor (ssh-copy-id)"
    echo -e "\t0. Volver"
    divisor azul
    read -rp "        Elige una opción: " opt
    
    case "$opt" in
        1) generar_llave ;;
        2) copiar_portapapeles ;;
        3) enviar_llave ;;
        0) exit 0 ;;
        *) echo -e "\t${colorRojo}Opción inválida.${finColor}"; sleep 1 ;;
    esac
done

#!/usr/bin/env bash
# docker_janitor.sh
# Herramienta interactiva para limpiar basura de Docker.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

if ! command -v docker &> /dev/null; then
    echo -e "${colorRojo}[!] Error: Docker no está instalado o no está en el PATH.${finColor}"
    exit 1
fi

if ! docker info &> /dev/null; then
    if sudo docker info &> /dev/null; then
        echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para ejecutar Docker...${finColor}"
        exec sudo "$0" "$@"
    else
        echo -e "${colorRojo}[!] Error: El demonio de Docker no está corriendo.${finColor}"
        exit 1
    fi
fi

while true; do
    clear
    divisor azul
    imprimir_color "azul" "\t        Docker Janitor (Limpiador)       "
    divisor azul
    imprimir_color "amarillo" "\n\tUso de Disco Actual:"
    docker system df
    echo ""
    divisor azul
    echo -e "\t1. Eliminar contenedores detenidos"
    echo -e "\t2. Eliminar imágenes colgantes (dangling <none>)"
    echo -e "\t3. Eliminar volúmenes huérfanos"
    echo -e "\t4. Limpieza total segura (prune system)"
    echo -e "\t5. Nuclear Wipe (Borrar TODO excepto lo que corre ahora)"
    echo -e "\t0. Salir"
    divisor azul
    read -rp "        Elige una opción [0-5]: " opt

    case "$opt" in
        1)
            echo -e "${colorVerde}[+] Eliminando contenedores detenidos...${finColor}"
            docker container prune -f
            sleep 2
            ;;
        2)
            echo -e "${colorVerde}[+] Eliminando imágenes colgantes...${finColor}"
            docker image prune -f
            sleep 2
            ;;
        3)
            echo -e "${colorVerde}[+] Eliminando volúmenes huérfanos...${finColor}"
            docker volume prune -f
            sleep 2
            ;;
        4)
            echo -e "${colorVerde}[+] Limpieza total segura...${finColor}"
            docker system prune -f
            sleep 2
            ;;
        5)
            echo -e "${colorRojo}[!] PELIGRO: Esto borrará todas las imágenes sin uso, cache, y redes.${finColor}"
            read -rp "¿Estás seguro? (s/N): " confirm
            if [[ "${confirm,,}" == "s" ]]; then
                docker system prune -a -f --volumes
            fi
            sleep 2
            ;;
        0)
            echo "Saliendo de Docker Janitor..."
            exit 0
            ;;
        *)
            echo -e "${colorRojo}Opción inválida.${finColor}"
            sleep 1
            ;;
    esac
done

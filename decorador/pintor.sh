#! /bin/bash

source ./decorador/color.sh

function imprimir_color() {
    local color_arg="$1"
    local texto="$2"
    local cierre="${3:-$finColor}"
    local color=""

    case "${color_arg,,}" in
        rojo) color="$colorRojo" ;;
        verde) color="$colorVerde" ;;
        azul) color="$colorAzul" ;;
        amarillo) color="$colorAmarillo" ;;
        morado) color="$colorMorado" ;;
        turquesa) color="$colorTurquesa" ;;
        gris) color="$colorGris" ;;
        "") color="$finColor" ;;
        *) color="$color_arg" ;; 
    esac

    echo -e "${color}${texto}${cierre}"
}

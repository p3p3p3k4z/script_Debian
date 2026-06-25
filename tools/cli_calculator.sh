#!/usr/bin/env bash
# cli_calculator.sh
# Calculadora interactiva CLI.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

clear
divisor azul
imprimir_color "azul" "\t        Calculadora Científica CLI (bc)      "
divisor azul

if ! command -v bc &> /dev/null; then
    imprimir_color "amarillo" "\t[i] Instalando 'bc'..."
    instalar_paquetes "bc"
fi

imprimir_color "turquesa" "\tEscribe la expresión matemática (ej. 5+5, 10/3, 2^8, sqrt(9))."
imprimir_color "turquesa" "\tEscribe 'q' o 'salir' para terminar."
echo ""

while true; do
    read -rp "    [Calc] > " expr
    
    if [[ "${expr,,}" == "q" || "${expr,,}" == "quit" || "${expr,,}" == "salir" ]]; then
        break
    fi
    
    if [[ -z "$expr" ]]; then continue; fi
    
    set +e
    resultado=$(echo "scale=4; $expr" | bc -l 2>&1)
    err=$?
    set -e
    
    if [[ $err -ne 0 || "$resultado" == *"error"* || "$resultado" == *"parse"* ]]; then
        imprimir_color "rojo" "\tError de sintaxis."
    else
        # Limpiar formato de floats
        res_limpio=$(echo "$resultado" | sed '/\./ s/\.\?0*$//')
        # Si bc devuelve .5 en vez de 0.5
        if [[ "$res_limpio" == .* ]]; then res_limpio="0$res_limpio"; fi
        if [[ "$res_limpio" == -.* ]]; then res_limpio="-0${res_limpio#-}"; fi
        
        imprimir_color "verde" "\t= $res_limpio"
    fi
done

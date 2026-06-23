#!/bin/bash
# Script de Mantenimiento Personal con Menu Interactivo y Seleccion de Borrado.

set -u

# --- Funciones de Utilidad ---
die(){ echo "ERROR: $*" >&2; exit 1; }

# --- Funcion de check_space (Solo Listar y Guardar Top 15) ---
check_space() {
    local threshold_mb="${1:-100}"
    
    local home="$HOME"
    
    echo "Revisión de espacio en: $home (Archivos > ${threshold_mb}MB)"
    echo "— Fecha: $(date '+%F %T')"
    echo

    echo "== Archivos mayores a ${threshold_mb}MB en \$HOME (top 15) =="
    
    local i=1
    local top_files=()

    find "$home" -type f -size +"${threshold_mb}"M -printf '%s\t%p\n' 2>/dev/null \
        | sort -nr \
        | head -n 15 \
        | while read -r line; do
            sz=$(echo "$line" | cut -f1)
            path=$(echo "$line" | cut -f2)
            
            # Formateo legible (usando awk solo para presentacion)
            formatted_line=$(echo "$sz $path" | awk '{
                sz=$1; path=$2;
                unit="B";
                if (sz>1024){sz/=1024;unit="KB"}
                if (sz>1024){sz/=1024;unit="MB"}
                if (sz>1024){sz/=1024;unit="GB"}
                printf "%s) %8.1f %s\t%s\n", NF, sz, unit, path
            }' NF="$i")

            echo "$formatted_line"
            top_files+=("$path")

            ((i++))
        done

    # Exporta los archivos encontrados para que el menu los use
    printf "%s\n" "${top_files[@]}" > /tmp/maintenance_top_files.tmp
    
    echo
    echo "== Uso de disco (top niveles en \$HOME) =="
    du -sh "$home"/* 2>/dev/null | sort -h | tail -n 10
    echo
}

# --- Funcion de old_files (Solo Listar y Guardar) ---
old_files() {
    local days="${1:-60}"
    local dir="${2:-}"
    
    # Directorio por defecto: $HOME/Documentos si existe; si no, $HOME
    if test -z "$dir"; then
        if test -d "$HOME/Documentos"; then
            dir="$HOME/Documentos"
        else
            dir="$HOME"
        fi
    fi

    if test ! -d "$dir"; then
        die "El directorio $dir no existe."
    fi

    echo "== Archivos en '$dir' no modificados en más de $days días =="
    
    local i=1
    local old_files_list=()

    # Buscar archivos antiguos e imprimir con un indice para seleccion
    find "$dir" -type f -mtime +"$days" -print | while read -r file; do
        printf "%s) %s\n" "$i" "$file"
        old_files_list+=("$file")
        ((i++))
    done
    
    # Exporta los archivos encontrados para que el menu los use
    printf "%s\n" "${old_files_list[@]}" > /tmp/maintenance_old_files.tmp
    
    echo
}

# --- Funciones del Menu Interactivo ---

show_menu() {
    clear
    echo "========================================"
    echo " Menú de Mantenimiento Personal "
    echo "========================================"
    echo "1. Revisar Espacio y Eliminar Archivos Grandes"
    echo "2. Buscar y Eliminar Archivos Antiguos"
    echo "0. Salir"
    echo "========================================"
}

read_option() {
    local choice
    read -p "Ingrese su opción [0-2]: " choice
    echo "$choice"
}

# --- Logica Principal del Menu (Controlador) ---

main_loop() {
    while true; do
        show_menu
        CHOICE=$(read_option)
        
        case $CHOICE in
            1) # check-space: Selección Interactiva por Tamaño
                echo ""
                read -p "Ingrese umbral de tamaño en MB (defecto: 100): " UMBRAL
                UMBRAL=${UMBRAL:-100}
                
                # Ejecutar check_space para LISTAR y guardar los archivos
                echo "--- Ejecutando análisis de espacio ---"
                check_space "$UMBRAL"
                
                # Cargar el array de archivos encontrados (top 15)
                IFS=$'\n' read -d '' -r -a FILES_FOUND < /tmp/maintenance_top_files.tmp 
                rm -f /tmp/maintenance_top_files.tmp
                
                if [ ${#FILES_FOUND[@]} -eq 0 ]; then
                    echo "No se encontraron archivos mayores a ${UMBRAL}MB."
                else
                    echo ""
                    echo "==========================================="
                    echo "  Selección de Archivos GRANDES a Eliminar (Top ${#FILES_FOUND[@]})"
                    echo "==========================================="
                    
                    for i in "${!FILES_FOUND[@]}"; do
                        file_path="${FILES_FOUND[$i]}"
                        file_index=$((i + 1))
                        
                        read -p "¿Eliminar archivo ${file_index}? (s/N): " DELETE_CONFIRM
                        if [[ "$DELETE_CONFIRM" =~ ^[sS]$ ]]; then
                            echo "  Eliminando: $file_path"
                            rm -f "$file_path"
                        else
                            echo " Omitido."
                        fi
                    done
                fi

                read -p "Presione [Enter] para continuar..."
                ;;
                
            2) # old-files: Selección Interactiva por Antigüedad
                echo ""
                read -p "Ingrese la antigüedad mínima en días (defecto: 60): " DIAS
                DIAS=${DIAS:-60}
                
                read -p "Ingrese el directorio a revisar (defecto: \$HOME/Documentos o \$HOME): " DIRECTORIO
                
                # Ejecutar old_files para LISTAR y guardar los archivos
                echo "--- Ejecutando análisis de archivos antiguos ---"
                old_files "$DIAS" "$DIRECTORIO"

                # Cargar el array de archivos encontrados
                IFS=$'\n' read -d '' -r -a FILES_FOUND < /tmp/maintenance_old_files.tmp 
                rm -f /tmp/maintenance_old_files.tmp
                
                if [ ${#FILES_FOUND[@]} -eq 0 ]; then
                    echo "No se encontraron archivos más antiguos de ${DIAS} días."
                else
                    echo ""
                    echo "==========================================="
                    echo "  Selección de Archivos ANTIGUOS a Eliminar (${#FILES_FOUND[@]} encontrados)"
                    echo "==========================================="

                    for i in "${!FILES_FOUND[@]}"; do
                        file_path="${FILES_FOUND[$i]}"
                        file_index=$((i + 1))
                        
                        read -p "¿Eliminar archivo ${file_index} ('$file_path')? (s/N): " DELETE_CONFIRM
                        if [[ "$DELETE_CONFIRM" =~ ^[sS]$ ]]; then
                            echo " Eliminando: $file_path"
                            rm -f "$file_path"
                        else
                            echo "  Omitido."
                        fi
                    done
                fi
                
                read -p "Presione [Enter] para continuar..."
                ;;
                
            0) # Salir
                echo "Saliendo del script de mantenimiento"
                exit 0
                ;;
                
            *) # Opción Inválida
                echo "Opción no válida. Inténtelo de nuevo."
                read -p "Presione [Enter] para continuar..."
                ;;
        esac
    done
}

# Iniciar el bucle principal
main_loop

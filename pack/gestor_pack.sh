#! /bin/bash
source ./decorador/separador.sh
source ./decorador/color.sh

# --- Funciones para Debian/Derivados (APT/Nala) ---

function actualizar_pack_debian() {
    echo -e "\nActualizando la lista de paquetes para Debian/Derivadas..."
    if command -v nala &> /dev/null; then
        sudo nala update
        sleep 3
        echo -e "\nActualizando los paquetes instalados para Debian/Derivadas..."
        sudo nala upgrade --assume-yes
    else
        echo -e "\nNala no está instalado, usando apt para actualizar la lista de paquetes..."
        sudo apt update
        sleep 3
        echo -e "\nActualizando los paquetes instalados para Debian/Derivadas..."
        sudo apt upgrade -y
    fi
    echo "Todo listo *<:^)"
}

function buscar_pack_debian() {
    local pack

    echo -e "\nDime el nombre del paquete a buscar en el sistema (dpkg)"
    read pack
    if sudo dpkg-query --list | grep -i "$pack"; then
        echo "Paquete(s) encontrado(s)."
    else
        echo "No se encontraron paquetes con el nombre: $pack"
    fi
}

function buscaronline_pack_debian(){
    local pack opp np

    echo -e "\nDime el nombre del paquete a buscar en línea (nala/apt)"
    read pack

    local pkg_manager_search="nala search"
    local pkg_manager_show="nala show"
    if ! command -v nala &> /dev/null; then
        pkg_manager_search="apt search"
        pkg_manager_show="apt show"
    fi

    if $pkg_manager_search "$pack"; then
        divisor2 
        echo "¿Deseas conocer más sobre el paquete? (S/s)"
        read opp

        if [[ "$opp" == "S" || "$opp" == "s" || "$opp" == "" ]]; then
            echo "Ingresa el nombre exacto del paquete para ver detalles:"
            read np
            divisor 
            $pkg_manager_show "$np"
            divisor
        fi
    else
        echo "No se encontraron paquetes con el nombre: $pack"
    fi
}

function eliminar_pack_debian() {
    local pack confirm

    echo -e "\nDime el nombre del paquete a eliminar"
    read pack
    echo "¿Estás seguro de que deseas eliminar el paquete '$pack'? (s/n)"
    read confirm
    if [[ "$confirm" == "s" || "$confirm" == "S" || "$confirm" == "" ]]; then
        sudo apt remove --purge -y "$pack"
        echo "Paquete '$pack' eliminado."
    else
        echo "Operación cancelada."
    fi
}

function limpiar_pack_debian() {
    echo "Limpiando paquetes innecesarios para Debian/Derivadas..."
    sudo apt autoremove -y
    sudo apt clean
    echo "Sistema limpio."
}

# --- Funciones para Fedora/Derivadas (DNF) ---

function actualizar_pack_fedora() {
    echo -e "\nActualizando la lista de paquetes para Fedora/Derivadas..."
    sudo dnf check-update
    sleep 3
    echo -e "\nActualizando los paquetes instalados para Fedora/Derivadas..."
    sudo dnf upgrade -y
    echo "Todo listo *<:^)"
}

function buscar_pack_fedora() {
    local pack

    echo -e "\nDime el nombre del paquete a buscar en el sistema (RPM)"
    read pack
    if rpm -qa | grep -i "$pack"; then
        echo "Paquete(s) encontrado(s)."
    else
        echo "No se encontraron paquetes con el nombre: $pack"
    fi
}

function buscaronline_pack_fedora(){
    local pack opp np

    echo -e "\nDime el nombre del paquete a buscar en línea (DNF)"
    read pack

    if sudo dnf search "$pack"; then
        divisor2
        echo "¿Deseas conocer más sobre el paquete? (S/s)"
        read opp

        if [[ "$opp" == "S" || "$opp" == "s" || "$opp" == "" ]]; then
            echo "Ingresa el nombre exacto del paquete para ver detalles:"
            read np
            divisor
            sudo dnf info "$np"
            divisor
        fi
    else
        echo "No se encontraron paquetes con el nombre: $pack"
    fi
}

function eliminar_pack_fedora() {
    local pack confirm

    echo -e "\nDime el nombre del paquete a eliminar"
    read pack
    echo "¿Estás seguro de que deseas eliminar el paquete '$pack'? (s/n)"
    read confirm
    if [[ "$confirm" == "s" || "$confirm" == "S" || "$confirm" == "" ]]; then
        sudo dnf remove -y "$pack"
        echo "Paquete '$pack' eliminado."
    else
        echo "Operación cancelada."
    fi
}

function limpiar_pack_fedora() {
    echo "Limpiando paquetes innecesarios para Fedora/Derivadas..."
    sudo dnf autoremove -y
    sudo dnf clean all
    echo "Sistema limpio."
}

# --- Funciones para OpenSUSE/Derivadas (Zypper) ---

function actualizar_pack_opensuse() {
    echo -e "\nActualizando la lista de paquetes para OpenSUSE/Derivadas..."
    sudo zypper refresh
    sleep 3
    echo -e "\nActualizando los paquetes instalados para OpenSUSE/Derivadas..."
    sudo zypper update -y
    echo "Todo listo *<:^)"
}

function buscar_pack_opensuse() {
    local pack

    echo -e "\nDime el nombre del paquete a buscar en el sistema (RPM)"
    read pack
    if rpm -qa | grep -i "$pack"; then
        echo "Paquete(s) encontrado(s)."
    else
        echo "No se encontraron paquetes con el nombre: $pack"
    fi
}

function buscaronline_pack_opensuse(){
    local pack opp np

    echo -e "\nDime el nombre del paquete a buscar en línea (Zypper)"
    read pack

    if sudo zypper search "$pack"; then
        divisor2
        echo "¿Deseas conocer más sobre el paquete? (S/s)"
        read opp

        if [[ "$opp" == "S" || "$opp" == "s" || "$opp" == "" ]]; then
            echo "Ingresa el nombre exacto del paquete para ver detalles:"
            read np
            divisor
            sudo zypper info "$np"
            divisor
        fi
    else
        echo "No se encontraron paquetes con el nombre: $pack"
    fi
}

function eliminar_pack_opensuse() {
    local pack confirm

    echo -e "\nDime el nombre del paquete a eliminar"
    read pack
    echo "¿Estás seguro de que deseas eliminar el paquete '$pack'? (s/n)"
    read confirm
    if [[ "$confirm" == "s" || "$confirm" == "S" || "$confirm" == "" ]]; then
        sudo zypper remove -y "$pack"
        echo "Paquete '$pack' eliminado."
    else
        echo "Operación cancelada."
    fi
}

function limpiar_pack_opensuse() {
    echo "Limpiando paquetes innecesarios para OpenSUSE/Derivadas..."
    sudo zypper clean --all
    echo "Sistema limpio."
}


# --- Funcion principal de menu de paquetes (menu_pack) ---
# Esta funcion actua como un "router" que llama a la funcion especifica de la distro.
function menu_pack() {
    if [ -z "$DISTRO_FAMILY" ]; then
        echo "${colorRojo}Error: La distribución no ha sido detectada correctamente. Ejecuta el script principal.${finColor}"
        return 1
    fi

    while true; do
        echo -e "\n\nMenú de Gestión de Paquetes (${DISTRO_FAMILY/ आधारित/})" # Muestra la familia de la distro
        echo "1- Actualizar Paquetes"
        echo "2- Buscar un Paquete Instalado"
        echo "3- Buscar en Línea un Paquete"
        echo "4- Eliminar un Paquete"
        echo "5- Limpiar Paquetes del Sistema"
        echo "6- Regresar al Menú Principal"
        echo "Teclea una opción"
        read opp

        case $opp in
            1)
                case "$DISTRO_FAMILY" in
                    debian_based) actualizar_pack_debian ;;
                    fedora_based) actualizar_pack_fedora ;;
                    opensuse_based) actualizar_pack_opensuse ;;
                    *) echo "${colorRojo}ERROR: Actualización no soportada para esta distribución.${finColor}" ;;
                esac
                ;;
            2)
                case "$DISTRO_FAMILY" in
                    debian_based) buscar_pack_debian ;;
                    fedora_based) buscar_pack_fedora ;;
                    opensuse_based) buscar_pack_opensuse ;;
                    *) echo "${colorRojo}ERROR: Búsqueda de paquete instalado no soportada para esta distribución.${finColor}" ;;
                esac
                ;;
            3)
                case "$DISTRO_FAMILY" in
                    debian_based) buscaronline_pack_debian ;;
                    fedora_based) buscaronline_pack_fedora ;;
                    opensuse_based) buscaronline_pack_opensuse ;;
                    *) echo "${colorRojo}ERROR: Búsqueda de paquete en línea no soportada para esta distribución.${finColor}" ;;
                esac
                ;;
            4)
                case "$DISTRO_FAMILY" in
                    debian_based) eliminar_pack_debian ;;
                    fedora_based) eliminar_pack_fedora ;;
                    opensuse_based) eliminar_pack_opensuse ;;
                    *) echo "${colorRojo}ERROR: Eliminación de paquete no soportada para esta distribución.${finColor}" ;;
                esac
                ;;
            5)
                case "$DISTRO_FAMILY" in
                    debian_based) limpiar_pack_debian ;;
                    fedora_based) limpiar_pack_fedora ;;
                    opensuse_based) limpiar_pack_opensuse ;;
                    *) echo "${colorRojo}ERROR: Limpieza de sistema no soportada para esta distribución.${finColor}" ;;
                esac
                ;;
            6)
                echo "Regresando al menú principal..."
                break
                ;;
            *)
                echo "${colorRojo}Opción inválida. Por favor, selecciona una opción válida.${finColor}"
                ;;
        esac

        echo -e "\n${colorAmarillo}Presiona cualquier tecla para continuar...${finColor}"
        read -n 1
    done
}

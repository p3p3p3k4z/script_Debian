#!/bin/bash

KVM_BLACKLIST_FILE="/etc/modprobe.d/blacklist-kvm.conf"
KVM_MODULES_COMMON="kvm"
KVM_MODULE_INTEL="kvm_intel"
KVM_MODULE_AMD="kvm_amd"

# Determine CPU type
if grep -q "vendor_id.*GenuineIntel" /proc/cpuinfo; then
    CPU_TYPE="Intel"
    KVM_MODULE_SPECIFIC="$KVM_MODULE_INTEL"
elif grep -q "vendor_id.*AuthenticAMD" /proc/cpuinfo; then
    CPU_TYPE="AMD"
    KVM_MODULE_SPECIFIC="$KVM_MODULE_AMD"
else
    CPU_TYPE="Unknown"
    echo "Advertencia: No se pudo determinar el tipo de CPU (Intel/AMD). Usaremos módulos genéricos."
    KVM_MODULE_SPECIFIC="" 
fi

echo "Tipo de CPU detectado: $CPU_TYPE"

# Function to update initramfs based on available commands
update_initramfs_command() {
    echo "Actualizando initramfs. Esto puede tomar un momento..."
    if command -v dracut &> /dev/null; then
        echo "Usando dracut -f..."
        sudo dracut -f
    elif command -v update-initramfs &> /dev/null; then
        echo "Usando update-initramfs -u..."
        sudo update-initramfs -u
    else
        echo "Error: No se encontró 'dracut' ni 'update-initramfs'. No se pudo actualizar el initramfs."
        echo "Por favor, actualiza tu initramfs manualmente."
        return 1
    fi
    return 0
}

# [PERSISTENTE] Function to enable KVM (Requires Reboot)
enable_kvm() {
    echo "Habilitando módulos KVM (Método Persistente)..."
    if [ -f "$KVM_BLACKLIST_FILE" ]; then
        sudo sed -i "/blacklist $KVM_MODULES_COMMON/d" "$KVM_BLACKLIST_FILE"
        sudo sed -i "/blacklist $KVM_MODULE_INTEL/d" "$KVM_BLACKLIST_FILE"
        sudo sed -i "/blacklist $KVM_MODULE_AMD/d" "$KVM_BLACKLIST_FILE"
        if [ ! -s "$KVM_BLACKLIST_FILE" ]; then
            sudo rm "$KVM_BLACKLIST_FILE"
        fi
    fi
    if update_initramfs_command; then
        echo -e "\n¡KVM habilitado permanentemente! REINICIA para aplicar."
    fi
}

# [PERSISTENTE] Function to disable KVM (Requires Reboot)
disable_kvm() {
    echo "Deshabilitando módulos KVM (Método Persistente)..."
    sudo mkdir -p "$(dirname "$KVM_BLACKLIST_FILE")"
    echo "blacklist $KVM_MODULES_COMMON" | sudo tee "$KVM_BLACKLIST_FILE" > /dev/null
    if [ "$CPU_TYPE" == "Intel" ]; then
        echo "blacklist $KVM_MODULE_INTEL" | sudo tee -a "$KVM_BLACKLIST_FILE" > /dev/null
    elif [ "$CPU_TYPE" == "AMD" ]; then
        echo "blacklist $KVM_MODULE_AMD" | sudo tee -a "$KVM_BLACKLIST_FILE" > /dev/null
    fi
    if update_initramfs_command; then
        echo -e "\n¡KVM deshabilitado permanentemente! REINICIA para aplicar."
    fi
}

check_secure_boot_error() {
    # Revisamos si el log del sistema acusa problemas de firmas (Key was rejected)
    if journalctl -u vboxdrv.service -n 20 2>/dev/null | grep -q "Key was rejected"; then
        echo -e "\n\033[0;31m========================================================="
        echo "DETECTADO: Bloqueo de UEFI Secure Boot (Key Rejected)"
        echo "=========================================================\033[0m"
        echo "El kernel rechazó los módulos de VirtualBox porque no están firmados."
        echo "Para solucionarlo de forma avanzada sin apagar Secure Boot, ejecuta:"
        echo ""
        echo "  1) sudo kmodgenca   (Si te dice que ya existe, salta al paso 2)"
        echo "  2) sudo akmods --force"
        echo "  3) sudo mokutil --import /etc/pki/akmods/certs/public_key.der"
        echo -e "	Puedes generar tu propias pass como 1234\n"
        echo "IMPORTANTE: Tras el paso 3, REINICIA el equipo y en la pantalla"
        echo "   azul (MOK Management) selecciona 'Enroll MOK' e introduce la contraseña."
        echo "========================================================="
        return 0
    fi
    return 1
}

# [LIVE] Deshabilitar KVM y activar VirtualBox de inmediato
disable_kvm_live() {
    echo "=== Liberando procesador para VirtualBox (Sin Reiniciar) ==="
    
    echo "Deteniendo servicios de libvirt/KVM..."
    sudo systemctl stop libvirtd 2>/dev/null
    
    echo "Descargando módulos de KVM..."
    sudo rmmod $KVM_MODULE_SPECIFIC 2>/dev/null
    sudo rmmod $KVM_MODULE_COMMON 2>/dev/null
    
    echo "Cargando módulos de VirtualBox..."
    sudo modprobe vboxdrv 2>/dev/null
    sudo modprobe vboxnetflt 2>/dev/null
    sudo modprobe vboxnetadp 2>/dev/null
    
    # Intentamos reiniciar el servicio oficial para verificar que todo esté en orden
    if sudo systemctl restart vboxdrv.service 2>/dev/null; then
        echo -e "\n¡Listo! Módulos KVM removidos y VirtualBox activado con éxito."
    else
        echo -e "\nError al levantar el servicio de VirtualBox (vboxdrv.service)."
        # Ejecutamos el diagnóstico para ver si es por culpa de Secure Boot
        check_secure_boot_error
    fi
}

# [LIVE] Apagar VirtualBox y restaurar KVM de inmediato
enable_kvm_live() {
    echo "=== Restaurando KVM del sistema (Sin Reiniciar) ==="
    
    echo "Descargando módulos de VirtualBox..."
    sudo rmmod vboxnetadp 2>/dev/null
    sudo rmmod vboxnetflt 2>/dev/null
    sudo rmmod vboxdrv 2>/dev/null
    
    echo "Volviendo a cargar módulos KVM..."
    sudo modprobe $KVM_MODULE_COMMON 2>/dev/null
    if [ -n "$KVM_MODULE_SPECIFIC" ]; then
        sudo modprobe $KVM_MODULE_SPECIFIC 2>/dev/null
    fi
    
    echo "Iniciando servicios de libvirt..."
    sudo systemctl start libvirtd 2>/dev/null
    
    echo -e "\n¡Listo! KVM vuelve a estar activo y disponible de inmediato."
}

# MENÚ PRINCIPAL
function_kvm(){
    while true; do
        echo "================================================="
        echo "   Script de Gestión de Virtualizacion (Fedora)  "
        echo "================================================="
        echo " METODOS EN CALIENTE (Sin reiniciar):"
        echo "   1. Activar VirtualBox (Apagar KVM ahora)"
        echo "   2. Restaurar KVM nativo (Apagar VirtualBox ahora)"
        echo " METODOS PERSISTENTES (Requieren reiniciar):"
        echo "   3. Habilitar KVM por defecto permanentemente"
        echo "   4. Deshabilitar KVM por defecto permanentemente"
        echo " -----------------------------------------------"
        echo "   0. Salir"
        echo "================================================="

        read -p "Elige una opción (1-5): " choice

        case $choice in
            1)
                disable_kvm_live
                break
                ;;
            2)
                enable_kvm_live
                break
                ;;
            3)
                enable_kvm
                break
                ;;
            4)
                disable_kvm
                break
                ;;
            0)
                echo "Saliendo de KVM ..."
                exit 0
                ;;
            *)
                clear
                echo -e "Opción inválida. Por favor, elige un número del 1 al 4.\n"
                ;;
        esac
    done
}

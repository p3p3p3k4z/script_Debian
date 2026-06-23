#! /bin/bash

export paquete_inicial_debian=("curl" "git" "neofetch" "htop" "gufw" "xinput" "tree" "nala" "aptitude" "btop" "net-tools")
export paquete_inicial_fedora=("curl" "git" "fastfetch" "htop" "firewalld" "tree" "dnf-plugins-core" "btop" "net-tools") # firewalld es la alternativa a gufw, xinput está en xorg-x11-server-utils
export paquete_inicial_opensuse=("curl" "git" "fastfetch" "htop" "firewalld" "tree" "btop" "net-tools" "xinput" ) 

# --- Funciones de Instalacion Base por Distro ---

function inicio_debian() {
    echo -e "\nIniciando configuración básica para Debian/Derivadas..."
    sudo apt update -y
    sudo apt install open-vm-tools-desktop -y # Si es relevante para tu caso
    sudo apt update -y
    sudo apt dist-upgrade -y
    sudo apt autoremove -y
    echo "Configuración inicial de Debian/Derivadas completada."
}

function inicio_fedora() {
    echo -e "\nIniciando configuración básica para Fedora/Derivadas..."
    sudo dnf check-update
    sudo dnf upgrade -y
    sudo dnf autoremove -y
    echo "Configuración inicial de Fedora/Derivadas completada."
}

function inicio_opensuse() {
    echo -e "\nIniciando configuración básica para OpenSUSE/Derivadas..."
    sudo zypper refresh
    sudo zypper update -y
    sudo zypper clean --all
    echo "Configuración inicial de OpenSUSE/Derivadas completada."
}

# --- Funcion para instalar paquetes basicos (rutina instalar_basico) ---

function instalar_basico_debian() {
    echo -e "\nInstalando paquetes básicos para Debian/Derivadas..."
    for pack in "${paquete_inicial_debian[@]}"; do
        if dpkg -s "$pack" &> /dev/null; then
            echo "$pack ya está instalado."
        else
            echo "Instalando $pack ..."
            sudo apt install -y "$pack"
        fi
    done
    # Instalar nala y aptitude si no estan, ya que se usan en otras funciones Debian
    if ! dpkg -s nala &> /dev/null; then sudo apt install -y nala; fi
    if ! dpkg -s aptitude &> /dev/null; then sudo apt install -y aptitude; fi
}

function instalar_basico_fedora() {
    echo -e "\nInstalando paquetes básicos para Fedora/Derivadas..."
    for pack in "${paquete_inicial_fedora[@]}"; do
        if rpm -q "$pack" &> /dev/null; then
            echo "$pack ya está instalado."
        else
            echo "Instalando $pack ..."
            sudo dnf install -y "$pack"
        fi
    done
}

function instalar_basico_opensuse() {
    echo -e "\nInstalando paquetes básicos para OpenSUSE/Derivadas..."
    for pack in "${paquete_inicial_opensuse[@]}"; do
        if rpm -q "$pack" &> /dev/null; then
            echo "$pack ya está instalado."
        else
            echo "Instalando $pack ..."
            sudo zypper install -y "$pack"
        fi
    done
}

# --- Lenguajes de Programacion ---

function f_c_debian() {
    echo "Instalando herramientas C/C++ para Debian/Derivadas..."
    sudo nala install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev pkg-config --assume-yes --install-recommends --install-suggests
}
function f_c_fedora() {
    echo "Instalando herramientas C/C++ para Fedora/Derivadas..."
    sudo dnf install -y @development-tools zlib-devel ncurses-devel gdbm-devel nss-devel openssl-devel readline-devel libffi-devel sqlite-devel wget bzip2-devel 
}
function f_c_opensuse() {
    echo "Instalando herramientas C/C++ para OpenSUSE/Derivadas..."
    sudo zypper -n install -t pattern devel_basis
    sudo zypper install -y zlib-devel ncurses-devel gdbm-devel libopenssl-devel readline-devel libffi-devel sqlite3-devel wget libbz2-devel 
}

function f_java_debian() {
    echo "Instalando Java para Debian/Derivadas..."
    sudo nala install openjdk-17-jdk default-jdk --assume-yes --install-recommends 
}
function f_java_fedora() {
    echo "Instalando Java para Fedora/Derivadas..."
    sudo dnf install -y java-21-openjdk java-latest-openjdk
}
function f_java_opensuse() {
    echo "Instalando Java para OpenSUSE/Derivadas..."
    sudo zypper install -y java-21-openjdk-devel 
}

function f_python_debian() {
    echo "Instalando Python y módulos para Debian/Derivadas..."
    sudo nala install python3-all-dev python3-pip python3-psutil python3-twisted stress python3-setuptools python3-pyqt5 python3-pip python3-tk python3-pygame python3-wxgtk4.0 --assume-yes --install-recommends
}
function f_python_fedora() {
    echo "Instalando Python y módulos para Fedora/Derivadas..."
    # Algunos paquetes pueden tener nombres diferentes en Fedora
    sudo dnf install -y python3-devel python3-pip python3-psutil python3-twisted stress python3-setuptools python3-PyQt5 python3-tkinter python3-pygame 
}
function f_python_opensuse() {
    echo "Instalando Python y módulos para OpenSUSE/Derivadas..."
    # Nombres de paquetes en OpenSUSE tambien pueden variar
    sudo zypper install -y python3-devel python3-pip python3-psutil python3-setuptools python3-PyQt5 python3-tk python3-pygame 
}

# --- Multimedia ---

function f_media_debian() {
    echo "Instalando reproductores multimedia para Debian/Derivadas..."
    sudo aptitude install vlc mpv -y
}
function f_media_fedora() {
    echo "Instalando reproductores multimedia para Fedora/Derivadas..."
    # Se recomienda instalar RPM Fusion antes para estos paquetes
    sudo dnf install -y vlc mpv
}
function f_media_opensuse() {
    echo "Instalando reproductores multimedia para OpenSUSE/Derivadas..."
    # Se recomienda instalar Packman antes para estos paquetes
    sudo zypper install -y vlc mpv
}

# --- Diseno ---

function f_diseno_debian(){
	sudo apt install -y krita blender gimp
	}	
function f_diseno_opensuse(){
	sudo zypper install -y krita blender libresprite gimp
	}
	
# --- temas ---
function f_tema_opensuse(){
	sudo zypper in xfwm4-theme*
	sudo zypper in papirus*
	}

# --- codium ---
function f_codium_opensuse(){
	sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
	echo -e "[codium]\nname=Codium Repository\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1" | sudo tee /etc/zypp/repos.d/codium.repo
	sudo zypper refresh
	sudo zypper install codium
	}

# --- Decoradores para PC ---

function f_chacharas_debian() {
    echo "Instalando 'chacharas' para Debian/Derivadas..."
    sudo nala install -y cbonsai lolcat toilet cowsay fortunes cmatrix oneko hollywood cmus moc
}
function f_chacharas_fedora() {
    echo "Instalando 'chacharas' para Fedora/Derivadas..."
    sudo dnf install -y lolcat toilet cowsay cmatrix oneko cmus moc astroterm # cbonsai, hollywood y fortunes-es podrían no estar directamente en los repos oficiales
}
function f_chacharas_opensuse() {
    echo "Instalando 'chacharas' para OpenSUSE/Derivadas..."
    sudo zypper install -y toilet cowsay cmatrix oneko cmus moc hollywood cbonsai  #lolcat y fortunes-es podrían no estar directamente en los repos oficiales
}

function f_pfetch() {
    #echo "Intentando instalar pfetch..."
    
    if command -v pfetch > /dev/null; then
       # echo "pfetch ya esta instalado en el sistema. Ejecutando..."
        pfetch
       # echo "Fin de la funcion f_pfetch."
        return 0 # Indica éxito y termina la función
    fi

    if [ -d "pfetch" ]; then
        echo "Limpiando carpeta 'pfetch' anterior..."
        rm -rf pfetch
    fi

    # Esta variable nos ayudara a saber si la instalacion fue exitosa
    local INSTALL_SUCCESS=0
    
    git clone https://github.com/dylanaraps/pfetch.git && \
    (
        cd pfetch && \
        sudo make install && \
	hash -r 2>/dev/null && \  # <--- FUERZA LA RECARGA DE COMANDOS
        INSTALL_SUCCESS=1  # Marca el éxito dentro de la subshell
    )
    
    # -------------------------------------------------------------
    # Ejecucion o Manejo de error
    # -------------------------------------------------------------
    
    if [ "$INSTALL_SUCCESS" -eq 1 ]; then
        #echo "pfetch instalado. Ejecutando pfetch..."
        pfetch 
        
    elif command -v neofetch > /dev/null; then
        #echo "Fallo la instalacion de pfetch. Ejecutando neofetch..."
        neofetch
        
    elif command -v fastfetch > /dev/null; then
        #echo "Fallo la instalacion de pfetch. Ejecutando fastfetch..."
        fastfetch
        
    else
        echo "Ni pfetch se pudo instalar, ni neofetch o fastfetch fueron encontrados."
        echo "Por favor, instala un paquete fetch o revisa los permisos de instalacion."
    fi

    if [ -d "pfetch" ]; then
        echo "Limpiando archivos temporales restantes..."
        rm -rf pfetch
    fi

}

# --- Wine ---

# Las funciones _test no se necesitan en esta estructura, el gestor de paquetes ya maneja la existencia.
# Solo dejaremos la funcion de instalacion.

function f_wine_debian() {
    echo "Instalando Wine para Debian/Derivadas..."
    # Pasos especificos para Debian:
    sudo dpkg --add-architecture i386
    sudo apt update
    wget -nc https://dl.winehq.org/wine-builds/winehq.key
    sudo apt-key add winehq.key
    sudo aptitude install wine -y
    echo "Ya puedes usar wine. Solo ejecutalo en tu consola: wine app.exe"
}

function f_wine_fedora() {
    echo "Instalando Wine para Fedora/Derivadas..."
    # Pasos especificos para Fedora:
    sudo dnf install -y wine
    # Para la version de WineHQ (mas reciente), los pasos son mas complejos, puedes anadir un enlace o una nota
    echo "Ya puedes usar wine. Solo ejecutalo en tu consola: wine app.exe"
}

function f_wine_opensuse() {
    echo "Instalando Wine para OpenSUSE/Derivadas..."
    # Pasos especificos para OpenSUSE:
    sudo zypper addrepo https://download.opensuse.org/repositories/Emulators:/Wine/openSUSE_Leap_$(grep VERSION_ID /etc/os-release | cut -d'=' -f2 | tr -d '"')/ WineHQ
    sudo zypper refresh
    sudo zypper install -y wine
    echo "Ya puedes usar wine. Solo ejecutalo en tu consola: wine app.exe"
}

# --- Docker ---

function f_docker_debian() {
    echo "Instalando Docker para Debian/Derivadas..."
    sudo aptitude install -y apt-transport-https ca-certificates curl software-properties-common
    sudo mkdir -m 0755 -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo aptitude install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo aptitude install -y docker-compose
    sudo usermod -aG docker "$USER"
    echo "Instalación completada. Cierra sesión/reinicia para aplicar cambios de grupo."
}

function f_docker_fedora() {
    echo "Instalando Docker para Fedora/Derivadas..."
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker "$USER"
    echo "Instalación completada. Cierra sesión/reinicia para aplicar cambios de grupo."
}

function f_docker_opensuse() {
    echo "Instalando Docker para OpenSUSE/Derivadas..."
    sudo zypper install -y docker docker-compose
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker "$USER"
    echo "Instalación completada. Cierra sesión/reinicia para aplicar cambios de grupo."
}

# --- Flatpak ---

function f_flatpak_debian() {
    echo "Instalando Flatpak para Debian/Derivadas..."
    sudo apt install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "Flatpak y Flathub configurados."
}

function f_flatpak_fedora() {
    echo "Flatpak ya viene preinstalado o es fácil de instalar en Fedora."
    echo "Añadiendo Flathub como repositorio oficial de Flatpak (si no existe)..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "Flatpak y Flathub configurados."
}

function f_flatpak_opensuse() {
    echo "Instalando Flatpak para OpenSUSE/Derivadas..."
    sudo zypper install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "Flatpak y Flathub configurados."
}

# --- Impresora HP ---

function f_impresora_hp_debian() {
    echo "Instalando controladores de impresora HP para Debian/Derivadas..."
    sudo apt update -y
    sudo apt install -y hplip hplip-gui printer-driver-hpcups printer-driver-postscript-hp simple-scan
    lpstat -p # Muestra el estado de las impresoras
    echo "Controladores HP y Simple Scan instalados."
}

function f_impresora_hp_fedora() {
    echo "Instalando controladores de impresora HP para Fedora/Derivadas..."
    sudo dnf install -y hplip hplip-gui system-config-printer-gui simple-scan
    lpstat -p
    echo "Controladores HP y Simple Scan instalados."
}

function f_impresora_hp_opensuse() {
    echo "Instalando controladores de impresora HP para OpenSUSE/Derivadas..."
    sudo zypper install -y hplip hplip-gui simple-scan
    lpstat -p
    echo "Controladores HP y Simple Scan instalados."
}

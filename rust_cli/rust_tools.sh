#!/bin/bash

instalar_rust_cli() {
    clear
    divisor
    echo -e "\t\t--- INSTALANDO HERRAMIENTAS CLI DE RUST ---"
    divisor
    echo -e "${colorAmarillo}Este proceso instalará Rust (si no lo tienes) y las siguientes herramientas CLI modernas:${finColor}"
    echo -e "  - bat (Reemplazo de cat)"
    echo -e "  - eza (Reemplazo de ls)"
    echo -e "  - fd-find (Reemplazo de find)"
    echo -e "  - ripgrep (Reemplazo veloz de grep)"
    echo -e "  - zoxide (Reemplazo inteligente de cd)\n"
    
    echo -e "¿Deseas continuar? (S/n)"
    read -r resp
    if [[ "$resp" == "n" || "$resp" == "N" ]]; then
        return
    fi

    # 1. Instalar Rust y Cargo si no existen
    if ! command -v cargo &> /dev/null; then
        echo -e "\n${colorVerde}[+] Instalando Rustup y Cargo...${finColor}"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        # Cargar variables de entorno
        source "$HOME/.cargo/env"
    else
        echo -e "\n${colorVerde}[+] Rust y Cargo ya están instalados en tu sistema.${finColor}"
    fi

    # Asegurarnos de que cargo está en el PATH para la instalación de este script
    if ! command -v cargo &> /dev/null; then
        export PATH="$HOME/.cargo/bin:$PATH"
    fi

    # 2. Instalar las herramientas
    # Usamos cargo install porque es universal y siempre trae las versiones más recientes.
    echo -e "\n${colorVerde}[+] Instalando 'bat'...${finColor}"
    cargo install bat
    
    echo -e "\n${colorVerde}[+] Instalando 'eza'...${finColor}"
    cargo install eza
    
    echo -e "\n${colorVerde}[+] Instalando 'fd-find'...${finColor}"
    cargo install fd-find
    
    echo -e "\n${colorVerde}[+] Instalando 'ripgrep'...${finColor}"
    cargo install ripgrep
    
    echo -e "\n${colorVerde}[+] Instalando 'zoxide'...${finColor}"
    cargo install zoxide

    echo -e "\n${colorVerde}[!] ¡Instalación de herramientas Rust completada!${finColor}"
    echo -e "${colorAmarillo}Nota: Es posible que necesites reiniciar tu terminal o añadir '~/.cargo/bin' a tu PATH si aún no lo está.${finColor}"
    sleep 4
}

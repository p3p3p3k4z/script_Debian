#!/usr/bin/env bash
# web_stack_deployer.sh
# Instala y configura un stack LEMP o LAMP básico para desarrollo local.

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh
source ./pack/gestor_pack.sh

if [[ "$EUID" -ne 0 ]]; then
    echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para instalar servidores...${finColor}"
    exec sudo "$0" "$@"
fi

clear
divisor azul
imprimir_color "azul" "\t       Desplegador de Servidores Web (LAMP/LEMP)     "
divisor azul

echo -e "\t${colorTurquesa}1. Stack LEMP (Nginx, MariaDB, PHP)${finColor}"
echo -e "\t${colorTurquesa}2. Stack LAMP (Apache, MariaDB, PHP)${finColor}"
echo -e "\t${colorTurquesa}0. Volver${finColor}"
divisor azul
read -rp "        Opción: " opt

if [[ "$opt" == "0" ]]; then exit 0; fi

    if [[ "$opt" == "1" ]]; then
        imprimir_color "turquesa" "\t[*] Instalando Nginx, MariaDB y PHP-FPM..."
        instalar_paquetes "nginx"
        instalar_paquetes "mariadb-server"
        instalar_paquetes "php-fpm"
        instalar_paquetes "php-mysql"
        systemctl enable nginx mariadb php8.1-fpm || true
        systemctl start nginx mariadb php8.1-fpm || true
        imprimir_color "verde" "\n\t[V] LEMP Stack instalado. Raíz web en: /var/www/html"
        
    elif [[ "$opt" == "2" ]]; then
        imprimir_color "turquesa" "\t[*] Instalando Apache2, MariaDB y PHP..."
        instalar_paquetes "apache2" "httpd" "apache2"
        instalar_paquetes "mariadb-server"
        instalar_paquetes "php"
        instalar_paquetes "libapache2-mod-php" "php" "apache2-mod_php8"
        instalar_paquetes "php-mysql" "php-mysqlnd" "php-mysql"
        systemctl enable apache2 httpd mariadb || true
        systemctl start apache2 httpd mariadb || true
        imprimir_color "verde" "\n\t[V] LAMP Stack instalado. Raíz web en: /var/www/html"
    fi

echo -e "\t    Accede a http://localhost en tu navegador."
echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

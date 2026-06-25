#!/usr/bin/env bash
# security_audit.sh
# Escáner local de malas configuraciones

set -euo pipefail

source ./decorador/color.sh
source ./decorador/pintor.sh
source ./decorador/separador.sh

if [[ "$EUID" -ne 0 ]]; then
    echo -e "${colorAmarillo}[!] Elevando a privilegios de superusuario para auditar el sistema...${finColor}"
    exec sudo "$0" "$@"
fi

clear
divisor azul
imprimir_color "azul" "\t      Auditor de Seguridad Básica (Hardening)    "
divisor azul

imprimir_color "turquesa" "\t[*] Analizando configuraciones del sistema..."
score=100

# 1. Verificar Firewall
if command -v ufw &> /dev/null; then
    if ufw status | grep -q "active"; then
        imprimir_color "verde" "\t[V] Firewall (UFW) está activado."
    else
        imprimir_color "rojo" "\t[X] Firewall (UFW) está DESACTIVADO (-20 pts)."
        score=$((score - 20))
    fi
elif command -v firewall-cmd &> /dev/null; then
    if firewall-cmd --state &> /dev/null; then
        imprimir_color "verde" "\t[V] Firewall (Firewalld) está activado."
    else
        imprimir_color "rojo" "\t[X] Firewall (Firewalld) está DESACTIVADO (-20 pts)."
        score=$((score - 20))
    fi
else
    imprimir_color "amarillo" "\t[!] No se detectó UFW ni Firewalld (-10 pts)."
    score=$((score - 10))
fi

# 2. Verificar Passwords Vacios
empty_pass=$(awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow | wc -l)
if [[ $empty_pass -eq 0 ]]; then
    imprimir_color "verde" "\t[V] No hay cuentas críticas con contraseñas vacías."
else
    imprimir_color "amarillo" "\t[!] Se encontraron $empty_pass cuentas bloqueadas o vacías (Revisa /etc/shadow)."
fi

# 3. SSH Root Login
if [[ -f /etc/ssh/sshd_config ]]; then
    if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
        imprimir_color "rojo" "\t[X] El acceso Root por SSH está PERMITIDO (-20 pts)."
        score=$((score - 20))
    else
        imprimir_color "verde" "\t[V] El acceso Root por SSH está restringido (Seguro)."
    fi
else
    imprimir_color "verde" "\t[V] SSH Server no está instalado (Seguro contra ataques remotos)."
fi

# 4. Actualizaciones
if command -v apt-get &> /dev/null; then
    upg=$(apt-get -s upgrade | grep -c "^Inst" || true)
    if [[ $upg -gt 50 ]]; then
        imprimir_color "amarillo" "\t[!] Tienes $upg paquetes sin actualizar (-10 pts)."
        score=$((score - 10))
    else
        imprimir_color "verde" "\t[V] Sistema razonablemente actualizado."
    fi
fi

# 5. Permisos de /etc/shadow
perms=$(stat -c "%a" /etc/shadow)
if [[ "$perms" == "000" || "$perms" == "600" || "$perms" == "640" ]]; then
    imprimir_color "verde" "\t[V] Permisos de /etc/shadow son seguros ($perms)."
else
    imprimir_color "rojo" "\t[X] Los permisos de /etc/shadow son demasiado permisivos ($perms) (-20 pts)."
    score=$((score - 20))
fi

divisor azul
imprimir_color "turquesa" "\t      PUNTUACIÓN DE SEGURIDAD: $score / 100"
divisor azul

if [[ $score -ge 90 ]]; then imprimir_color "verde" "\tTu sistema tiene un excelente nivel de bastionado."; fi
if [[ $score -ge 70 && $score -lt 90 ]]; then imprimir_color "amarillo" "\tTu sistema es seguro, pero tiene áreas de mejora."; fi
if [[ $score -lt 70 ]]; then imprimir_color "rojo" "\t[!] PELIGRO: Tu sistema tiene vulnerabilidades de configuración críticas."; fi

echo -e "\n${colorGris}Presiona Enter para continuar...${finColor}"
read -r

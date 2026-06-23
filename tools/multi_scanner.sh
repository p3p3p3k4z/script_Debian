#!/usr/bin/env bash
# multi_scanner.sh
# Escanea la subred base de forma paralela y ultra-rapida.
# Permite conectarse por varios metodos al host elegido.
#
# Uso:
#  ./multi_scanner.sh            # usa 10.10.11.1-254, ssh, y usuario actual
#  ./multi_scanner.sh -u user -s 50 -e 80 -m sftp
#  ./multi_scanner.sh -b 10.0.0 -s 1 -e 20 -p 3389 -m rdp

set -euo pipefail

# --- Defaults ---
BASE="10.10.11"     # prefijo por defecto (sin el último octeto)
START=1
END=254
PORT=22
USER="$(whoami)"
TIMEOUT_SECS=1      # tiempo corto ya que se hace en paralelo
SSH_OPTS="-o ConnectTimeout=5 -o StrictHostKeyChecking=ask"
METHOD="ssh"        # método por defecto: ssh

print_help() {
  cat <<EOF
Uso: $0 [opciones]

Opciones:
  -b BASE     Prefijo de red (por ejemplo 10.10.11). Default: ${BASE}
  -s START    Último octeto inicial. Default: ${START}
  -e END      Último octeto final. Default: ${END}
  -p PORT     Puerto (SSH/RDP/servicio). Default: ${PORT}
  -u USER     Usuario. Default: ${USER}
  -t TIMEOUT  Timeout TCP en segundos para el escaneo. Default: ${TIMEOUT_SECS}
  -m METHOD   Método de conexión. Default: ${METHOD}
               Métodos soportados: ssh, sftp, scp, rsync, smb, webdav, rdp
  -h          Muestra esta ayuda
EOF
}

# Parse args
while getopts "b:s:e:p:u:t:m:h" opt; do
  case "${opt}" in
    b) BASE="${OPTARG}" ;;
    s) START="${OPTARG}" ;;
    e) END="${OPTARG}" ;;
    p) PORT="${OPTARG}" ;;
    u) USER="${OPTARG}" ;;
    t) TIMEOUT_SECS="${OPTARG}" ;;
    m) METHOD="${OPTARG}" ;;
    h) print_help; exit 0 ;;
    *) print_help; exit 1 ;;
  esac
done

# Validate numeric range
if ! [[ "${START}" =~ ^[0-9]+$ ]] || ! [[ "${END}" =~ ^[0-9]+$ ]]; then
  echo "Error: START y END deben ser números (0-255)." >&2
  exit 2
fi
if (( START < 0 || START > 255 || END < 0 || END > 255 || START > END )); then
  echo "Error: rango inválido." >&2
  exit 2
fi

METHOD=$(echo "${METHOD}" | tr '[:upper:]' '[:lower:]')

case "${METHOD}" in
  ssh|sftp|scp|rsync|smb|webdav|rdp) ;;
  *)
    echo "Método desconocido: ${METHOD}" >&2
    echo "Métodos soportados: ssh, sftp, scp, rsync, smb, webdav, rdp" >&2
    exit 6
    ;;
esac

echo "Escaneando ${BASE}.${START}-${END} puerto ${PORT} (timeout TCP ${TIMEOUT_SECS}s) como usuario '${USER}', método '${METHOD}'..."

# Function to test puerto TCP.
test_port() {
  local ip=$1
  if command -v timeout >/dev/null 2>&1; then
    timeout "${TIMEOUT_SECS}" bash -c ">/dev/tcp/${ip}/${PORT}" 2>/dev/null && return 0 || return 1
  else
    bash -c "cat < /dev/tcp/${ip}/${PORT}" >/dev/null 2>&1 && return 0 || return 1
  fi
}

# --- Escaneo en Paralelo ---
TMP_FILE=$(mktemp /tmp/multi_scanner_XXXXXX.tmp)
reachable=()

for i in $(seq "${START}" "${END}"); do
  ip="${BASE}.${i}"
  (
    if test_port "${ip}"; then
      echo "${ip}" >> "${TMP_FILE}"
    fi
  ) &
done

# Esperar a que terminen todos los procesos en segundo plano
wait

# Leer resultados, ordenarlos numericamente y borrar el temporal
if [[ -f "$TMP_FILE" ]]; then
  if [[ -s "$TMP_FILE" ]]; then
    mapfile -t reachable < <(sort -V "$TMP_FILE")
  fi
  rm -f "$TMP_FILE"
fi

for ip in "${reachable[@]:-}"; do
  echo "  -> ${ip} (puerto ${PORT} abierto)"
done

count=${#reachable[@]}
if (( count == 0 )); then
  echo "No se encontraron hosts con el puerto ${PORT} abierto en el rango indicado."
  exit 3
fi

echo
echo "Hosts alcanzables (${count}):"
for idx in "${!reachable[@]}"; do
  echo "  [$idx] ${reachable[$idx]}"
done

if (( count == 1 )); then
  selection=0
else
  read -rp "Elige índice para conectar (0-$((count-1))) o escribe IP completa: " selection_raw
  if [[ "${selection_raw}" =~ ^[0-9]+$ ]]; then
    if (( selection_raw < 0 || selection_raw >= count )); then
      echo "Índice fuera de rango." >&2
      exit 4
    fi
    selection="${selection_raw}"
  else
    selection_ip="${selection_raw}"
    if [[ "${selection_ip}" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      ok=0
      for ip in "${reachable[@]}"; do
        [[ "${ip}" == "${selection_ip}" ]] && ok=1 && break
      done
      if (( ok == 0 )); then
        echo "La IP ${selection_ip} no está en la lista." >&2
        exit 5
      fi
      ip_to_connect="${selection_ip}"
    else
      echo "Entrada inválida." >&2
      exit 6
    fi
  fi
fi

if [[ -z "${ip_to_connect:-}" ]]; then
  ip_to_connect="${reachable[$selection]}"
fi

echo "Intentando conexión a ${ip_to_connect} usando método '${METHOD}'..."

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: se requiere '$1' pero no está instalado." >&2
    return 1
  fi
  return 0
}

case "${METHOD}" in
  ssh) exec ssh ${SSH_OPTS} -p "${PORT}" "${USER}@${ip_to_connect}" ;;
  sftp)
    require_cmd sftp || exit 7
    exec sftp -o ConnectTimeout=5 -o StrictHostKeyChecking=ask -P "${PORT}" "${USER}@${ip_to_connect}"
    ;;
  scp)
    require_cmd scp || exit 7
    read -rp "Ruta remota (user@host:/ruta ó /ruta en ${ip_to_connect}): " rpath
    read -rp "Destino local (default: current dir): " ldest
    ldest="${ldest:-.}"
    if [[ "${rpath}" != *:* ]]; then
      remote="${USER}@${ip_to_connect}:${rpath}"
    else
      remote="${rpath}"
    fi
    exec scp -P "${PORT}" "${remote}" "${ldest}"
    ;;
  rsync)
    require_cmd rsync || exit 7
    echo "  Ejemplo: rsync -avz -e 'ssh -p ${PORT}' ${USER}@${ip_to_connect}:/ruta/ ./destino/"
    read -rp "¿Ejecutar rsync ahora? (s/N): " do_rsync
    if [[ "${do_rsync,,}" =~ ^s|y ]]; then
      read -rp "Ruta remota: " rpath
      read -rp "Destino local: " ldest
      ldest="${ldest:-./}"
      exec rsync -avz -e "ssh -p ${PORT}" "${USER}@${ip_to_connect}:${rpath}" "${ldest}"
    else
      exit 0
    fi
    ;;
  smb)
    url="smb://${ip_to_connect}/"
    if command -v gio >/dev/null 2>&1; then exec gio open "${url}"
    elif command -v xdg-open >/dev/null 2>&1; then exec xdg-open "${url}"
    elif command -v smbclient >/dev/null 2>&1; then exec smbclient -L "${ip_to_connect}" -U "${USER}"
    else exit 7; fi
    ;;
  webdav)
    url="dav://${ip_to_connect}/"
    if command -v gio >/dev/null 2>&1; then exec gio open "${url}"
    elif command -v xdg-open >/dev/null 2>&1; then exec xdg-open "${url}"
    elif command -v cadaver >/dev/null 2>&1; then exec cadaver "${url}"
    else exit 7; fi
    ;;
  rdp)
    if command -v xfreerdp >/dev/null 2>&1; then exec xfreerdp /v:${ip_to_connect}:${PORT}
    elif command -v rdesktop >/dev/null 2>&1; then exec rdesktop -u "${USER}" -p "" "${ip_to_connect}:${PORT}"
    else exit 7; fi
    ;;
  *) exit 8 ;;
esac

#!/usr/bin/env bash
# ssh_scanner.sh
# Escaneo paralelo y rapido de una red local enfocado 100% a SSH.

set -euo pipefail

# --- Defaults ---
BASE="10.10.11"
START=1
END=254
PORT=22
USER="$(whoami)"
TIMEOUT_SECS=1
SSH_OPTS="-o ConnectTimeout=5 -o StrictHostKeyChecking=ask"

print_help() {
  cat <<EOF
Uso: $0 [opciones]

Opciones:
  -b BASE     Prefijo de red (por ejemplo 10.10.11). Default: ${BASE}
  -s START    Último octeto inicial. Default: ${START}
  -e END      Último octeto final. Default: ${END}
  -p PORT     Puerto SSH. Default: ${PORT}
  -u USER     Usuario SSH. Default: ${USER}
  -t TIMEOUT  Timeout TCP en segundos para el escaneo. Default: ${TIMEOUT_SECS}
  -h          Muestra esta ayuda
EOF
}

while getopts "b:s:e:p:u:t:h" opt; do
  case "${opt}" in
    b) BASE="${OPTARG}" ;;
    s) START="${OPTARG}" ;;
    e) END="${OPTARG}" ;;
    p) PORT="${OPTARG}" ;;
    u) USER="${OPTARG}" ;;
    t) TIMEOUT_SECS="${OPTARG}" ;;
    h) print_help; exit 0 ;;
    *) print_help; exit 1 ;;
  esac
done

if ! [[ "${START}" =~ ^[0-9]+$ ]] || ! [[ "${END}" =~ ^[0-9]+$ ]]; then
  echo "Error: START y END deben ser números (0-255)." >&2; exit 2
fi

echo "Escaneando de forma paralela ${BASE}.${START}-${END} puerto ${PORT} como usuario '${USER}'..."

test_port() {
  local ip=$1
  if command -v timeout >/dev/null 2>&1; then
    timeout "${TIMEOUT_SECS}" bash -c ">/dev/tcp/${ip}/${PORT}" 2>/dev/null && return 0 || return 1
  else
    bash -c "cat < /dev/tcp/${ip}/${PORT}" >/dev/null 2>&1 && return 0 || return 1
  fi
}

TMP_FILE=$(mktemp /tmp/ssh_scanner_XXXXXX.tmp)
reachable=()

# Escaneo masivo en paralelo
for i in $(seq "${START}" "${END}"); do
  ip="${BASE}.${i}"
  (
    if test_port "${ip}"; then
      echo "${ip}" >> "${TMP_FILE}"
    fi
  ) &
done

wait # Sincroniza y espera a los 254 subprocesos

if [[ -f "$TMP_FILE" ]]; then
  if [[ -s "$TMP_FILE" ]]; then
    mapfile -t reachable < <(sort -V "$TMP_FILE")
  fi
  rm -f "$TMP_FILE"
fi

for ip in "${reachable[@]:-}"; do
  echo "  -> ${ip} (ssh abierto)"
done

count=${#reachable[@]}
if (( count == 0 )); then
  echo "No se encontraron hosts con SSH abierto."
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
  read -rp "Elige índice para conectar (0-${count-1}) o escribe IP completa: " selection_raw
  if [[ "${selection_raw}" =~ ^[0-9]+$ ]]; then
    selection="${selection_raw}"
  else
    selection_ip="${selection_raw}"
    ip_to_connect="${selection_ip}"
    echo "Conectando a ${ip_to_connect}..."
    exec ssh ${SSH_OPTS} -p "${PORT}" "${USER}@${ip_to_connect}"
  fi
fi

ip_to_connect="${reachable[$selection]}"
echo "Conectando a ${ip_to_connect} con ssh ${USER}@${ip_to_connect} -p ${PORT} ..."
exec ssh ${SSH_OPTS} -p "${PORT}" "${USER}@${ip_to_connect}"

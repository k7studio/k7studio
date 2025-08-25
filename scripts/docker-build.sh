#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."

if [[ ! -d "$ROOT_DIR" ]]; then
  echo "[ERRO] Diretório raiz não encontrado: $ROOT_DIR"
  exit 1
fi

LOG_DIR="${ROOT_DIR}/logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/docker-build_${TIMESTAMP}.log"

# Redirecionar stdout e stderr para arquivo de log e console simultaneamente
exec > >(tee -a "$LOG_FILE") 2>&1

GREEN='\033[0;32m'; NC='\033[0m'

log() {
  echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

log "= INICIANDO BUILD DO CONTAINER DOCKER ="

BUILD_START=$(date +%s)

docker build -t k7studio-build -f "${ROOT_DIR}/config/Dockerfile" "${ROOT_DIR}"

BUILD_END=$(date +%s)
BUILD_DURATION=$((BUILD_END - BUILD_START))

log "= BUILD DOCKER CONCLUÍDO EM ${BUILD_DURATION} SEGUNDOS ="

log "Para executar o container com seu usuário do host:"
log "  docker run -it --rm -v \"\$(pwd)\":/workspace -e LOCAL_USER_ID=\$(id -u) -e LOCAL_GROUP_ID=\$(id -g) k7studio-build"

log "Para publicar manualmente o conteúdo otimizado da pasta 'build' no GitHub Pages utilize o comando abaixo:"
log "  docker run --rm -v \"\$(pwd)\":/workspace k7studio-build /bin/bash -c \"ghp-import -n -p -f build\""

log "Certifique-se de rodar 'prepare-local-env.sh' para configurar corretamente 'local.env' no seu ambiente local."

log "Log registrado em: $LOG_FILE"


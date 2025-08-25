#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
LOG_DIR="${ROOT_DIR}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/docker-exec_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log(){ echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
error(){ echo -e "${RED}[ERROR] $1${NC}"; exit 1; }

IMAGE_NAME="k7studio-build"
CMD="${1:-}"
shift || true

[[ -z "$CMD" ]] && error "Uso: $0 [args]"

# Build se necessário
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  log "Imagem '$IMAGE_NAME' não encontrada. Construindo..."
  docker build -t "$IMAGE_NAME" -f "${ROOT_DIR}/config/Dockerfile" "${ROOT_DIR}"
fi

log "Executando comando no container: scripts/run.sh $CMD $*"
docker run --rm -v "$(pwd)":/workspace $IMAGE_NAME /workspace/scripts/run.sh "$CMD" "$@"

log "===== docker-exec.sh FINALIZADO ====="
log "Log registrado em: $LOG_FILE"


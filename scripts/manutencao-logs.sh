#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
LOG_DIR="${ROOT_DIR}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/manutencao-logs_$(date +%Y%m%d_%H%M%S).log"

exec > >(tee -a "$LOG_FILE") 2>&1

RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
log(){ echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }

RETENTION_DAYS=30
KEEP_RECENT=5

log "===== INICIANDO MANUTENÇÃO DE LOGS ====="

total=$(find "$LOG_DIR" -type f | wc -l)
log "Antes: $total arquivos encontrados."

find "$LOG_DIR" -type f -mtime +$RETENTION_DAYS | sort | head -n -$KEEP_RECENT | while read -r f; do
    rm -f "$f"
done

total_after=$(find "$LOG_DIR" -type f | wc -l)
log "Depois: $total_after arquivos restantes."

log "===== MANUTENÇÃO DE LOGS CONCLUÍDA ====="
log "Log registrado em: $LOG_FILE"


#!/bin/bash

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'

log(){ echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
error(){ echo -e "${RED}[ERR] $1${NC}"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
LOG_DIR="${ROOT_DIR}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/rollback_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

source "${ROOT_DIR}/config/k7studio-config.env"

LIST=false
TARGET=""
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --list) LIST=true; shift;;
        --backup) TARGET="$2"; shift 2;;
        --force) FORCE=true; shift;;
        -h|--help)
            echo "Uso: $0 [--list] [--backup NAME] [--force]"
            exit 0;;
        *) error "Opção inválida: $1";;
    esac
done

if $LIST; then
    ls -1 "$BACKUP_DIR"/ 2>/dev/null || error "Nenhum backup encontrado"
    log "Log registrado em: $LOG_FILE"
    exit 0
fi

if [[ -z $TARGET ]]; then
    TARGET=$(ls -1t "$BACKUP_DIR" | head -1)
fi

[[ -d "$BACKUP_DIR/$TARGET" ]] || error "Backup não encontrado: $TARGET"

if ! $FORCE; then
    echo "Confirmar rollback para '$TARGET'? (y/N)"
    read -r r
    [[ $r =~ ^[Yy]$ ]] || exit 0
fi

log "Restaurando backup '$TARGET'..."
cp -r "$BACKUP_DIR/$TARGET"/* . || error "Falha ao restaurar"

log "Rollback concluído."
log "Log registrado em: $LOG_FILE"


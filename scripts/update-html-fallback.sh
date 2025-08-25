#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log(){ echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
warn(){ echo -e "${YELLOW}[WARN] $1${NC}"; }
error(){ echo -e "${RED}[ERROR] $1${NC}"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
BUILD_DIR="${ROOT_DIR}/build"
BACKUP_DIR="${BUILD_DIR}/backup"
LOG_DIR="${ROOT_DIR}/logs"
mkdir -p "$LOG_DIR" "$BACKUP_DIR"
LOG_FILE="$LOG_DIR/update-html-fallback_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

log "Iniciando atualização do index.html para fallback WebP"

INDEX_FILE="${BUILD_DIR}/index.html"
BACKUP_FILE="${BACKUP_DIR}/index.html.bak.$(date +%Y%m%d_%H%M%S)"

[[ -f "$INDEX_FILE" ]] || error "Arquivo $INDEX_FILE não encontrado. Execute o build primeiro."

cp "$INDEX_FILE" "$BACKUP_FILE"
log "Backup criado: $BACKUP_FILE"

# Substituir imagens <img src="jpg/png"> por <picture><source webp><img fallback>
sed -Ei 's#<img([^>]+)src="([^"]+)\.(jpg|jpeg|png)"([^>]*)>#<picture><source srcset="\2.webp" type="image/webp"><img\1src="\2.\3"\4></picture>#gi' "$INDEX_FILE"

log "Atualização concluída: fallback WebP aplicado"
log "Log registrado em: $LOG_FILE"


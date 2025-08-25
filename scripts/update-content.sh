#!/bin/bash

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

log(){ echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
warn(){ echo -e "${YELLOW}[WARN] $1${NC}"; }
error(){ echo -e "${RED}[ERR] $1${NC}"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
LOG_DIR="${ROOT_DIR}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/update-content_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

log "===== UPDATE INCREMENTAL (DOCKER) ====="

source "${ROOT_DIR}/config/k7studio-config.env"

[[ -d "$BUILD_DIR" ]] || error "Build inexistente. Rode optimize-projeto.sh primeiro."

FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=true; shift;;
    *) error "Opção inválida: $1";;
  esac
done

# Detectar mudanças
changes=()
md5file="$BUILD_DIR/.source_checksums"

for f in index.html css/style.css js/main.js; do
  [[ -f $f ]] || continue
  sum=$(md5sum "$f")
  prev=$(grep "${f##*/}" "$md5file" 2>/dev/null || true)
  [[ "$sum" != "$prev" || $FORCE = true ]] && changes+=("$f")
done

if [[ ${#changes[@]} -eq 0 ]]; then
  log "Nenhuma mudança detectada."
  log "Log registrado em: $LOG_FILE"
  exit 0
fi

ts=$(date +%Y%m%d_%H%M%S)
bkp="$BACKUP_DIR/inc_$ts"
mkdir -p "$bkp"

cp -r "$BUILD_DIR" "$bkp/build_backup"

log "Backup incremental criado: $bkp"

# Processar mudanças
[[ " ${changes[*]} " == *"style.css"* ]] && sed '/@import/d' css/style.css | uglifycss > "$BUILD_DIR/css/style.min.css"
[[ " ${changes[*]} " == *"main.js"* ]] && uglifyjs js/main.js -c -m -o "$BUILD_DIR/js/main.min.js"
if [[ " ${changes[*]} " == *"index.html"* ]]; then
  cp index.html "$BUILD_DIR/index.tmp.html"
  sed -i 's|css/style.css|css/style.min.css|g; s|js/main.js|js/main.min.js|g' "$BUILD_DIR/index.tmp.html"
  html-minifier --collapse-whitespace --remove-comments --minify-css true --minify-js true \
    "$BUILD_DIR/index.tmp.html" -o "$BUILD_DIR/index.html"
  rm "$BUILD_DIR/index.tmp.html"
fi

# Atualizar checksums
{
  [[ -f index.html ]] && md5sum index.html
  [[ -f css/style.css ]] && md5sum css/style.css
  [[ -f js/main.js ]] && md5sum js/main.js
} > "$md5file"

log "===== UPDATE CONCLUÍDO ====="
log "Log registrado em: $LOG_FILE"


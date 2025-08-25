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
LOG_FILE="$LOG_DIR/optimize-projeto_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

source "${ROOT_DIR}/config/k7studio-config.env"

log "= INICIANDO OTIMIZAÇÃO COMPLETA (DOCKER) ="

# 1. Backup full
ts=$(date +%Y%m%d_%H%M%S)
bk="${BACKUP_DIR}/${ts}"
mkdir -p "$bk"
cp -r "${ROOT_DIR}/index.html" "${ROOT_DIR}/css" "${ROOT_DIR}/js" \
      "${ROOT_DIR}/img" "${ROOT_DIR}/logo" "${ROOT_DIR}/CNAME" "$bk/" 2>/dev/null || warn "Alguns arquivos não estavam presentes para backup."
log "Backup criado em $bk"

# 2. Reset build
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# 3. Imagens originais
mkdir -p "${BUILD_DIR}/img" "${BUILD_DIR}/logo"
cp -r "${ROOT_DIR}/img/"* "${BUILD_DIR}/img/" 2>/dev/null || warn "Pasta img vazia."
cp -r "${ROOT_DIR}/logo/"* "${BUILD_DIR}/logo/" 2>/dev/null || warn "Pasta logo vazia."

# 4. WebP
log "Convertendo imagens para WebP..."
shopt -s nullglob
for dir in img logo; do
  for file in "${ROOT_DIR}/${dir}/"*.{jpg,jpeg,png}; do
    outdir="${BUILD_DIR}/${dir}"
    name=$(basename "$file")
    base="${name%.*}"
    q=$WEBP_QUALITY; [[ $dir == logo ]] && q=95
    cwebp -q "$q" "$file" -o "${outdir}/${base}.webp"
    log "Imagem otimizada: ${dir}/${name} -> ${dir}/${base}.webp"
  done
done

# 5. Critical CSS
log "Gerando Critical CSS..."
set +e
critical --base "${ROOT_DIR}" --html index.html --width 375 --height 667 --target "${BUILD_DIR}/critical.min.css"
CRITICAL_STATUS=$?
set -e
if [[ $CRITICAL_STATUS -ne 0 ]]; then
  warn "Critical CSS falhou (erro: $CRITICAL_STATUS). Criando arquivo vazio para continuidade."
  echo "/* critical css não gerado */" > "${BUILD_DIR}/critical.min.css"
fi

# 6. CSS Minify
log "Minificando CSS..."
mkdir -p "${BUILD_DIR}/css"
sed '/@import/d' "${ROOT_DIR}/css/style.css" | uglifycss > "${BUILD_DIR}/css/style.min.css"

# 7. JS Minify
log "Minificando JS..."
mkdir -p "${BUILD_DIR}/js"
uglifyjs "${ROOT_DIR}/js/main.js" -c -m -o "${BUILD_DIR}/js/main.min.js"

# 8. HTML Build
log "Gerando HTML otimizado..."
cp "${ROOT_DIR}/index.html" "${BUILD_DIR}/index.tmp.html"
sed -i 's|css/style.css|css/style.min.css|g;s|js/main.js|js/main.min.js|g' "${BUILD_DIR}/index.tmp.html"
if [[ -s "${BUILD_DIR}/critical.min.css" ]]; then
  css=$(<"${BUILD_DIR}/critical.min.css")
  sed -i "/<\/head>/i <style>${css}</style>" "${BUILD_DIR}/index.tmp.html"
fi
html-minifier --collapse-whitespace --remove-comments --minify-css true --minify-js true \
  "${BUILD_DIR}/index.tmp.html" -o "${BUILD_DIR}/index.html"
rm "${BUILD_DIR}/index.tmp.html"

# 9. Deploy extras
cp "${ROOT_DIR}/CNAME" "${BUILD_DIR}/" 2>/dev/null || warn "Arquivo CNAME não encontrado."
touch "${BUILD_DIR}/.nojekyll"

# 10. Report
orig=$(du -sk "${ROOT_DIR}" | cut -f1)
opt=$(du -sk "${BUILD_DIR}" | cut -f1)
log "Tamanho original: $orig KB | Otimizado: $opt KB"

log "= OTIMIZAÇÃO CONCLUÍDA ="
log "Log registrado em: $LOG_FILE"


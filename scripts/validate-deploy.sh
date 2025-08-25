#!/bin/bash
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log(){ echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
warn(){ echo -e "${YELLOW}[WARN] $1${NC}"; }
error(){ echo -e "${RED}[ERROR] $1${NC}"; exit 1; }
success(){ echo -e "${CYAN}[OK] $1${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
mkdir -p "${ROOT_DIR}/logs"
LOGFILE="${ROOT_DIR}/logs/validate-deploy_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOGFILE") 2>&1

URL="https://www.k7studio.com.br"
RUN_LH=false
REPORT=true; LOCAL=true

while [[ $# -gt 0 ]]; do
  case $1 in
    --url) URL="$2"; shift 2;;
    --lighthouse) RUN_LH=true; shift;;
    --no-local) LOCAL=false; shift;;
    --no-report) REPORT=false; shift;;
    -h|--help)
      echo "Uso: $0 [--url URL] [--lighthouse] [--no-local] [--no-report]"
      exit 0;;
    *) error "Opção inválida: $1";;
  esac
done

log "= Iniciando validação pós-deploy ="
log "URL alvo: $URL"

if $LOCAL; then
  [[ -f "${ROOT_DIR}/build/index.html" ]] || error "Build inexistente"
  for d in "${ROOT_DIR}/build/css" "${ROOT_DIR}/build/js"; do
    [[ -d $d && $(find "$d" -type f | wc -l) -gt 0 ]] || error "Arquivos ausentes em $d"
  done
  success "Estrutura local OK"
fi

code=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
if [[ $code -ge 200 && $code -lt 400 ]]; then success "HTTP $code OK"
else warn "HTTP $code na resposta"; fi

hdrs=$(mktemp); curl -sI "$URL" > "$hdrs"
grep -qi 'cache-control' "$hdrs" && success "Cache-Control presente" || warn "Cache-Control ausente"
grep -qiE 'content-encoding.*(gzip|br)' "$hdrs" && success "Compressão ativa" || warn "Compressão ausente"
rm "$hdrs"

resp_time=$(curl -s -w '%{time_total}' -o /dev/null "$URL")
resp_time_ms=$(awk "BEGIN{print $resp_time * 1000}")
log "Tempo resposta: ${resp_time_ms} ms"
(( $(echo "$resp_time_ms <= 500" | bc -l) )) && success "Resposta rápida" || warn "Resposta lenta"

if $RUN_LH; then
  if ! command -v lhci &>/dev/null; then
    warn "LHCI não instalado, abortando."
  else
    CHROME_BIN=$(command -v google-chrome || true)
    if [[ -z "$CHROME_BIN" ]]; then warn "Google Chrome não detectado"; else
      export LHCI_CHROME_PATH="$CHROME_BIN"
      export LHCI_CHROME_FLAGS="--headless=new --no-sandbox --disable-dev-shm-usage --no-zygote --disable-gpu"
      log "Executando LHCI com $CHROME_BIN"
      if ! timeout 600 xvfb-run --auto-servernum -- lhci autorun --config=./config/lighthouserc.json; then
        warn "LHCI falhou (ignorado)."
      fi
    fi
  fi
fi

if $REPORT; then
  ts=$(date +%Y%m%d_%H%M%S)
  echo "{\"url\":\"$URL\",\"status\":\"checked\",\"timestamp\":\"$(date +%Y-%m-%dT%H:%M:%S)\"}" \
    > "${ROOT_DIR}/logs/validation_${ts}.json"
  success "Relatório salvo em logs/validation_${ts}.json"
fi

log "= VALIDAÇÃO FINALIZADA ="
log "Log registrado em: $LOGFILE"


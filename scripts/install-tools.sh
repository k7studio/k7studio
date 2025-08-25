#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
LOG_DIR="${ROOT_DIR}/logs"
CONFIG_DIR="${ROOT_DIR}/config"
CONFIG_FILE="${CONFIG_DIR}/k7studio-config.env"

mkdir -p "$LOG_DIR" "$CONFIG_DIR"
LOG_FILE="$LOG_DIR/install-tools_$(date +%Y%m%d_%H%M%S).log"

exec > >(tee -a "$LOG_FILE") 2>&1

log(){ echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
warn(){ echo -e "${YELLOW}[WARN] $1${NC}"; }
error(){ echo -e "${RED}[ERROR] $1${NC}"; exit 1; }

log "= Iniciando validação de ambiente no container ="

# Estrutura
for d in scripts build backup logs .github/workflows; do
  mkdir -p "${ROOT_DIR}/${d}"
done

log "Estrutura básica de diretórios garantida."

# Ferramentas necessárias (sem exigir LHCI obrigatoriamente)
CMDS=(node npm python3 pip3 cwebp html-minifier uglifyjs uglifycss critical imagemin google-chrome)

for cmd in "${CMDS[@]}"; do
  if ! command -v "$cmd" &>/dev/null; then
    warn "Comando ausente no container: $cmd. Tentando reinstalar..."
    case "$cmd" in
      html-minifier|uglifyjs|uglifycss|critical|imagemin)
        npm install -g "$cmd" || error "Falha ao instalar $cmd"
        ;;
      cwebp)
        apt-get update && apt-get install -y webp || error "Falha ao instalar cwebp"
        ;;
      google-chrome)
        warn "Google Chrome deve ser instalado via Dockerfile."
        ;;
      *)
        error "Instalação automática não configurada para $cmd."
        ;;
    esac
  else
    ver=$($cmd --version 2>/dev/null || echo "n/a")
    log "Comando OK: $cmd (versão: $ver)"
  fi
done

PYTHON_VERSION=$(python3 --version 2>&1 || echo "n/a")
log "Versão do Python3 instalada: $PYTHON_VERSION"

if command -v dbus-launch &>/dev/null; then
  log "dbus-launch disponível."
else
  warn "dbus-launch não encontrado. Algumas funcionalidades do Chrome podem falhar."
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  cat > "$CONFIG_FILE" << EOF
BUILD_DIR="build"
SRC_DIR="src"
BACKUP_DIR="backup"
WEBP_QUALITY=85
CSS_MINIFY=true
JS_MINIFY=true
LIGHTHOUSE_BUDGET=true
PERFORMANCE_THRESHOLD=85
EOF
  log "Arquivo de configuração criado em $CONFIG_FILE"
else
  log "Arquivo de configuração já existe em $CONFIG_FILE, mantendo configuração atual."
fi

log "= Validação de ambiente concluída com sucesso! ="
log "Log registrado em: $LOG_FILE"


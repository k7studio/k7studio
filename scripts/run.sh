#!/bin/bash
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

log(){ echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
warn(){ echo -e "${YELLOW}[WARN] $1${NC}"; }
error(){ echo -e "${RED}[ERROR] $1${NC}"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."
LOG_DIR="${ROOT_DIR}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/run_$(date +%Y%m%d_%H%M%S).log"

exec > >(tee -a "$LOG_FILE") 2>&1

log "= INICIANDO EXECUÇÃO run.sh ="
log "Comando recebido: $0 $*"

# Manutenção de logs condicional
if [[ -f "$SCRIPT_DIR/manutencao-logs.sh" ]]; then
    LOG_COUNT=$(find "$LOG_DIR" -type f -name "*.log" | wc -l)
    if (( LOG_COUNT > 50 )); then
        warn "Detectados $LOG_COUNT arquivos de log. Executando manutenção automática..."
        bash "$SCRIPT_DIR/manutencao-logs.sh"
        log "Manutenção de logs concluída antes da execução principal."
    else
        log "A contagem de logs ($LOG_COUNT) está abaixo do limite. Nenhuma manutenção necessária."
    fi
else
    warn "manutencao-logs.sh não encontrado no diretório de scripts."
fi

# Interpretar comando principal
COMMAND="${1:-help}"
shift || true

case "$COMMAND" in
    install)
        log "Executando install-tools.sh..."
        exec "$SCRIPT_DIR/install-tools.sh" "$@"
        ;;
    optimize)
        log "Executando optimize-projeto.sh..."
        exec "$SCRIPT_DIR/optimize-projeto.sh" "$@"
        ;;
    update)
        log "Executando update-content.sh..."
        exec "$SCRIPT_DIR/update-content.sh" "$@"
        ;;
    validate)
        log "Executando validate-deploy.sh..."
        exec "$SCRIPT_DIR/validate-deploy.sh" "$@"
        ;;
    rollback)
        log "Executando rollback.sh..."
        exec "$SCRIPT_DIR/rollback.sh" "$@"
        ;;
    help|*)
        cat << EOF
K7 Studio - Master Script (run.sh)

Uso: ./run.sh [comando] [opções]

Comandos disponíveis:
 install    Instala todas as ferramentas necessárias
 optimize   Executa otimização completa do projeto
 update     Atualiza conteúdo preservando otimizações
 validate   Valida deploy e coleta métricas
 rollback   Reverte para backup anterior
 help       Exibe esta ajuda

Exemplos:
 ./run.sh install
 ./run.sh optimize
 ./run.sh update --force
 ./run.sh validate --url https://k7studio.com.br --lighthouse
 ./run.sh rollback --list
EOF
        ;;
esac

log "= EXECUÇÃO run.sh FINALIZADA ="
log "Log registrado em: $LOG_FILE"


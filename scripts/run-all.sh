#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

log(){ echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }

log "Iniciando processo completo: instalação, otimização, fallback HTML e validação pós-deploy"

log "Passo 1: Instalando ferramentas necessárias"
./scripts/install-tools.sh

log "Passo 2: Otimizando projeto"
./scripts/optimize-projeto.sh

log "Passo 3: Atualizando index.html com fallback WebP"
./scripts/update-html-fallback.sh

log "Passo 4: Validando deploy (LHCI desabilitado por padrão)"
./scripts/validate-deploy.sh

log "Processo completo finalizado com sucesso!"


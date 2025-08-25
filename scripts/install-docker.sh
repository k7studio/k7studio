#!/bin/bash
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

log(){ echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
warn(){ echo -e "${YELLOW}[WARN] $1${NC}"; }
error(){ echo -e "${RED}[ERROR] $1${NC}"; exit 1; }

mkdir -p logs
LOG_FILE="logs/install-docker_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

log "===== INICIANDO INSTALAÇÃO DOCKER ENGINE (UBUNTU 24.04) ====="

log "Removendo versões antigas e Docker Desktop (se existirem)..."
sudo apt-get purge -y docker-desktop docker docker-engine docker.io containerd runc || true
sudo rm -rf $HOME/.docker/desktop $HOME/.config/Docker $HOME/.docker

log "Instalando dependências..."
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

log "Adicionando chave GPG oficial do Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

log "Configurando repositório Docker estável..."
REPO_LINE="deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu noble stable"
REPO_FILE="/etc/apt/sources.list.d/docker.list"

if sudo grep -Fxq "$REPO_LINE" "$REPO_FILE" 2>/dev/null; then
    log "Repositório Docker já configurado, pulando esta etapa."
else
    log "Adicionando repositório Docker ao $REPO_FILE"
    echo "$REPO_LINE" | sudo tee "$REPO_FILE" > /dev/null
fi

log "Instalando Docker Engine e componentes..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

log "Ativando serviço Docker..."
sudo systemctl enable --now docker

log "Adicionando usuário '$USER' ao grupo docker..."
sudo groupadd docker || true
sudo usermod -aG docker "$USER"
warn "Para aplicar a mudança de grupo, use: newgrp docker"

log "Executando teste com hello-world..."
docker run --rm hello-world || warn "Falha ao executar teste hello-world"

log "===== INSTALAÇÃO DOCKER ENGINE CONCLUÍDA ====="
log "Log registrado em: $LOG_FILE"


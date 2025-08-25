#!/bin/bash
set -euo pipefail

# Define UID/GID locais para passar ao container (entrypoint.sh usa essas variáveis)
export LOCAL_USER_ID=$(id -u)
export LOCAL_GROUP_ID=$(id -g)

echo "[INFO] Iniciando ambiente de desenvolvimento (Docker Compose V2)..."
echo "[INFO] UID=$LOCAL_USER_ID GID=$LOCAL_GROUP_ID"

# Substitui 'docker-compose' pelo novo formato do plugin em Ubuntu 24.04
docker compose up

# Se preferir rodar destacado (logs em segundo plano), use:
# docker compose up -d && echo "[INFO] Container em execução em background"


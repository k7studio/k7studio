#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Gerando arquivo local.env com variáveis de ambiente para Docker Compose...${NC}"

LOCAL_USER_ID=$(id -u)
LOCAL_GROUP_ID=$(id -g)

ENV_FILE="local.env"

echo "LOCAL_USER_ID=${LOCAL_USER_ID}" > "$ENV_FILE"
echo "LOCAL_GROUP_ID=${LOCAL_GROUP_ID}" >> "$ENV_FILE"

echo -e "${GREEN}Arquivo '$ENV_FILE' criado com sucesso!${NC}"


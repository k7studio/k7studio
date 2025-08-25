#!/bin/bash

set -euo pipefail

echo "Iniciando servidor HTTP local para pré-visualização do build na porta 8080..."

# Verifica se o diretório build existe
if [ ! -d "./build" ]; then
  echo "Diretório 'build' não encontrado. Execute primeiro o script de otimização."
  exit 1
fi

cd build

# Executa servidor HTTP na porta 8080, escutando em 0.0.0.0
python3 -m http.server 8080

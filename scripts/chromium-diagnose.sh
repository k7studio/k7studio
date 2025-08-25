#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/chrome-diagnose_$(date +%Y%m%d_%H%M%S).log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "== Diagnóstico Google Chrome / Lighthouse =="

echo "Versão Google Chrome:"
google-chrome --version || echo "Google Chrome não instalado!"

echo
echo "Testando sandbox com dump-dom..."
google-chrome --no-sandbox --headless=new --disable-gpu --disable-dev-shm-usage --dump-dom https://www.google.com > /tmp/test-chrome.html || cat /tmp/test-chrome.html
echo ">>> Teste de dump-dom finalizado. Saída em /tmp/test-chrome.html"

echo
echo "Uid/gid:"
id

echo
echo "/proc/self/status"
grep -Ei 'Uid|Gid|Cap|NoNewPrivs' /proc/self/status

echo
echo "AppArmor status dentro do container:"
if command -v aa-status &>/dev/null; then
    aa-status
else
    echo "AppArmor tools não disponíveis"
fi

echo
echo "Verificação finalizada. Log: $LOG_FILE"


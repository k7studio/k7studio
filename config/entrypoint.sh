#!/bin/bash
set -e

# Entrypoint multiusuário
# - Executa como root apenas se FORCE_ROOT=1
# - Caso contrário, troca para usuário 'ubuntu' (uid/gid configuráveis)

if [ "$(id -u)" -eq 0 ]; then
    if [ "${FORCE_ROOT:-}" = "1" ]; then
        exec "$@"
    fi

    LOCAL_USER_ID=${LOCAL_USER_ID:-1000}
    LOCAL_GROUP_ID=${LOCAL_GROUP_ID:-1000}
    LOCAL_USER=ubuntu

    # Criar grupo se não existir
    if ! getent group "$LOCAL_GROUP_ID" >/dev/null 2>&1; then
        groupadd -g "$LOCAL_GROUP_ID" "$LOCAL_USER"
    fi
    LOCAL_GROUP="$(getent group "$LOCAL_GROUP_ID" | cut -d: -f1)"

    # Criar usuário se não existir
    if ! getent passwd "$LOCAL_USER_ID" >/dev/null 2>&1; then
        useradd -m -u "$LOCAL_USER_ID" -g "$LOCAL_GROUP_ID" -s /bin/bash "$LOCAL_USER"
    else
        LOCAL_USER="$(getent passwd "$LOCAL_USER_ID" | cut -d: -f1)"
    fi

    # Garantir posse da pasta de trabalho
    chown -R "$LOCAL_USER:$LOCAL_GROUP" /workspace

    # Ajustar PATH para npm global user
    export PATH="/home/$LOCAL_USER/.npm-global/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

    exec gosu "$LOCAL_USER" "$@"
else
    exec "$@"
fi


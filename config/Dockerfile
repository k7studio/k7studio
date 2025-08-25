FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# Criar diretórios temporários necessários
RUN mkdir -p /tmp /tmp/chrome-profile && \
    chmod 1777 /tmp && \
    chmod 700 /tmp/chrome-profile

# Atualizar pacotes e instalar dependências essenciais
RUN echo "[INFO] Atualizando e instalando dependências essenciais..." && \
    apt-get update && apt-get install -y \
    curl wget gnupg ca-certificates software-properties-common \
    python3 python3-pip python3-venv python3-pil python3-setuptools \
    git git-lfs \
    fonts-liberation libatk-bridge2.0-0 libatk1.0-0 libcups2 \
    libasound2t64 libdbus-1-3 libdrm2 libegl1 libgbm1 libgtk-3-0 \
    libnspr4 libnss3 libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 \
    libxshmfence1 libxss1 libxtst6 x11-utils xdg-utils gosu \
    mesa-vulkan-drivers libgl1-mesa-dri libgl1 xvfb fontconfig \
    webp bc dbus dbus-x11 dconf-cli xauth openssh-client \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
    libu2f-udev libxkbcommon0 \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Instalar Google Chrome estável (substituindo Chromium)
RUN echo "[INFO] Instalando Google Chrome estável..." && \
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-linux-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
      > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Node.js 18.x (NodeSource LTS estável)
RUN echo "[INFO] Instalando Node.js 18.x..." && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Configurar Git LFS
RUN echo "[INFO] Configurando Git LFS..." && git lfs install --skip-smudge || true

# Criar usuário 'ubuntu' (não-root)
RUN echo "[INFO] Criando usuário ubuntu..." && id ubuntu 2>/dev/null || useradd -m -s /bin/bash ubuntu

# Configuração global npm para usuário ubuntu
RUN mkdir -p /home/ubuntu/.npm-global && chown -R ubuntu:ubuntu /home/ubuntu/.npm-global

# Copiar entrypoint e ajustar permissões
COPY config/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Mudar para usuário ubuntu
USER ubuntu

# Ajustar PATH para npm global
ENV PATH=/home/ubuntu/.npm-global/bin:$PATH

# Configurar npm prefix para usuário ubuntu
RUN npm config set prefix '/home/ubuntu/.npm-global'

# Instalar pacotes npm globais
RUN echo "[INFO] Instalando pacotes npm globais..." && \
    npm install -g uglify-js uglifycss html-minifier imagemin-cli imagemin-webp \
    critical@5.0.0

# Criar ambiente virtual Python para instalação isolada do ghp-import
RUN echo "[INFO] Criando ambiente virtual Python e instalando ghp-import..." && \
    python3 -m venv /home/ubuntu/.venv && \
    /home/ubuntu/.venv/bin/pip install --upgrade pip && \
    /home/ubuntu/.venv/bin/pip install ghp-import

# Atualizar PATH para incluir ambiente virtual Python
ENV PATH="/home/ubuntu/.venv/bin:/home/ubuntu/.npm-global/bin:$PATH"

# Comandos para confirmar instalação das ferramentas principais
RUN echo "[INFO] Verificando instalações das ferramentas..." && \
    command -v ghp-import && ghp-import --version && \
    command -v uglifyjs && uglifyjs --version && \
    command -v html-minifier && html-minifier --version

WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]


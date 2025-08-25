# 🎯 K7 Studio – Sistema de Otimização e CI/CD com Docker Ubuntu 24.04

- Este projeto implementa uma cadeia DevOps completa para garantir **performance mobile-first**, **zero-downtime** e **automação CI/CD robusta** do site [`k7studio.com.br`](https://k7studio.com.br), agora em ambiente padronizado via container Docker Ubuntu 24.04.
---

## 📌 Principais Recursos

- Ambiente Docker único baseado em Ubuntu 24.04.  
- Navegador Google Chrome estável instalado e configurado para Lighthouse CI.  
- Scripts shell padronizados para build, otimização, validação, rollback e manutenção.  
- Pipeline CI/CD no GitHub Actions com rollback automático em falhas.  
- Estrutura organizada para facilitar desenvolvimento, manutenção e deploy consistente.
---

## 📦 Setup Inicial

### 1. Pré-requisitos

- Docker instalado ([Guia oficial](https://docs.docker.com/get-docker/))  
- Git instalado  

### 2. Clonar o repositório
```
git config user.name "K7 Studio"
git config user.email "k7.danceandsport@gmail.com"
git remote set-url origin git@github-k7studio:k7studio/k7studio.git
git clone https://github.com/k7studio/k7studio.git
cd k7studio
```

### 3. Construir a imagem Docker
```
./scripts/docker-build.sh
```
### 4. Criar arquivo local de variáveis de ambiente para Docker Compose
```
./scripts/prepare-local-env.sh
```
### 5. Rodar o container para desenvolvimento e execução contínua
```
docker compose up --remove-orphans -d
```
- O serviço ficará ativo aguardando comandos, permitindo execução dos scripts com docker compose exec
---

## 🚀 Uso dos Scripts Shell no Container

### Lista de scripts e suas funções:

| Script                      | Função                                                                     |
|-----------------------------|----------------------------------------------------------------------------|
| `install-tools.sh`          | Valida e instala ferramentas e dependências dentro do container.           |
| `optimize-projeto.sh`       | Otimização completa do projeto (minificação JS/CSS, WebP, Critical CSS).   |
| `update-content.sh`         | Atualização incremental do conteúdo, minificando apenas arquivos alterados.|
| `update-html-fallback.sh`   | Atualiza build/index.html para suporte eficiente a imagens WebP fallback.  |
| `validate-deploy.sh`        | Realiza validação pós-deploy; pode rodar Lighthouse CI (opcional).         |
| `rollback.sh`               | Restaura backup anterior em caso de falha.                                 |
| `run.sh`                    | Script mestre para execução coordenada dos scripts principais.             |
| `run-all.sh`                | Executa fluxo completo: instalação, otimização, atualização, validação.    |
| `manutencao-logs.sh`        | Limpeza automática de arquivos de log antigos.                             |
| `docker-build.sh`           | Script para build da imagem Docker.                                        |
| `docker-run.sh`             | Executa container em modo interativo.                                      |
| `docker-exec.sh`            | Executa comandos dentro do container, com build automático se precisar.    |

### Exemplos de uso:

- Instalar ferramentas necessárias:
```
./scripts/install-tools.sh
```
- Executar otimização completa:
```
./scripts/optimize-projeto.sh
```
- Atualizar fallback de imagens WebP no HTML:
```
./scripts/update-html-fallback.sh
```
- Validar deploy (sem Lighthouse CI por padrão):
```
./scripts/validate-deploy.sh
```
- Validar deploy com Lighthouse CI manualmente:
```
./scripts/validate-deploy.sh --lighthouse
```
- Fluxo completo de build até validação:
```
./scripts/run-all.sh
```
- Rollback de uma versão anterior:
```
./scripts/rollback.sh --list
./scripts/rollback.sh --backup <timestamp> --force
```
- Executar container para desenvolvimento interativo:
```
docker-compose run k7studio /bin/bash
```
---

### Ordem correta das operações Git para uso do repositório K7 Studio

- Antes de enviar suas alterações para o repositório remoto, siga esta sequência correta para evitar problemas de autenticação e garantir que seu histórico local esteja consistente:

### 1. Configurar seu nome e e-mail para commits (uma única vez por máquina):
```
git config user.name "K7 Studio"
git config user.email "k7.danceandsport@gmail.com"
```
### 2. Clonar o repositório (caso ainda não tenha):
```
git clone https://github.com/k7studio/k7studio.git
cd k7studio
```
### 3. Configurar a URL remota para usar SSH (antes do primeiro push para evitar solicitar senha):
```
git remote set-url origin git@github.com:k7studio/k7studio.git
```
### 4. Verificar o status dos arquivos modificados/localizados:
```
git status
```
### 5. Adicionar as alterações para o próximo commit:
```
git add .
```
### 6. Criar o commit local com mensagem clara e descritiva:
```
git commit -m "Descrição clara da mudança realizada"
```
### 7. Enviar as alterações para o ramo principal no repositório remoto:
```
git push origin main
```
---

### 💾 Observação:  
- Certifique-se de configurar corretamente as chaves SSH no seu sistema e adicionar a chave pública em sua conta GitHub para autenticação sem senha.  
- Caso precise de ajuda para configurar SSH ou resolver problemas de autenticação, revise a seção FAQ.


## ⚙️ Pipeline CI/CD no GitHub Actions

- Build da imagem Docker usando Ubuntu 24.04  
- Execução do fluxo completo via `run-all.sh`  
- Upload dos logs para análise  
- Deploy no GitHub Pages com rollback em falhas  
---

## 📁 Estrutura dos Diretórios no Projeto
```
/workspace
├── index.html
├── css/
├── js/
├── img/
├── logo/
├── scripts/
├── config/
├── logs/
├── backup/
├── build/
├── .github/
├── .env.example
├── local.env
├── README.md
```
---

## 💾 Considerações Importantes

- Execute todos os comandos de build e otimização dentro do container para evitar inconsistências.  
- Use `local.env` para variáveis UID/GID no Docker Compose.  
- Backups e logs ficam fora do controle de versão (definidos no `.gitignore`).  
- Limpeza periódica dos logs com `manutencao-logs.sh`.

#### Uso padronizado do arquivo `.env`

- Para simplificar o gerenciamento das variáveis de ambiente e evitar confusão, recomenda-se utilizar sempre o arquivo `.env` na raiz do projeto para definir as variáveis `LOCAL_USER_ID` e `LOCAL_GROUP_ID`. Caso o arquivo `local.env` exista por questões históricas, avalie sua remoção ou deixe claro que é um arquivo auxiliar, explicando diferenças para evitar ambiguidades nas variáveis usadas pelo Docker Compose.

#### Atualização do comando Docker Compose

- A ferramenta Docker CLI atualizou o comando tradicional `docker-compose` para a forma moderna e oficial `docker compose` (com espaço). Recomenda-se que toda a equipe migre para `docker compose` para garantir compatibilidade futura, melhor integração e acesso a novos recursos do Docker.

**Exemplo:**  
- Uso antigo: 
`docker-compose up -d`  
- Uso recomendado: 
`docker compose up -d`
---

## ✅ Checklist Simplificado para Migração e Implantação

### 1. Atualizar .env com UID e GID corretos
```
echo "LOCAL_USER_ID=$(id -u)" > .env
echo "LOCAL_GROUP_ID=$(id -g)" >> .env
```

### 2. Limpar containers órfãos
```
docker compose down --remove-orphans
```
### 3. Build da imagem Docker
```
docker build -t k7studio-build -f config/Dockerfile .
```
### 4. Subir o container
```
docker compose up --remove-orphans -d
```
### 5. Acessar container
```
docker compose exec k7studio /bin/bash
```

### 6. Executar scripts em sequência
```
./scripts/install-tools.sh
./scripts/optimize-projeto.sh
./scripts/update-html-fallback.sh
./scripts/update-content.sh
./scripts/validate-deploy.sh
```

### 7. Prévia local (novo conteúdo)
```
docker compose run --service-ports k7studio ./scripts/preview-build.sh
```

### 8. Commit e push
```
git add .
git commit -m "chore: atualização incremental"
git push origin main
```
## 💾 Considerações Importantes
- Existe o script scripts/preview-build.sh para pré-visualização local, reforçando o uso do parâmetro `--service-ports`.

## ✅ Checklist Simplificado para Atualização Incremental (exemplo: index.html) no Projeto K7 Studio

### 1. Alterar o arquivo localmente no diretório do projeto
- (exemplo: editar index.html, css/, js/, imagens, etc)

### 2. Garantir que as alterações estejam sincronizadas no container
- Se usar volumes docker, atualizações são refletidas imediatamente no container.

### 3. Executar atualização incremental dentro do container:
```
docker compose exec k7studio ./scripts/update-content.sh
```

### 4. (Opcional) Validar a atualização:
```
docker compose exec k7studio ./scripts/validate-deploy.sh
```

### 5. (Opcional) Pré-visualizar build atualizado no host:
```
docker compose run --service-ports k7studio ./scripts/preview-build.sh
```

### 6. Comitar e enviar para o repositório para disparo do pipeline:
```
git add .
git commit -m "chore: atualização incremental de conteúdo"
git push origin main
```

## 💾 Considerações Importantes
- Lembrar que a sincronização via volumes é essencial para que as atualizações locais reflitam no container, evitando dúvidas.

## ✅ Checklist de Atualizações e Sequência para Deploy
- Quando você modificar qualquer conteúdo do projeto (exemplo: atualização no `index.html`), siga o fluxo a seguir para refletir as mudanças no ambiente, validar e fazer o deploy no GitHub Pages.
### 1. Subir o container
```
docker compose up --remove-orphans -d
```

### 2. Sincronizar alterações no container
- Se estiver usando volumes Docker, alterações nos arquivos locais serão refletidas imediatamente no container.

### 3. Executar atualização incremental dentro do container
- No terminal do host:
```
docker compose exec <nome do container> ./scripts/update-content.sh
```
- Exemplo para este projeto:
```
docker compose exec  k7studio ./scripts/update-content.sh
```

### 4. Validar atualização (opcional)
```
docker compose exec k7studio ./scripts/validate-deploy.sh
```
- Lembre-se que a opção `--no-lighthouse` não é suportada.

### 5. Pré-visualizar build atualizado localmente (opcional)
```
docker compose run --service-ports k7studio ./scripts/preview-build.sh
```
### 6. Commitar e enviar para o repositório
```
git add .
git commit -m "chore: atualização incremental de conteúdo"
git push origin main
```
- Este push dispara a pipeline CI/CD e implanta a nova versão no GitHub Pages.
---

### 7. Como parar o container após terminar

- Se a instância principal estiver rodando em background (**com `docker compose up -d`**), use para parar:
```
docker compose down
```
---

### 8. Nota sobre sincronização de arquivos
- Para que as atualizações locais reflitam no container e o processo funcione sem erros, é importante que o projeto utilize volumes Docker para sincronização de arquivos.
---

### Dica importante

- Evite conflitos de porta executando a pré-visualização `preview-build.sh` preferencialmente usando `docker compose exec` se o container principal já estiver ativo.
- Use sempre o comando atualizado `docker compose` (com espaço) para operar o Docker Compose.
---

## 📝 Guia Rápido para Controle de Alterações com Git

- Para manter o histórico organizado e garantir o fluxo correto de deploy, siga as boas práticas abaixo para controle de versões e sincronização com o repositório remoto.

### 1. Configurar usuário Git (uma vez por máquina)

- Configure seu nome e e-mail para os commits:
```
git config user.name "K7 Studio"
git config user.email "k7.danceandsport@gmail.com"
```
---

### 2. Verificar status dos arquivos

- Antes de qualquer operação, veja os arquivos modificados:
```
git status
```
---

### 3. Adicionar arquivos ao staging

- Inclua as alterações para o próximo commit:
```
git add .
```
---

### 4. Criar um commit com mensagem clara

- Registre as alterações no histórico local:
```
git commit -m "Descrição clara da mudança realizada"
```

- *Exemplo:*
```
git commit -m "chore: atualização incremental de conteúdo"
```
---

### 5. Enviar alterações para o repositório remoto
- Faça o push para o ramo principal:
```
git push origin main
```

- Se estiver usando SSH corretamente, não será solicitado usuário e senha.
```
git remote set-url origin git@github.com:k7studio/k7studio.git
```
---

### Dicas importantes

- Sempre execute `git status` para entender o estado atual antes de `add` ou `commit`.
- Evite commits muito grandes; prefira commits lógicos e frequentes para facilitar histórico e rollback.
- Garanta que arquivos importantes estejam versionados e arquivos temporários/com logs estejam ignorados via `.gitignore`.
- Configure acesso SSH para evitar pedir senha a cada push (ver seção FAQ).

---

### Ajuda e solução de problemas comum

- Caso receba erro de identidade, reconfigure user.name e user.email.
- Para problemas de autenticação, preferira o uso de SSH ao invés de HTTPS.
```
git remote set-url origin git@github.com:k7studio/k7studio.git
```
---

## ❓ FAQ - Dúvidas Comuns sobre Docker, Preview Local e Deploy

### 1. Como saber se a configuração SSH para GitHub está funcionando?

- Após configurar sua chave SSH local e alterar a URL remota do Git para usar o protocolo SSH com o comando:
```
git remote set-url origin git@github.com:k7studio/k7studio.git
```
ao executar um push, espere uma saída semelhante a esta:
```
Enumerating objects: 80, done.
Counting objects: 100% (80/80), done.
Delta compression using up to 8 threads
Compressing objects: 100% (71/71), done.
Writing objects: 100% (78/78), 2.87 MiB | 3.24 MiB/s, done.
Total 78 (delta 4), reused 17 (delta 1), pack-reused 0
remote: Resolving deltas: 100% (4/4), completed with 1 local object.
To github.com:k7studio/k7studio.git
180a5c7..51a3f7e main -> main
```

- Isso significa que o push foi enviado com sucesso usando SSH, sem solicitar usuário ou senha, indicando que a chave SSH está corretamente configurada.
- Em caso de erro ou solicitação de usuário/senha, revise sua configuração SSH e adicione sua chave pública ao GitHub em https://github.com/settings/ssh/new.
---

### 2. Por que recebo erro “port is already allocated” ao rodar preview com `docker compose run --service-ports`?

- Esse erro acontece quando a porta 8080 já está ocupada no host, geralmente porque o container principal está rodando e já mapeou essa porta.

- **Soluções:**

- Se o container principal estiver ativo, use:
```
command: ["tail", "-f", "/dev/null"]
```

- Assim, o container não sai após iniciar e pode receber comandos com `docker compose exec`.
---

### 3. Devo usar `docker-compose` ou `docker compose`?

- Use sempre o comando oficial moderno:
```
docker compose <comando>
```

- O `docker-compose` antigo ainda funciona, mas pode ser descontinuado. A migração evita problemas futuros e garante acesso às últimas funcionalidades.
---

### 4. Preciso limpar containers antigos, o que faço?

- Use para limpar containers órfãos ao alterar configurações no `docker-compose.yml`:
```
docker compose down --remove-orphans
```
---

### 5. Como evitar problemas com cache no GitHub Pages após fazer deploy?

- Limpe cache do navegador (hard refresh, modo anônimo).
- Aguarde alguns minutos para o cache CDN propagar as atualizações.
- Certifique-se de que headers HTTP `Cache-Control` estejam configurados corretamente no deploy.
---

### 6. Posso interromper o preview local com Ctrl+C?

- Sim, para o comando:
```
docker compose run --service-ports k7studio ./scripts/preview-build.sh
```
- Use Ctrl+C para parar o servidor HTTP e assim o container temporário será encerrado automaticamente.
---

### 7. O que fazer quando recebo erro “port already allocated” ao rodar preview?

- Isso ocorre porque a porta 8080 já está ocupada pelo container principal ativo (iniciado com `docker compose up -d`).

#### Soluções:

- Para rodar o preview no container existente, sem tentar alocar a porta novamente, usar o comando:
```
docker compose exec k7studio ./scripts/preview-build.sh
```
- Ou então pare o container principal primeiro:
```
docker compose down
```
e só depois execute seu preview com:
```
docker compose run --service-ports k7studio ./scripts/preview-build.sh
```
---

### 8. Como faço para atualizar o projeto sem problemas?

- Execute:
```
docker compose exec k7studio ./scripts/update-content.sh
docker compose exec k7studio ./scripts/validate-deploy.sh
```
- Opcionalmente, pré-visualize.
- Faça commit e push para disparar deploy.
---

### 9. Como paro o container principal após uso?

- Use para encerrar e liberar recursos:
```
docker compose down
```
---

## ✅ Guia Operacional para Atualização, Preview e Deploy do Projeto K7 Studio com Docker

### 1. Verifique que o container principal está rodando
- Após a criação do container principal em modo daemon:
```
docker compose up --remove-orphans -d
```

- O container chamado k7studio (ou k7studio-container) estará ativo.

### 2. Editar arquivos locais no projeto
- Faça as alterações desejadas, por exemplo no index.html.

### 3. Aplicar atualizações incrementais no container
- Execute no host para aplica a atualização mantendo otimizações anteriores:
```
docker compose exec k7studio ./scripts/update-content.sh
```

### 4. Validar as atualizações
- Opcionalmente, realizar validação do deploy:
```
docker compose exec k7studio ./scripts/validate-deploy.sh
```

### 5. Realizar pré-visualização local
- Se o container principal estiver ativo e usando a porta 8080 (como normalmente acontece), para evitar erro de porta ocupada:
- Use o comando exec para rodar o preview dentro do container em execução:
```
docker compose exec k7studio ./scripts/preview-build.sh
```
- Ou, se quiser testar em container separado com mapeamento explicito de porta:
```
docker compose down  # para container principal e libera a porta
docker compose run --service-ports k7studio ./scripts/preview-build.sh
```

### 6. Commitar e enviar as mudanças para disparar deploy no GitHub
- Finalize com:
```
git add .
git commit -m "chore: atualização incremental"
git push origin main
```
- Isso dispara o pipeline.

### 7. Parar container principal após o trabalho
- Quando terminar, em host:
```
docker compose down
```
---

## 📄 Licença

- Projeto exclusivo K7 Studio – Todos os direitos reservados.



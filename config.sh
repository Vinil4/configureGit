#!/usr/bin/env bash
set -euo pipefail

#instala o git
sudo apt-get -y install git

# Script: configura_git_ed25519.sh
# Gera chave ed25519, configura git, adiciona inicialização do ssh-agent no ~/.bashrc e exibe a chave pública.
# Uso: ./configura_git_ed25519.sh

SSH_DIR="$HOME/.ssh"
KEY_NAME="id_ed25519"
KEY_PATH="$SSH_DIR/$KEY_NAME"
PUB_KEY_PATH="${KEY_PATH}.pub"
BASHRC="$HOME/.bashrc"
MARKER_START="# >>> ssh-agent auto-start (adicionado por configura_git_ed25519.sh) >>>"
MARKER_END="# <<< ssh-agent auto-start (adicionado por configura_git_ed25519.sh) <<<"

# Ler nome e email (sem perguntar se já configurado — atualiza globalmente)
read -rp "Digite seu nome para o Git: " GIT_NAME
read -rp "Digite seu e-mail para o Git: " GIT_EMAIL

echo "Configurando git (global)..."
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Cria ~/.ssh se não existir
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Se existir chave com mesmo nome, faz backup seguro
if [ -f "$KEY_PATH" ] || [ -f "$PUB_KEY_PATH" ]; then
  TIMESTAMP=$(date +"%Y%m%d%H%M%S")
  BACKUP_PRIVATE="${KEY_PATH}.backup.${TIMESTAMP}"
  BACKUP_PUBLIC="${PUB_KEY_PATH}.backup.${TIMESTAMP}"
  echo "Chaves existentes encontradas. Fazendo backup para:"
  echo "  $BACKUP_PRIVATE"
  echo "  $BACKUP_PUBLIC"
  mv -v "$KEY_PATH" "$BACKUP_PRIVATE" 2>/dev/null || true
  mv -v "$PUB_KEY_PATH" "$BACKUP_PUBLIC" 2>/dev/null || true
fi

# Gerar chave ED25519 sem passphrase
echo "Gerando chave ED25519 em $KEY_PATH (sem passphrase)..."
ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$KEY_PATH" -N "" -q

# Ajusta permissões
chmod 600 "$KEY_PATH"
chmod 644 "$PUB_KEY_PATH"

# Iniciar ssh-agent na sessão atual (se não houver um rodando) e adicionar a chave
echo "Iniciando ssh-agent na sessão atual (se necessário) e adicionando a chave..."
# tenta descobrir SSH_AUTH_SOCK já existente
if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "${SSH_AUTH_SOCK:-}" ]; then
  echo "ssh-agent já está disponível nesta sessão."
else
  eval "$(ssh-agent -s)" >/dev/null
fi

# Adiciona a chave (silencioso)
ssh-add -q "$KEY_PATH" || {
  echo "Aviso: ssh-add falhou. Talvez seja necessário rodar 'ssh-add $KEY_PATH' manualmente."
}

# Adicionar bloco de inicialização ao ~/.bashrc (sem duplicar)
if ! grep -Fq "$MARKER_START" "$BASHRC"; then
  cat >> "$BASHRC" <<'EOF'

# >>> ssh-agent auto-start (adicionado por configura_git_ed25519.sh) >>>
# Inicia ssh-agent se não existir e carrega a chave id_ed25519 automaticamente.
ssh_agent_auto_start() {
  # caminho da chave (ajuste se necessario)
  local key_path="$HOME/.ssh/id_ed25519"

  # se ssh-agent não estiver rodando, inicia um novo
  if [ -z "${SSH_AUTH_SOCK:-}" ] || [ ! -S "${SSH_AUTH_SOCK:-}" ]; then
    eval "$(ssh-agent -s)" >/dev/null
  fi

  # adiciona a chave ao agente se existir e ainda não estiver adicionada
  if [ -f "$key_path" ]; then
    # lista chaves e verifica se já está lá
    if ! ssh-add -l | grep -q "id_ed25519"; then
      ssh-add -q "$key_path" 2>/dev/null || true
    fi
  fi
}
ssh_agent_auto_start
# <<< ssh-agent auto-start (adicionado por configura_git_ed25519.sh) <<<
EOF

  echo "Bloco de inicialização adicionado em $BASHRC."
else
  echo "Bloco de inicialização já presente em $BASHRC — pulando adição."
fi

# Mostrar a chave pública
echo
echo "Chave pública gerada (copie e cole no seu provedor Git, ex: GitHub/GitLab):"
echo "--------------------------------------------------"
cat "$PUB_KEY_PATH"
echo
echo "--------------------------------------------------"
echo "Finalizado. Se você usar outro shell (zsh, fish), adapte a adição ao arquivo de inicialização desse shell."

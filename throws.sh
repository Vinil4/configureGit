#!/bin/bash

# Este script aplica 4 personalizações:
# 1. Instala dependências e configura o clipboard do sistema no Vim
# 2. Altera o prefixo do Tmux para Ctrl+A e adiciona o modo Vim
# 3. Cria um alias 'ra' para 'ranger'
# 4. Inicia o Tmux automaticamente no login do shell

echo "==> Instalando dependências para o clipboard (vim-gtk3 e xclip)..."
# O vim-gtk3 (ou vim-g/vim-x11) é necessário para ter a opção +clipboard
# O xclip é a ferramenta que o vim usa para aceder ao clipboard
sudo apt update
sudo apt install -y vim-gtk3 xclip
echo ""

echo "==> Configurando o Vim para usar a área de transferência do sistema..."
VIMRC_FILE="$HOME/.vimrc"
CLIPBOARD_LINE="set clipboard=unnamedplus"

# Garante que o .vimrc exista
touch "$VIMRC_FILE"

# Adiciona a linha de configuração do clipboard se ela não existir
if ! grep -qF "$CLIPBOARD_LINE" "$VIMRC_FILE"; then
    echo "" >> "$VIMRC_FILE"
    echo "\" Linka o Vim com o clipboard do sistema (Ctrl+C/Ctrl+V)" >> "$VIMRC_FILE"
    echo "$CLIPBOARD_LINE" >> "$VIMRC_FILE"
    echo "Configuração do clipboard adicionada ao $VIMRC_FILE."
else
    echo "Configuração do clipboard já existe no $VIMRC_FILE (pulado)."
fi
echo ""

# ----------------------------------------------------

# --- INÍCIO DA MODIFICAÇÃO ---
echo "==> Configurando o Tmux (prefixo Ctrl+A e modo Vim)..."
# Garante que o arquivo exista
touch ~/.tmux.conf

# 1. Configuração do Prefixo (Original)
if ! grep -q "unbind C-b" ~/.tmux.conf; then
    echo 'unbind C-b' >> ~/.tmux.conf
fi
if ! grep -q "set -g prefix C-a" ~/.tmux.conf; then
    echo 'set -g prefix C-a' >> ~/.tmux.conf
fi
if ! grep -q "bind C-a send-prefix" ~/.tmux.conf; then
    echo 'bind C-a send-prefix' >> ~/.tmux.conf
fi

# 2. Configurações de "Vim Mode" (Novo)
# Adiciona um comentário de separação se ele não existir
if ! grep -q "# Configurações de \"Vim Mode\"" ~/.tmux.conf; then
    echo "" >> ~/.tmux.conf
    echo "# Configurações de \"Vim Mode\"" >> ~/.tmux.conf
fi

# Ativa o "modo visual" (copy mode) com teclas do Vi
# Use Ctrl+A [ para entrar, 'v' para selecionar, 'y' para copiar
if ! grep -q "set-window-option -g mode-keys vi" ~/.tmux.conf; then
    echo "set-window-option -g mode-keys vi" >> ~/.tmux.conf
fi

# Navegação entre painéis com h, j, k, l (estilo Vim)
# Use Ctrl+A h, Ctrl+A j, Ctrl+A k, Ctrl+A l
if ! grep -q "bind h select-pane -L" ~/.tmux.conf; then
    echo "bind h select-pane -L" >> ~/.tmux.conf
fi
if ! grep -q "bind j select-pane -D" ~/.tmux.conf; then
    echo "bind j select-pane -D" >> ~/.tmux.conf
fi
if ! grep -q "bind k select-pane -U" ~/.tmux.conf; then
    echo "bind k select-pane -U" >> ~/.tmux.conf
fi
if ! grep -q "bind l select-pane -R" ~/.tmux.conf; then
    echo "bind l select-pane -R" >> ~/.tmux.conf
fi

# Redimensionar painéis com Shift + h, j, k, l
# O '-r' permite repetir (ex: segurar Ctrl+A e apertar H várias vezes)
if ! grep -q "bind -r H resize-pane -L 5" ~/.tmux.conf; then
    echo "bind -r H resize-pane -L 5" >> ~/.tmux.conf
fi
if ! grep -q "bind -r J resize-pane -D 5" ~/.tmux.conf; then
    echo "bind -r J resize-pane -D 5" >> ~/.tmux.conf
fi
if ! grep -q "bind -r K resize-pane -U 5" ~/.tmux.conf; then
    echo "bind -r K resize-pane -U 5" >> ~/.tmux.conf
fi
if ! grep -q "bind -r L resize-pane -R 5" ~/.tmux.conf; then
    echo "bind -r L resize-pane -R 5" >> ~/.tmux.conf
fi

echo "Configuração do Tmux (com modo Vim) concluída."
echo ""
# --- FIM DA MODIFICAÇÃO ---

# ----------------------------------------------------

echo "==> Configurando o Shell (alias 'ra' e auto-start do Tmux)..."

# Define o bloco de texto que queremos adicionar.
CONFIG_BLOCK=$(cat << 'EOT'

# ==================================
# Minhas Personalizações (auto-gerado)
# ==================================

# 1. Alias para o Ranger
alias ra="ranger"

# 2. Iniciar o Tmux automaticamente
# (Apenas se não estivermos já no Tmux e se for uma sessão interativa)
if [ -z "$TMUX" ] && [ "$TERM" != "dumb" ] && [ -n "$PS1" ]; then
    # O -A "atacha" a uma sessão "main" ou cria uma se não existir.
    tmux new-session -A -s main
fi
EOT
)

# ----------------------------------------------------

# Aplicar ao .bashrc (para o Bash)
if ! grep -q 'alias ra="ranger"' ~/.bashrc; then
    echo "$CONFIG_BLOCK" >> ~/.bashrc
    echo "Configuração aplicada ao ~/.bashrc"
else
    echo "Configuração já existe no ~/.bashrc (pulado)"
fi

# Aplicar ao .zshrc (para o Zsh)
if ! grep -q 'alias ra="ranger"' ~/.zshrc; then
    echo "$CONFIG_BLOCK" >> ~/.zshrc
    echo "Configuração aplicada ao ~/.zshrc"
else
    echo "Configuração já existe no ~/.zshrc (pulado)"
fi

# ----------------------------------------------------

echo ""
echo "Concluído!"
echo ""
echo "Para aplicar as mudanças, reinicie o seu terminal ou execute:"
echo "  source ~/.bashrc"
echo "  source ~/.zshrc"
echo ""
echo "Os atalhos do Tmux e o clipboard do Vim funcionarão após o Tmux e o Vim serem reiniciados."

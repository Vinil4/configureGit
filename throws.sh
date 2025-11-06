#!/bin/bash

# Este script aplica 4 personalizações:
# 1. Instala dependências e configura o clipboard do sistema no Vim
# 2. Altera o prefixo do Tmux para Ctrl+A
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

echo "==> Configurando o Tmux (prefixo Ctrl+A)..."
# Garante que o arquivo exista
touch ~/.tmux.conf

# Adiciona as linhas apenas se elas ainda não existirem
if ! grep -q "unbind C-b" ~/.tmux.conf; then
    echo 'unbind C-b' >> ~/.tmux.conf
fi
if ! grep -q "set -g prefix C-a" ~/.tmux.conf; then
    echo 'set -g prefix C-a' >> ~/.tmux.conf
fi
if ! grep -q "bind C-a send-prefix" ~/.tmux.conf; then
    echo 'bind C-a send-prefix' >> ~/.tmux.conf
fi
echo "Configuração do Tmux concluída."
echo ""

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
echo "O atalho Ctrl+A do Tmux e o clipboard do Vim funcionarão após o Tmux e o Vim serem reiniciados."

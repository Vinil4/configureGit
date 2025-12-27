#!/bin/bash

set -e

echo "==> Iniciando script de Personalização (Config & Tweak)..."

# ====================================================
# 1. Instalação do URxvt (Que não estava no script anterior)
# ====================================================
if ! command -v urxvt >/dev/null 2>&1; then
    echo "Instalando rxvt-unicode (URxvt)..."
    sudo apt install -y rxvt-unicode xclip
else
    echo "URxvt já instalado."
fi

# ====================================================
# 2. Configuração do Tmux (Prefixo C-a, Vim Mode, Kill)
# ====================================================
echo "==> Gerando ~/.tmux.conf..."

# Fazemos backup se existir
if [ -f ~/.tmux.conf ] && [ ! -L ~/.tmux.conf ]; then
    mv ~/.tmux.conf ~/.tmux.conf.bak
fi

# Cria o arquivo limpo com todas as configs de uma vez
cat > ~/.tmux.conf << 'EOF'
# --- Prefixo (Ctrl+A) ---
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# --- Modo Vim e Navegação ---
set-window-option -g mode-keys vi
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# --- Redimensionar Painéis ---
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# --- Atalhos de Kill ---
bind q kill-pane
bind Q confirm-before -p "Matar todo o servidor tmux? (y/n)" kill-server

# --- Copiar (Estilo Vim + Clipboard Sistema) ---
bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
bind-key -T copy-mode-vi 'y' send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

# Mouse (Opcional, bom ter)
set -g mouse on
EOF

echo "Configuração do Tmux aplicada."

# ====================================================
# 3. Função 'ra' (Ranger com cd) para .bashrc e .zshrc
# ====================================================
echo "==> Configurando função 'ra' (Ranger)..."

CONFIG_BLOCK=$(cat << 'EOT'

# --- Função 'ra' (Ranger com CD automático) ---
# Impede conflito com alias
unalias ra 2>/dev/null

function ra {
    local tempfile="$(mktemp -t ranger-cd.XXXXXX)"
    ranger --choosedir="$tempfile" "${@:-$(pwd)}"
    if [ -f "$tempfile" ]; then
        local target_dir="$(cat "$tempfile")"
        rm -f "$tempfile"
        if [ -n "$target_dir" ] && [ "$target_dir" != "$(pwd)" ]; then
            cd "$target_dir"
        fi
    fi
}
EOT
)

# Aplica no Bash
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q 'function ra {' ~/.bashrc; then
        echo "$CONFIG_BLOCK" >> ~/.bashrc
        echo "Função 'ra' adicionada ao .bashrc"
    fi
fi

# Aplica no Zsh
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q 'function ra {' ~/.zshrc; then
        echo "$CONFIG_BLOCK" >> ~/.zshrc
        echo "Função 'ra' adicionada ao .zshrc"
    fi
fi

# ====================================================
# 4. Configuração do URxvt (.Xresources)
# ====================================================
echo "==> Configurando .Xresources (Tema Solarized)..."

cat > "$HOME/.Xresources" << 'EOT'
! URxvt Configurações - Tema Solarized Dark

! === Fonte ===
URxvt.font:             xft:DejaVu Sans Mono:size=12
URxvt.boldFont:         xft:DejaVu Sans Mono:bold:size=12

! === Cores (Solarized Dark) ===
URxvt.background:       #002b36
URxvt.foreground:       #839496
URxvt.cursorColor:      #93a1a1
URxvt.color0:           #073642
URxvt.color8:           #002b36
URxvt.color1:           #dc322f
URxvt.color9:           #cb4b16
URxvt.color2:           #859900
URxvt.color10:          #586e75
URxvt.color3:           #b58900
URxvt.color11:          #657b83
URxvt.color4:           #268bd2
URxvt.color12:          #839496
URxvt.color5:           #d33682
URxvt.color13:          #6c71c4
URxvt.color6:           #2aa198
URxvt.color14:          #93a1a1
URxvt.color7:           #eee8d5
URxvt.color15:          #fdf6e3

! === Scroll e Buffer ===
URxvt.scrollBar: false
URxvt.saveLines: 8192
URxvt.internalBorder: 5
URxvt.letterSpace: -1

! === Clipboard (Requer perl extensions) ===
URxvt.perl-ext-common: default,matcher,selection-to-clipboard
URxvt.keysym.C-S-c: eval:selection_to_clipboard
URxvt.keysym.C-S-v: eval:paste_clipboard
URxvt.url-launcher: xdg-open
URxvt.matcher.button: 1
EOT

# Recarrega se possível
if command -v xrdb > /dev/null; then
    xrdb -merge ~/.Xresources
    echo ".Xresources recarregado."
fi

# ====================================================
# 5. Wallpapers
# ====================================================
echo "==> Copiando Wallpapers..."
# Garante que as pastas existem antes de copiar
mkdir -p ~/git/submodules/walls
mkdir -p ~/git/configureGit/walls

# Verifica se a origem existe antes de tentar copiar
if [ -f ~/git/configureGit/walls/1337390.png ]; then
    cp ~/git/configureGit/walls/1337390.png ~/git/submodules/walls/
fi
if [ -f ~/git/configureGit/walls/snorlax.jpg ]; then
    cp ~/git/configureGit/walls/snorlax.jpg ~/git/submodules/walls/
fi
echo "Wallpapers copiados (se encontrados na origem)."

echo ""
echo "=== Personalização Concluída! ==="
echo "Dica: Adicione 'set clipboard=unnamedplus' manualmente ao seu arquivo doti3/dotvimrc."

# ====================================================
# 6. Copiar Scripts Auxiliares do i3 (Brilho, GPU, Shutdown)
# ====================================================
echo "==> Instalando scripts auxiliares e Rofi..."

mkdir -p ~/.config/i3

if [ -d ~/git/configureGit/doti3 ]; then
    echo "Copiando todos os arquivos de doti3..."
    
    # Copia TUDO (sobrescreve se já existir)
    cp -r ~/git/configureGit/doti3/* ~/.config/i3/
    
    # Ajusta os nomes dos arquivos de configuração
    # O i3 espera 'config', mas no git está 'config_git'
    if [ -f ~/.config/i3/config_git ]; then
        mv ~/.config/i3/config_git ~/.config/i3/config
    fi
    
    if [ -f ~/.config/i3/i3blocks.conf_git ]; then
        mv ~/.config/i3/i3blocks.conf_git ~/.config/i3/i3blocks.conf
    fi

    # Dá permissão de execução para todos os scripts e binários
    chmod +x ~/.config/i3/*
    sudo chmod +s $(which brightnessctl)
    echo "Scripts copiados e permissões ajustadas."
else
    echo "AVISO: Scripts não encontrados em ~/git/configureGit/doti3/"
fi

# ====================================================
# 7. Desativar ISO 14755 (Fix do Ctrl+Shift no URxvt)
# ====================================================
echo "==> Desativando entrada ISO 14755 (Símbolos Unicode)..."

# Adiciona ao .Xresources apenas se ainda não estiver lá
if [ -f "$HOME/.Xresources" ]; then
    if ! grep -q "URxvt.iso14755" "$HOME/.Xresources"; then
        cat >> "$HOME/.Xresources" << 'EOT'

! === Correção: Desativar ISO 14755 ===
! Isso impede que Ctrl+Shift bloqueie o terminal esperando entrada Unicode
URxvt.iso14755: false
URxvt.iso14755_52: false
EOT
        # Aplica a alteração imediatamente
        xrdb -merge "$HOME/.Xresources"
        echo "ISO 14755 desativado. Ctrl+Shift agora deve funcionar para atalhos."
    else
        echo "Configuração ISO 14755 já estava presente."
    fi
else
    echo "Arquivo .Xresources não encontrado. Criando..."
    echo "URxvt.iso14755: false" > "$HOME/.Xresources"
    echo "URxvt.iso14755_52: false" >> "$HOME/.Xresources"
    xrdb -merge "$HOME/.Xresources"
fi

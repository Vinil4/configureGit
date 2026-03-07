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
echo "==> Configurando .Xresources e Scripts Perl para Clipboard..."

# Instala o script de clipboard manualmente se não existir
mkdir -p ~/.urxvt/ext/
if [ ! -f ~/.urxvt/ext/clipboard ]; then
    curl -o ~/.urxvt/ext/clipboard https://raw.githubusercontent.com/muennich/urxvt-perls/master/deprecated/clipboard
    chmod +x ~/.urxvt/ext/clipboard
fi

cat > "$HOME/.Xresources" << EOT
! URxvt Configurações - Tema Solarized Dark
URxvt.font:             xft:DejaVu Sans Mono:size=12
URxvt.boldFont:         xft:DejaVu Sans Mono:bold:size=12

! Cores Solarized
! special
*.foreground:   #93a1a1
*.background:   #002b36
*.cursorColor:  #93a1a1

! black
*.color0:       #002b36
*.color8:       #657b83

! red
*.color1:       #dc322f
*.color9:       #dc322f

! green
*.color2:       #859900
*.color10:      #859900

! yellow
*.color3:       #b58900
*.color11:      #b58900

! blue
*.color4:       #268bd2
*.color12:      #268bd2

! magenta
*.color5:       #6c71c4
*.color13:      #6c71c4

! cyan
*.color6:       #2aa198
*.color14:      #2aa198

! white
*.color7:       #93a1a1
*.color15:      #fdf6e3

! Scroll e Buffer
URxvt.scrollBar: false
URxvt.saveLines: 8192
URxvt.internalBorder: 5

! Clipboard e Fixes
URxvt.perl-lib: $HOME/.urxvt/ext/
URxvt.perl-ext-common: default,matcher,clipboard
URxvt.keysym.Control-Shift-C: perl:clipboard:copy
URxvt.keysym.Control-Shift-V: perl:clipboard:paste
URxvt.iso14755: false
URxvt.iso14755_52: false
EOT

# Recarrega as configurações
if command -v xrdb > /dev/null; then
    xrdb -load ~/.Xresources
    echo ".Xresources carregado com sucesso."
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
# 7. CONFIGURAÇÃO AUTOMÁTICA DO RANGER (rifle.conf)
# ====================================================
echo "==> Configurando rifle.conf do Ranger para abrir texto no Vim..."

# Garante que a pasta de config existe
mkdir -p "$HOME/.config/ranger"

# Cria ou sobrescreve o rifle.conf com a nossa regra prioritária no topo
# 'cat' para criar o topo e depois anexar o conteúdo original se ele existir
{
    echo "# --- Regra automática inserida pelo setup ---"
    echo "mime ^text,  label editor = vim -- \"\$@\""
    echo "ext yml|yaml|json|conf|ini|sh|py|js|md, label editor = vim -- \"\$@\""
    echo ""
    
    # Se o arquivo já existir, anexa o conteúdo dele abaixo da nossa regra
    if [ -f "$HOME/.config/ranger/rifle.conf" ]; then
        cat "$HOME/.config/ranger/rifle.conf"
    else
        # Se não existir, gera o padrão do ranger
        ranger --copy-config=rifle > /dev/null 2>&1
        cat "$HOME/.config/ranger/rifle.conf"
    fi
} > "$HOME/.config/ranger/rifle.conf.tmp"

mv "$HOME/.config/ranger/rifle.conf.tmp" "$HOME/.config/ranger/rifle.conf"
echo "Regra do Ranger aplicada."

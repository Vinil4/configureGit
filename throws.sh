#!/bin/bash

# Este script aplica 5 personalizações:
# 1. Instala dependências e configura o clipboard do sistema no Vim
# 2. Altera o prefixo do Tmux para Ctrl+A, adiciona o modo Vim e atalhos de 'kill'
# 3. Cria uma FUNÇÃO 'ra' para o ranger (para mudar o diretório ao sair)
# 4. Inicia o Tmux automaticamente no login do shell
# 5. Configura o terminal URxvt (rxvt-unicode) com tema e fonte

echo "==> Instalando dependências para o clipboard (vim-gtk3 e xclip)..."
sudo apt update
sudo apt install -y vim-gtk3 xclip
echo ""

echo "==> Configurando o Vim para usar a área de transferência do sistema..."
VIMRC_FILE="$HOME/.vimrc"
CLIPBOARD_LINE="set clipboard=unnamedplus"
touch "$VIMRC_FILE"

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

echo "==> Configurando o Tmux (prefixo Ctrl+A e modo Vim)..."
touch ~/.tmux.conf
# Prefixo
if ! grep -q "unbind C-b" ~/.tmux.conf; then
    echo 'unbind C-b' >> ~/.tmux.conf
fi
if ! grep -q "set -g prefix C-a" ~/.tmux.conf; then
    echo 'set -g prefix C-a' >> ~/.tmux.conf
fi
if ! grep -q "bind C-a send-prefix" ~/.tmux.conf; then
    echo 'bind C-a send-prefix' >> ~/.tmux.conf
fi

# Modo Vim e Navegação
if ! grep -q "# Configurações de \"Vim Mode\"" ~/.tmux.conf; then
    echo "" >> ~/.tmux.conf
    echo "# Configurações de \"Vim Mode\"" >> ~/.tmux.conf
fi
if ! grep -q "set-window-option -g mode-keys vi" ~/.tmux.conf; then
    echo "set-window-option -g mode-keys vi" >> ~/.tmux.conf
fi
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

# Redimensionar painéis
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

# --- ATALHOS PARA MATAR (ADICIONADO) ---
if ! grep -q "bind q kill-pane" ~/.tmux.conf; then
    echo "" >> ~/.tmux.conf
    echo "# Atalho para matar o painel atual (q)" >> ~/.tmux.conf
    echo "bind q kill-pane" >> ~/.tmux.conf
fi

if ! grep -q "bind Q confirm-before" ~/.tmux.conf; then
    echo "" >> ~/.tmux.conf
    echo "# Atalho para matar o servidor (Shift+Q, com confirmação)" >> ~/.tmux.conf
    echo 'bind Q confirm-before -p "Matar todo o servidor tmux? (y/n)" kill-server' >> ~/.tmux.conf
fi

# Adiciona o cabeçalho se não existir
if ! grep -qF "# --- Configurações de Cópia (estilo Vim) ---" ~/.tmux.conf; then
	echo "" >> ~/.tmux.conf
	echo "# --- Configurações de Cópia (estilo Vim) ---" >> ~/.tmux.conf
fi

# Adiciona o binding 'v' se não existir
if ! grep -qF "bind-key -T copy-mode-vi 'v' send-keys -X begin-selection" ~/.tmux.conf; then
	echo "# 'v' começa a seleção (como no Vim)" >> ~/.tmux.conf
	echo "bind-key -T copy-mode-vi 'v' send-keys -X begin-selection" >> ~/.tmux.conf
fi

# Adiciona o binding 'y' (com xsel) se não existir
if ! grep -qF "bind-key -T copy-mode-vi 'y' send-keys -X copy-pipe-and-cancel 'xsel --clipboard --input'" ~/.tmux.conf; then
	echo "# 'y' copia a seleção E envia para o clipboard do sistema (usando xsel)" >> ~/.tmux.conf
	echo "bind-key -T copy-mode-vi 'y' send-keys -X copy-pipe-and-cancel 'xsel --clipboard --input'" >> ~/.tmux.conf
fi

echo "Configuração do Tmux (com modo Vim e atalhos de 'kill') concluída."
echo ""

# ----------------------------------------------------

echo "==> Configurando o Shell (função 'ra' e auto-start do Tmux)..."
# --- CORRIGIDO: Adicionado 'unalias' para garantir que a função 'ra' ganhe ---
CONFIG_BLOCK=$(cat << 'EOT'

# ==================================
# Minhas Personalizações (auto-gerado)
# ==================================

# 1. Função 'ra' (Ranger) com 'cd' ao sair
# Remove qualquer 'alias ra' conflitante que possa existir
unalias ra 2>/dev/null

function ra {
    local tempfile="$(mktemp -t ranger-cd.XXXXXX)"
    # --choosedir diz ao ranger para escrever o último dir neste arquivo
    # "${@:-$(pwd)}" inicia o ranger no diretório atual
    ranger --choosedir="$tempfile" "${@:-$(pwd)}"
    
    # Se o arquivo temporário foi criado e ainda existe
    if [ -f "$tempfile" ]; then
        local target_dir="$(cat "$tempfile")"
        rm -f "$tempfile"
        
        # Se o diretório de destino não estiver vazio e for diferente do atual
        if [ -n "$target_dir" ] && [ "$target_dir" != "$(pwd)" ]; then
            # Muda para o diretório de destino
            cd "$target_dir"
        fi
    fi
}

# 2. Carregar o ambiente do ROS 2
if [ -f /opt/ros/jazzy/setup.bash ]; then
    source /opt/ros/jazzy/setup.bash
fi

# 2. Iniciar o Tmux automatically
# (Apenas se não estivermos já no Tmux e se for uma sessão interativa)
if [ -z "$TMUX" ] && [ "$TERM" != "dumb" ] && [ -n "$PS1" ]; then
    # O -A "atacha" a uma sessão "main" ou cria uma se não existir.
    tmux new-session -A -s main
fi
EOT
)

# Aplicar ao .bashrc
if [ -f "$HOME/.bashrc" ]; then
    # --- CORRIGIDO: Procura pela função 'ra' em vez do alias ---
    if ! grep -q 'function ra {' ~/.bashrc; then
        echo "$CONFIG_BLOCK" >> ~/.bashrc
        echo "Configuração aplicada ao ~/.bashrc"
    else
        echo "Configuração já existe no ~/.bashrc (pulado)"
    fi
fi

# Aplicar ao .zshrc
if [ -f "$HOME/.zshrc" ]; then
    # --- CORRIGIDO: Procura pela função 'ra' em vez do alias ---
    if ! grep -q 'function ra {' ~/.zshrc; then
        echo "$CONFIG_BLOCK" >> ~/.zshrc
        echo "Configuração aplicada ao ~/.zshrc"
    else
        echo "Configuração já existe no ~/.zshrc (pulado)"
    fi
fi

# ----------------------------------------------------

echo "==> Configurando o URxvt (Terminal)..."
# CORRIGIDO: Removemos as configurações 'perl' e 'keysym'
# que não funcionam na sua instalação.
# O clipboard agora deve ser usado com Seleção (copiar) e Botão do Meio/Shift+Insert (colar).
XRESOURCES_CONTENT=$(cat << 'EOT'
! URxvt Configurações - Tema Solarized Dark

! === Fonte ===
URxvt.font:             xft:DejaVu Sans Mono:size=12
URxvt.boldFont:         xft:DejaVu Sans Mono:bold:size=12

! === Cores ===
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
URxvt.colorG13:          #6c71c4
URxvt.color6:           #2aa198
URxvt.color14:          #93a1a1
URxvt.color7:           #eee8d5
URxvt.color1As5:          #fdf6e3

! === Outras Configurações ===
URxvt.scrollBar: false
URxvt.saveLines: 8192
URxvt.internalBorder: 5
URxvt.letterSpace: -1

! Desabilita o modo ISO 14755 (que usa Ctrl+Shift)
URxvt.iso14755: false
URxvt.iso14755_52: false
EOT
)

# Escreve o conteúdo no arquivo .Xresources
echo "$XRESOURCES_CONTENT" > "$HOME/.Xresources"
echo "Arquivo ~/.Xresources criado com o tema."

# Tenta carregar as configurações imediatamente
if command -v xrdb > /dev/null; then
    xrdb -merge ~/.Xresources
    echo "Configurações do URxvt carregadas."
else
    echo "Comando 'xrdb' não encontrado. Pule a recarga do .Xresources."
fi

# ----------------------------------------------------

if ! grep -q "source /opt/ros/jazzy/setup.bash" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# setup dos ROS 2 JAZZY" >> ~/.bashrc
    echo 'source /opt/ros/jazzy/setup.bash' >> ~/.bashrc
fi

mkdir -p ~/git/submodules/walls &&
cp ~/git/configureGit/walls/1337390.png ~/git/configureGit/walls/snorlax.jpg ~/git/submodules/walls

echo ""
echo "Concluído!"
echo ""
echo "Para aplicar as mudanças do shell (função 'ra', tmux), reinicie o seu terminal ou execute:"
echo "  source ~/.bashrc"
echo "  ou"
echo "  source ~/.zshrc"
echo ""
echo "As novas configurações do URxvt (cores/fonte) serão aplicadas na próxima vez que você abrir um novo terminal."

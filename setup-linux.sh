#!/bin/bash

#==================================================
# CONFIGURAÇÃO INICIAL E DEPENDÊNCIAS
#==================================================

# Para o script se qualquer comando falhar
set -e

# Define o diretório principal para clonar os repositórios
MAIN_DIR=~/git/submodules

# Encontra o diretório onde o script .sh está sendo executado
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "Diretório do script detectado: $SCRIPT_DIR"

echo "==> Criando diretório principal em $MAIN_DIR..."
mkdir -p "$MAIN_DIR"

echo "==> Atualizando repositórios APT..."
sudo apt update

echo "==> Instalando ferramentas e dependências via APT..."

# Atualiza listas
sudo apt update

# Instala tudo de uma vez
sudo apt install -y \
    git \
    build-essential \
    cmake \
    pkg-config \
    make \
    automake \
    autoconf \
    curl \
    python3-pip \
    python3-dev \
    python3-venv \
    golang \
    jq \
    libreadline-dev \
    lightdm \
    i3-wm \
    i3lock \
    i3status \
    i3blocks \
    suckless-tools \
    dmenu \
    rofi \
    feh \
    picom \
    xorg \
    xinit \
    xbindkeys \
    xdotool \
    lxappearance \
    arandr \
    tmux \
    tmuxinator \
    ranger \
    fzf \
    silversearcher-ag \
    htop \
    zsh-syntax-highlighting \
    vim-gtk3 \
    pdfpc \
    pulseaudio \
    alsa-utils \
    pasystray \
    light \
    brightnessctl \
    fonts-font-awesome \
    fonts-terminus \
    xfonts-terminus \
    dunst \
    gettext \
    intltool \
    libeigen3-dev \
    libboost-all-dev \
    libusb-1.0-0-dev \
    libceres-dev \
    libglib2.0-dev \
    libx11-dev \
    libxkbfile-dev \
    libqt5svg5

echo "==> Instalação via APT concluída!"
echo "==> Aplicando upgrade do sistema..."
sudo apt upgrade -y

# ==================
# CONFIGURAÇÃO PÓS-INSTALAÇÃO
# ==================

echo "==> Configurando lightdm como o gerenciador de login padrão..."
sudo systemctl enable lightdm
sudo systemctl set-default graphical.target
echo "==> lightdm definido como padrão."


# Entra no diretório principal
cd "$MAIN_DIR"

#==================================================
# Instalação do Vimiv (Image Viewer)
#==================================================
echo "==> Instalando Vimiv (Image Viewer)..."

# 1. Instala dependências do sistema (Qt5 e bibliotecas gráficas)
sudo apt install -y python3-pyqt5 python3-setuptools python3-pip

# 2. Instala via PIP usando o nome correto ('vimiv', não 'vimiv-qt')
# O 'break-system-packages' é necessário no Ubuntu 24.04
sudo pip3 install vimiv --break-system-packages

# 3. Garante que o atalho existe
if ! command -v vimiv &> /dev/null; then
    # Às vezes o pip instala em ~/.local/bin e o sudo não vê
    echo "Aviso: O binário do vimiv pode não estar no PATH do sudo, mas deve funcionar para o usuário."
fi

echo "Vimiv instalado com sucesso."

#==================================================
# Pandoc Goodies
#==================================================
echo "==> Configurando Pandoc Goodies..."
if [ ! -d "$MAIN_DIR/pandoc-goodies" ]; then
    git clone https://github.com/tajmone/pandoc-goodies.git "$MAIN_DIR/pandoc-goodies"
fi

# Adiciona ao PATH se ainda não estiver
PANDOC_PATH="$MAIN_DIR/pandoc-goodies/scripts"
if ! grep -q "pandoc-goodies" ~/.bashrc; then
    echo "Adicionando Pandoc Goodies ao PATH (.bashrc)..."
    echo "export PATH=\"\$PATH:$PANDOC_PATH\"" >> ~/.bashrc
fi

# Se você usa ZSH, adiciona lá também
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "pandoc-goodies" ~/.zshrc; then
        echo "export PATH=\"\$PATH:$PANDOC_PATH\"" >> ~/.zshrc
    fi
fi

cd "$MAIN_DIR"

#==================================================
# i3blocks-contrib
#==================================================
if [ ! -d "$MAIN_DIR/i3blocks-contrib" ]; then
    echo "Clonando o repositório do i3blocks-contrib..."
    git clone https://github.com/vivien/i3blocks-contrib.git "$MAIN_DIR/i3blocks-contrib"
else
    echo "==> Repositório i3blocks-contrib já existe."
fi

echo "Entrando em $MAIN_DIR/i3blocks-contrib..."
cd "$MAIN_DIR/i3blocks-contrib"
echo "Atualizando repositório..."
git pull

if [ ! -d "$HOME/.config/i3blocks" ]; then
    echo "Diretório de configuração do i3blocks não existe. Criando..."
    mkdir -p "$HOME/.config/i3blocks"
fi

echo "Configurando i3blocks-contrib com autotools (configure/make)..."
./configure
echo "Compilando com make..."
make
echo "Instalando com make install..."
sudo make install

git reset --hard
git clean -fd
echo "Retornando para $MAIN_DIR"
cd "$MAIN_DIR"

#==================================================
# i3-layout-manager
#==================================================
if [ ! -d "$MAIN_DIR/i3-layout-manager" ]; then
    echo "Clonando o repositório do i3-layout-manager..."
    git clone https://github.com/klaxalk/i3-layout-manager.git "$MAIN_DIR/i3-layout-manager"
else
    echo "==> Repositório i3-layout-manager já existe."
fi

echo "Entrando em $MAIN_DIR/i3-layout-manager..."
cd "$MAIN_DIR/i3-layout-manager"
echo "Atualizando repositório..."
git pull

echo "Instalando o script 'layout_manager.sh' em /usr/local/bin..."
sudo cp layout_manager.sh /usr/local/bin/i3-layout-manager
sudo chmod +x /usr/local/bin/i3-layout-manager

git reset --hard
git clean -fd
echo "Retornando para $MAIN_DIR"
cd "$MAIN_DIR"

#==================================================
# git-sync
#==================================================
echo "Verificando git-sync..."
if command -v git-sync >/dev/null 2>&1; then
    echo "O git-sync já está instalado."
else
    echo "O git-sync não foi encontrado. Instalando..."
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin

    if [ ! -d "$MAIN_DIR/git-sync" ]; then
        echo "Clonando git-sync..."
        git clone https://github.com/AkashRajpurohit/git-sync.git "$MAIN_DIR/git-sync"
    fi
    
    cd "$MAIN_DIR/git-sync"
    git pull
    
    echo "Compilando git-sync..."
    go build -o git-sync
    sudo mv git-sync /usr/local/bin/

    if command -v git-sync >/dev/null 2>&1; then
        echo "git-sync instalado com sucesso!"
    else
        echo "Erro na instalação do git-sync!"
    fi
fi
cd "$MAIN_DIR"

#==================================================
# xkblayout-state
#==================================================
echo "Verificando xkblayout-state..."
if command -v xkblayout-state >/dev/null 2>&1; then
    echo "O xkblayout-state já está instalado."
else
    echo "O xkblayout-state não foi encontrado. Instalando..."

    if [ ! -d "$MAIN_DIR/xkblayout-state" ]; then
        echo "Clonando xkblayout-state (fork nonpop)..."
        git clone https://github.com/nonpop/xkblayout-state.git "$MAIN_DIR/xkblayout-state"
    fi
    
    echo "Entrando em $MAIN_DIR/xkblayout-state..."
    cd "$MAIN_DIR/xkblayout-state"
    git pull
    
    echo "Compilando xkblayout-state..."
    make
    sudo make install
    hash -r

    if command -v xkblayout-state >/dev/null 2>&1; then
        echo "xkblayout-state instalado com sucesso!"
    else
        echo "Erro na instalação do xkblayout-state!"
    fi
fi
cd "$MAIN_DIR"

#==================================================
# Keychron K2 Function Keys
#==================================================
echo "Configurando as teclas de função do Keychron (método hid_apple)..."

echo "Tentando carregar o módulo 'hid_apple'..."
sudo modprobe -q hid_apple

FNMODE_FILE="/sys/module/hid_apple/parameters/fnmode"

if [ -f "$FNMODE_FILE" ]; then
    echo "Módulo 'hid_apple' encontrado. Aplicando fnmode=2..."
    echo 2 | sudo tee "$FNMODE_FILE"
    echo "Tornando a configuração do Keychron permanente..."
    echo "options hid_apple fnmode=2" | sudo tee /etc/modprobe.d/hid_apple.conf
    echo "Configuração do Keychron K2 (hid_apple) aplicada com sucesso!"
    echo "AVISO: Pode ser necessário rodar 'sudo update-initramfs -u' ou reiniciar."
else
    echo "AVISO: O arquivo '$FNMODE_FILE' não foi encontrado."
    echo "O seu kernel pode já usar um driver dedicado (hid_keychron)."
    echo "Esta etapa foi pulada, pois provavelmente não é necessária."
fi

cd "$MAIN_DIR"

#==================================================
# Configuração Automática do ZSH Syntax Highlighting
#==================================================
# No Ubuntu 24.04 via APT, o script fica em /usr/share/...
ZSH_HIGHLIGHT_PATH="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

if [ -f "$ZSH_HIGHLIGHT_PATH" ]; then
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "zsh-syntax-highlighting.zsh" "$HOME/.zshrc"; then
            echo "Ativando zsh-syntax-highlighting no .zshrc..."
            echo "source $ZSH_HIGHLIGHT_PATH" >> "$HOME/.zshrc"
        fi
    else
        echo "AVISO: .zshrc não encontrado. Instale o zsh e oh-my-zsh primeiro."
    fi
fi

#==================================================
# Configuração do Touchpad (Tap-to-Click)
#==================================================
echo "==> Configurando o Touchpad (Tap-to-Click)..."

# Define o conteúdo do arquivo de configuração do Xorg
TOUCHPAD_CONFIG=$(cat << 'EOT'
Section "InputClass"
    Identifier "libinput touchpad catchall"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    # Habilita o "Tocar para Clicar"
    Option "Tapping" "on"
    # Habilita o movimento do touch invertido
    Option "NaturalScrolling" "true"
    # Habilita o "Clique com Botão Direito" ao tocar com dois dedos
    Option "TapButton2" "3"
    # Habilita o "Clique com Botão do Meio" ao tocar com três dedos
    Option "TapButton3" "2"
EndSection
EOT
)

# Cria o diretório se ele não existir
sudo mkdir -p /etc/X11/xorg.conf.d/

# Escreve a configuração no arquivo
echo "$TOUCHPAD_CONFIG" | sudo tee /etc/X11/xorg.conf.d/40-libinput.conf > /dev/null
echo "Configuração do touchpad aplicada."

# Cria o arquivo de configuração 00-keyboard.conf
echo 'Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "br"
        Option "XkbModel" "abnt2"
EndSection' | sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf > /dev/null

echo "Teclado configurado. Reinicie para aplicar no LightDM e no i3."

#==================================================
# CONFIGURAÇÃO DE DOTFILES (Vim e i3)
#==================================================
echo "==> Iniciando configuração de Dotfiles..."

# --- 1. CONFIGURAÇÃO DO VIM ---
# Procura pela pasta 'dotvim' e arquivo 'dotvimrc' ao lado do script
VIM_SOURCE_DIR="$SCRIPT_DIR/dotvim"
VIMRC_SOURCE_FILE="$SCRIPT_DIR/dotvimrc" # Verifique se o nome é esse mesmo na sua pasta

if [ -d "$VIM_SOURCE_DIR" ]; then
    echo "Configurando Vim..."
    
    # Linka o .vimrc
    if [ -f "$VIMRC_SOURCE_FILE" ]; then
        ln -sf "$VIMRC_SOURCE_FILE" "$HOME/.vimrc"
        echo "  -> Link criado: ~/.vimrc aponta para $VIMRC_SOURCE_FILE"
    else
        # Tenta procurar dentro da pasta dotvim se não estiver fora
        if [ -f "$VIM_SOURCE_DIR/vimrc" ]; then
             ln -sf "$VIM_SOURCE_DIR/vimrc" "$HOME/.vimrc"
             echo "  -> Link criado: ~/.vimrc aponta para $VIM_SOURCE_DIR/vimrc"
        else
             echo "  AVISO: Arquivo de configuração do vim (dotvimrc ou vimrc) não encontrado."
        fi
    fi

    # Linka a pasta .vim inteira
    # Remove a pasta antiga se existir (cuidado aqui, faz backup se tiver coisas importantes)
    rm -rf "$HOME/.vim"
    ln -sf "$VIM_SOURCE_DIR" "$HOME/.vim"
    echo "  -> Link criado: ~/.vim aponta para $VIM_SOURCE_DIR"

    # Instala o gerenciador de plugins (Plug)
    echo "  -> Baixando vim-plug..."
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    
    echo "  -> Instalando plugins..."
    # Roda o vim silenciosamente para instalar plugins
    vim -E -s -u "$HOME/.vimrc" +PlugInstall +qall || echo "Aviso: Erro ao instalar plugins (normal se for a primeira vez)"
else
    echo "AVISO: Pasta 'dotvim' não encontrada em $SCRIPT_DIR."
fi

# --- 2. CONFIGURAÇÃO DO i3 e i3blocks ---
I3_SOURCE_DIR="$SCRIPT_DIR/doti3"

if [ -d "$I3_SOURCE_DIR" ]; then
    echo "Configurando i3 e i3blocks..."
    
    # Cria o diretório padrão moderno
    mkdir -p "$HOME/.config/i3"

    # --- Config do i3 ---
    # Verifica se o arquivo se chama 'config_git' (como você mencionou) ou apenas 'config'
    if [ -f "$I3_SOURCE_DIR/config_git" ]; then
        ln -sf "$I3_SOURCE_DIR/config_git" "$HOME/.config/i3/config"
        echo "  -> Link criado: ~/.config/i3/config aponta para config_git"
    elif [ -f "$I3_SOURCE_DIR/config" ]; then
        ln -sf "$I3_SOURCE_DIR/config" "$HOME/.config/i3/config"
        echo "  -> Link criado: ~/.config/i3/config aponta para config"
    else
        echo "  ERRO: Arquivo de config do i3 não encontrado dentro de doti3."
    fi
    
    # --- INJEÇÃO DO PASYSTRAY ---
    # Isso garante que o pasystray inicie junto com o i3
    if [ -f "$HOME/.config/i3/config" ]; then
        if ! grep -q "pasystray" "$HOME/.config/i3/config"; then
            echo "Adicionando pasystray ao config do i3..."
            echo "" >> "$HOME/.config/i3/config"
            echo "# Volume Control (Adicionado pelo setup.sh)" >> "$HOME/.config/i3/config"
            echo "exec --no-startup-id pasystray" >> "$HOME/.config/i3/config"
        else
            echo "  -> Pasystray já configurado no i3."
        fi
    fi

    # --- Config do i3blocks ---
    if [ -f "$I3_SOURCE_DIR/i3blocks.conf_git" ]; then
        ln -sf "$I3_SOURCE_DIR/i3blocks.conf_git" "$HOME/.config/i3/i3blocks.conf"
        echo "  -> Link criado: ~/.config/i3/i3blocks.conf aponta para i3blocks.conf_git"
    elif [ -f "$I3_SOURCE_DIR/i3blocks.conf" ]; then
        ln -sf "$I3_SOURCE_DIR/i3blocks.conf" "$HOME/.config/i3/i3blocks.conf"
        echo "  -> Link criado: ~/.config/i3/i3blocks.conf aponta para i3blocks.conf"
    fi
    
    # Garante permissão de execução se tiver scripts dentro
    chmod +x "$I3_SOURCE_DIR"/* 2>/dev/null || true

else
    echo "AVISO: Pasta 'doti3' não encontrada em $SCRIPT_DIR."
fi

#==================================================
# Instalação do ROS 2 (Jazzy) 
#==================================================
echo "==> Iniciando a instalação do ROS 2 Jazzy..."

echo "==> 1. Configurando o 'locale' (UTF-8)..."
sudo apt-get update
sudo apt-get install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8
echo "Locale configurado."

echo "==> 2. Adicionando repositórios..."
sudo apt-get install -y software-properties-common curl gnupg lsb-release
sudo add-apt-repository -y universe

# Baixa a chave do ROS
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

# Adiciona a fonte do ROS 2
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

echo "==> 3. Instalando ROS 2 Jazzy e Ferramentas de Simulação..."
sudo apt-get update
sudo apt-get install -y \
    ros-jazzy-desktop-full \
    ros-dev-tools \
    python3-colcon-common-extensions \
    git \
    python3-rosdep \

# Inicializa rosdep se necessário
if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
    sudo rosdep init
fi
rosdep update

echo "==> Instalação do ROS 2 Jazzy + Gazebo Harmonic concluída!"
echo "==> AVISO IMPORTANTE: Adicione o seguinte ao seu ~/.bashrc ou ~/.zshrc:"
echo "==>   source /opt/ros/jazzy/setup.bash"
echo "=================================================="

cd $MAIN_DIR

# --- Finalização ---
echo "==> Configurando Variáveis de Ambiente Finais..."

#===================================================
# Configuração das Variáveis de ambiente e Sources
#===================================================

echo "==> Configurando variáveis de ambiente no .bashrc..."

# --- GARANTE O VIM CUSTOMIZADO NO TERMINAL ---
if ! grep -q "export EDITOR=vim" ~/.bashrc; then
    echo "Definindo Vim como editor padrão (para Ctrl-x Ctrl-e funcionar)..."
    echo "export EDITOR=vim" >> ~/.bashrc
    echo "export VISUAL=vim" >> ~/.bashrc
fi

# 1. Adicionar Source do ROS 2 Jazzy
if ! grep -q "source /opt/ros/jazzy/setup.bash" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# ROS 2 Jazzy" >> ~/.bashrc
    echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
fi

# Mensagem Final Estilosa
# Verifica se o toilet está instalado para não dar erro no script
if command -v toilet &> /dev/null; then
    toilet -f smblock "LASER UAV"
    toilet -f smblock "INSTALLED"
else
    echo "========================================="
    echo "   LASER UAV - INSTALACAO CONCLUIDA      "
    echo "========================================="
fi

echo "==> ATENÇÃO: Feche este terminal e abra um novo para as alterações surtirem efeito."

#===================================================
# Verificação final do lightdm
# ==================================================

if ! dpkg -l | grep -q lightdm; then
    echo "AVISO: lightdm não foi instalado corretamente!"
else
    echo "lightdm instalado com sucesso!"
fi

echo "=============================================="
echo "Instalação e configuração concluídas!"
echo "AVISOS IMPORTANTES:"
echo "1. Os plugins do Vim (YCM, NERDTree, etc) foram instalados em $MAIN_DIR."
echo "2. Suas configs 'doti3' foram linkadas a partir de $SCRIPT_DIR."
echo "3. Reinicie seu shell (ou 'source ~/.bashrc' / 'source ~/.zshrc') para aplicar mudanças de PATH."
echo "4. Você precisará adicionar 'zsh-syntax-highlighting' manualmente ao seu ~/.zshrc."
echo "5. REINICIE O COMPUTADOR para que o 'lightdm', 'urxvt', e as mudanças do 'hid_apple' tenham efeito."
echo "=============================================="

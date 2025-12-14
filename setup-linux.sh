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
    # --- Ferramentas de Build e Base ---
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
    
    # --- Interface Gráfica (i3 e utilitários) ---
    lightdm \
    i3-wm \
    i3lock \
    i3status \
    i3blocks \
    suckless-tools \
    dmenu \
    rofi \
    feh \
    compton \
    xorg \
    xinit \
    xbindkeys \
    xdotool \
    lxappearance \
    arandr \
    
    # --- Terminal e Produtividade (Substituindo seus submodules antigos) ---
    tmux \
    tmuxinator \
    ranger \
    fzf \
    silversearcher-ag \
    htop \
    zsh-syntax-highlighting \
    
    # --- Editores e Visualizadores ---
    vim-gtk3 \
    pdfpc \
    vimiv \
    
    # --- Áudio e Brilho ---
    pulseaudio \
    alsa-utils \
    pasystray \
    light \
    brightnessctl \
    
    # --- Fontes ---
    fonts-font-awesome \
    fonts-terminus \
    xfonts-terminus \
    
    # --- Dependências de Robótica (PX4/ROS) ---
    libeigen3-dev \
    libboost-all-dev \
    libusb-1.0-0-dev \
    libceres-dev \
    libglib2.0-dev

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
# Athame (Vim mode for Readline)
#==================================================
echo "==> Configurando Athame..."
if [ ! -d "$MAIN_DIR/athame" ]; then
    echo "Clonando Athame..."
    git clone https://github.com/ardagnir/athame.git "$MAIN_DIR/athame"
fi

echo "Entrando em $MAIN_DIR/athame..."
cd "$MAIN_DIR/athame"
git pull

echo "Compilando Athame..."
make
sudo make install

# O Athame geralmente precisa atualizar o arquivo .inputrc
echo "Atualizando .inputrc para suportar Athame..."
# Verifica se já existe configuração para não duplicar
if ! grep -q "athame_init" ~/.inputrc 2>/dev/null; then
    echo '$include /usr/local/lib/athame/athame_init.rl' >> ~/.inputrc
    echo "set editing-mode vi" >> ~/.inputrc
    echo "Configuração adicionada ao ~/.inputrc"
else
    echo "Athame já configurado no .inputrc."
fi

cd "$MAIN_DIR"

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
# indicator-sound-switcher
#==================================================
echo "Verificando indicator-sound-switcher..."

if [ ! -d "$MAIN_DIR/indicator-sound-switcher" ]; then
    echo "Clonando indicator-sound-switcher (fork 'yktoo')..."
    git clone https://github.com/yktoo/indicator-sound-switcher.git "$MAIN_DIR/indicator-sound-switcher"
fi

echo "Entrando em $MAIN_DIR/indicator-sound-switcher..."
cd "$MAIN_DIR/indicator-sound-switcher"
git pull
echo "Limpando diretório 'build' antigo..."
sudo rm -rf build

echo "Instalando com pip (setup.py)..."
sudo pip3 install . --break-system-packages
hash -r

if command -v indicator-sound-switcher >/dev/null 2>&1; then
    echo "indicator-sound-switcher instalado com sucesso!"
else
    echo "Erro na instalação do indicator-sound-switcher!"
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
# Instalação do ROS 2 (Jazzy) + Gazebo Harmonic
#==================================================
echo "==> Iniciando a instalação do ROS 2 Jazzy e Gazebo Harmonic..."

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
    ros-jazzy-ros-gz  # <--- Instala Gazebo Harmonic e a ponte ROS automaticamente

# Inicializa rosdep se necessário
if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
    sudo rosdep init
fi
rosdep update

echo "==> Instalação do ROS 2 Jazzy + Gazebo Harmonic concluída!"
echo "==> AVISO IMPORTANTE: Adicione o seguinte ao seu ~/.bashrc ou ~/.zshrc:"
echo "==>   source /opt/ros/jazzy/setup.bash"
echo "=================================================="

#===================================================
# Instalação do firmware PX4 (Para Gazebo Harmonic)
#===================================================

# 1. Instalar Micro XRCE-DDS Agent (Obrigatório para ROS 2 <-> PX4)
echo "==> Instalando Micro XRCE-DDS Agent..."
if [ ! -f "/usr/local/bin/MicroXRCEAgent" ]; then
    sudo apt-get install -y build-essential cmake
    mkdir -p /tmp/xrce_build && cd /tmp/xrce_build
    git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git
    cd Micro-XRCE-DDS-Agent && mkdir build && cd build
    cmake ..
    make
    sudo make install
    sudo ldconfig /usr/local/lib/
    rm -rf /tmp/xrce_build
    echo "Agent instalado com sucesso."
else
    echo "Agent já estava instalado."
fi

# 2. Clonar o PX4
echo "==> Clonando PX4 Autopilot..."
cd $MAIN_DIR
if [ ! -d "PX4-Autopilot" ]; then
    git clone https://github.com/PX4/PX4-Autopilot.git --recursive
else
    echo "Pasta PX4-Autopilot já existe. Atualizando..."
    cd PX4-Autopilot
    git pull
    git submodule update --init --recursive
    cd ..
fi

# 3. Setup de dependências do PX4
echo "==> Instalando dependências do PX4 via script oficial..."
cd PX4-Autopilot
# --no-nuttx: Pula compiladores de hardware físico (economiza tempo)
bash ./Tools/setup/ubuntu.sh --no-nuttx

# Dependências Python extras para garantir compatibilidade
pip3 install --user -U empy==3.3.4 pyros-genmsg setuptools kconfiglib jinja2 jsonschema future packaging gitman --break-system-packages || true

# 4. Compilar para Gazebo Harmonic (gz-sim)
echo "==> Compilando PX4 SITL para GAZEBO HARMONIC..."

make px4_sitl_default

echo "==> Setup do PX4 Concluído!"

#===================================================
# Instalação do ACADOS
#===================================================

echo "==> Instalando ACADOS (Solver NMPC)..."
# instalar em ~/git/dependencies para ficar organizado
mkdir -p ~/git/dependencies
cd ~/git/dependencies

if [ ! -d "acados" ]; then
    git clone https://github.com/acados/acados.git
    cd acados
    git submodule update --recursive --init
    mkdir -p build
    cd build
    # Flag QPOASES ativada
    cmake -DACADOS_WITH_QPOASES=ON ..
    make install -j4
    
    # Exportar variáveis para o .bashrc
    echo "" >> ~/.bashrc
    echo "# ACADOS Configuration" >> ~/.bashrc
    echo "export ACADOS_SOURCE_DIR=\"$HOME/git/dependencies/acados\"" >> ~/.bashrc
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\"$HOME/git/dependencies/acados/lib\"" >> ~/.bashrc
    echo "   -> ACADOS instalado e variáveis adicionadas ao .bashrc"
else
    echo "   -> ACADOS já parece estar instalado."
fi

# --- Finalização ---
echo "==> Configurando Variáveis de Ambiente Finais..."

#===================================================
# Configuração das Variáveis de ambiente e Sources
#===================================================

echo "==> Configurando variáveis de ambiente no .bashrc..."

# 1. Adicionar Source do ROS 2 Jazzy
if ! grep -q "source /opt/ros/jazzy/setup.bash" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# ROS 2 Jazzy" >> ~/.bashrc
    echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
fi

# 2. Configurações do MicroXRCEAgent (Facilita rodar o agente)
if ! grep -q "MicroXRCEAgent" ~/.bashrc; then
    echo "# Atalho para o Agente PX4 <-> ROS 2" >> ~/.bashrc
    echo "alias run_agent='MicroXRCEAgent udp4 -p 8888'" >> ~/.bashrc
fi

# 3. Variáveis de Simulação (Gazebo Harmonic não precisa de tantas vars manuais quanto o Classic)
# Mas é bom garantir que o shell saiba onde está o PX4
if ! grep -q "PX4_SOURCE_DIR" ~/.bashrc; then
    echo "export PX4_SOURCE_DIR=$HOME/git/submodules/PX4-Autopilot" >> ~/.bashrc
    # Adiciona o diretório build ao path para acessar o binário px4 facilmente
    echo "export PATH=\$PATH:$HOME/git/submodules/PX4-Autopilot/build/px4_sitl_default/bin" >> ~/.bashrc
fi

echo "NOTA: O Simulador agora é o Gazebo Harmonic (gz-sim)."
echo "Para rodar a simulação: cd ~/git/submodules/PX4-Autopilot && make px4_sitl_default gz_x500"

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

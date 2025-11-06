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

echo "==> Instalando todas as dependências APT de uma vez..."
sudo apt install -y \
    git \
    meson \
    cmake \
    gettext \
    ninja-build \
    build-essential \
    pkg-config \
    make \
    automake \
    autoconf \
    curl \
    bison \
    lightdm \
    python3-pip \
    pandoc \
    vim \
    golang \
    ruby-full \
    rubygems \
    xbacklight \
    alsa-utils \
    pulseaudio \
    feh \
    arandr \
    lxappearance \
    thunar \
    rofi \
    compton \
    systemd \
    i3lock \
    jq \
    xbindkeys \
    xdotool \
    libxcb1-dev \
    libxcb-keysyms1-dev \
    libpango1.0-dev \
    libxcb-util0-dev \
    libxcb-icccm4-dev \
    libyajl-dev \
    libstartup-notification0-dev \
    libxcb-randr0-dev \
    libev-dev \
    libxcb-cursor-dev \
    libxcb-xinerama0-dev \
    libxcb-xkb-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libxcb-shape0-dev \
    xcb-proto \
    libglib2.0-dev \
    libevent-dev \
    libncurses5-dev \
    libpcre3 \
    libpcre3-dev \
    zlib1g-dev \
    libx11-dev \
    libxkbfile-dev \
    libgtk-3-dev \
    libayatana-appindicator3-dev \
    libcanberra-gtk3-dev \
    gnome-shell-extension-appindicator

echo "==> Aplicando upgrade do sistema..."
sudo apt upgrade -y

# Entra no diretório principal
cd "$MAIN_DIR"

#==================================================
# i3 (Airblader)
#==================================================
if [ ! -d "i3" ]; then
    echo "Clonando o repositório do i3 (Airblader)..."
    git clone https://github.com/Airblader/i3.git && cd i3
else
    echo "==> Repositório i3 já existe, atualizando..."
    cd i3 && git pull
fi

meson setup build
ninja -C build
sudo ninja -C build install
cd "$MAIN_DIR"

#==================================================
# i3blocks
#==================================================
if [ ! -d "i3blocks" ]; then
    echo "Clonando o repositório do i3blocks..."
    git clone https://github.com/vivien/i3blocks.git i3blocks && cd i3blocks
else
    echo "==> Repositório i3blocks já existe, atualizando..."
    cd i3blocks && git pull
fi

echo "Configurando i3blocks com autotools (configure/make)..."
# Opcional, mas garante que os scripts de build estejam atualizados
./autogen.sh
    
# Configura com o prefixo /usr para instalar no lugar certo
./configure --prefix=/usr
    
make
sudo make install
cd "$MAIN_DIR"

#==================================================
# i3blocks-contrib
#==================================================

# Garante que o repositório exista
if [ ! -d "$MAIN_DIR/i3blocks-contrib" ]; then
    echo "Clonando o repositório do i3blocks-contrib..."
    git clone https://github.com/vivien/i3blocks-contrib.git "$MAIN_DIR/i3blocks-contrib"
else
    echo "==> Repositório i3blocks-contrib já existe."
fi

# Entra no diretório
echo "Entrando em $MAIN_DIR/i3blocks-contrib..."
cd "$MAIN_DIR/i3blocks-contrib"

echo "Atualizando repositório..."
git pull

# Criando diretório de configuração do i3blocks, se necessário
if [ ! -d "$HOME/.config/i3blocks" ]; then
    echo "Diretório de configuração do i3blocks não existe. Criando..."
    mkdir -p "$HOME/.config/i3blocks"
fi

# --- INÍCIO DA CORREÇÃO ---
# O i3blocks-contrib usa autotools, não Meson!
echo "Configurando i3blocks-contrib com autotools (configure/make)..."
./configure

echo "Compilando com make..."
make

echo "Instalando com make install..."
sudo make install
# --- FIM DA CORREÇÃO ---

# Limpeza
git reset --hard
git clean -fd

# Volta para o diretório principal
echo "Retornando para $MAIN_DIR"
cd "$MAIN_DIR"

#==================================================
# i3-layout-manager
#==================================================

# Garante que o repositório exista
if [ ! -d "$MAIN_DIR/i3-layout-manager" ]; then
    echo "Clonando o repositório do i3-layout-manager..."
    git clone https://github.com/klaxalk/i3-layout-manager.git "$MAIN_DIR/i3-layout-manager"
else
    echo "==> Repositório i3-layout-manager já existe."
fi

# Entra no diretório
echo "Entrando em $MAIN_DIR/i3-layout-manager..."
cd "$MAIN_DIR/i3-layout-manager"

echo "Atualizando repositório..."
git pull

# --- INÍCIO DA CORREÇÃO ---
# Este script é um executável Bash, não um pacote Python.
# As dependências dele (jq, rofi, vim, xdotool) já
# foram instaladas no bloco principal de 'apt install' no topo do script.

echo "Instalando o script 'layout_manager.sh' em /usr/local/bin..."
sudo cp layout_manager.sh /usr/local/bin/i3-layout-manager
sudo chmod +x /usr/local/bin/i3-layout-manager
# --- FIM DA CORREÇÃO ---

# Limpeza
git reset --hard
git clean -fd

# Volta para o diretório principal
echo "Retornando para $MAIN_DIR"
cd "$MAIN_DIR"

#==================================================
# zsh-syntax-highlighting
#==================================================
if [ ! -d "$MAIN_DIR/zsh-syntax-highlighting" ]; then
    echo "Clonando o repositório zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$MAIN_DIR/zsh-syntax-highlighting" && cd "$MAIN_DIR/zsh-syntax-highlighting"
else
    echo "==> Repositório zsh-syntax-highlighting já existe, atualizando..."
    cd "$MAIN_DIR/zsh-syntax-highlighting" && git pull
fi

# Define o diretório de plugins do ZSH (padrão oh-my-zsh)
ZSH_CUSTOM=${ZSH_CUSTOM:-"$HOME/.oh-my-zsh/custom"}/plugins
if [ ! -d "$ZSH_CUSTOM" ]; then
    mkdir -p "$ZSH_CUSTOM"
fi

# Linkando o plugin
ln -sf "$MAIN_DIR/zsh-syntax-highlighting" "$ZSH_CUSTOM/zsh-syntax-highlighting"

# Adicionando o plugin ao arquivo ~/.zshrc
if [ -f "$HOME/.zshrc" ] && ! grep -q 'zsh-syntax-highlighting' ~/.zshrc; then
    echo "Adicionando o plugin zsh-syntax-highlighting ao arquivo ~/.zshrc..."
    echo "plugins=( \$(plugins) zsh-syntax-highlighting )" >> ~/.zshrc
fi

# AVISO: source só funcionará para este script. O usuário precisa recarregar o zsh manualmente.
echo "==> AVISO: 'source ~/.zshrc' pode ser necessário no seu terminal."

# Limpeza
git reset --hard
git clean -fd
cd "$MAIN_DIR"

#==================================================
# tmux
#==================================================
if [ ! -d "$MAIN_DIR/tmux" ]; then
    echo "Clonando o repositório tmux..."
    git clone https://github.com/tmux/tmux.git "$MAIN_DIR/tmux" && cd "$MAIN_DIR/tmux"
else
    echo "==> Repositório tmux já existe, atualizando..."
    cd "$MAIN_DIR/tmux" && git pull
fi

./autogen.sh
./configure
make
sudo make install

# Limpeza
git reset --hard
git clean -fd
cd "$MAIN_DIR"

#==================================================
# tmuxinator
#==================================================
if [ ! -d "$MAIN_DIR/tmuxinator" ]; then
    echo "Clonando o repositório tmuxinator..."
    git clone https://github.com/tmuxinator/tmuxinator.git "$MAIN_DIR/tmuxinator" && cd "$MAIN_DIR/tmuxinator"
else
    echo "==> Repositório tmuxinator já existe, atualizando..."
    cd "$MAIN_DIR/tmuxinator" && git pull
fi

# --- INÍCIO DA CORREÇÃO ---
# Instalar dependências do Ruby (com sudo)
sudo gem install bundler
sudo bundle install

# Instalar o tmuxinator globalmente (com sudo)
sudo gem install tmuxinator
# --- FIM DA CORREÇÃO ---

# Limpeza
git reset --hard
git clean -fd
cd "$MAIN_DIR"

#==================================================
# fzf
#==================================================
if [ ! -d "$MAIN_DIR/fzf" ]; then
    echo "Clonando o repositório fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$MAIN_DIR/fzf" && cd "$MAIN_DIR/fzf"
else
    echo "==> Repositório fzf já existe, atualizando..."
    cd "$MAIN_DIR/fzf" && git pull
fi

# --- INÍCIO DA CORREÇÃO ---
echo "Instalando o fzf (não-interativo)..."
# Usa --all para uma instalação não-interativa completa
./install --all

# O script acima instala em $HOME/.fzf/bin
# Vamos criar um link simbólico para que o sistema o encontre
echo "Criando link simbólico para fzf em /usr/local/bin..."
sudo ln -sf "$HOME/.fzf/bin/fzf" /usr/local/bin/fzf
# --- FIM DA CORREÇÃO ---

# Verificando a instalação
if command -v fzf > /dev/null; then
    echo "fzf instalado com sucesso!"
else
    echo "Erro na instalação do fzf."
fi
cd "$MAIN_DIR"

#==================================================
# ranger
#==================================================
if [ ! -d "$MAIN_DIR/ranger" ]; then
    echo "Clonando o repositório ranger..."
    git clone https://github.com/ranger/ranger.git "$MAIN_DIR/ranger" && cd "$MAIN_DIR/ranger"
else
    echo "==> Repositório ranger já existe, atualizando..."
    cd "$MAIN_DIR/ranger" && git pull
fi

echo "Instalando dependências do ranger (pip)..."
sudo pip3 install -r requirements.txt --break-system-packages

echo "Instalando o ranger..."
sudo make install

if command -v ranger > /dev/null; then
    echo "ranger instalado com sucesso!"
else
    echo "Erro na instalação do ranger."
fi
cd "$MAIN_DIR"

#==================================================
# pandoc-goodies
#==================================================
if [ ! -d "$MAIN_DIR/pandoc-goodies" ]; then
    echo "Clonando o repositório pandoc-goodies..."
    git clone https://github.com/tajmone/pandoc-goodies.git "$MAIN_DIR/pandoc-goodies" && cd "$MAIN_DIR/pandoc-goodies"
else
    echo "==> Repositório pandoc-goodies já existe, atualizando..."
    cd "$MAIN_DIR/pandoc-goodies" && git pull
fi

echo "Adicionando os scripts do pandoc-goodies ao PATH (via .bashrc)..."
echo 'export PATH="$HOME/git/submodules/pandoc-goodies/scripts:$PATH"' >> ~/.bashrc

echo "==> AVISO: 'source ~/.bashrc' será necessário para usar o pandoc-goodies no seu terminal."
cd "$MAIN_DIR"

#==================================================
# brightnessctl
#==================================================

# Garante que o repositório exista
if [ ! -d "$MAIN_DIR/brightnessctl" ]; then
    echo "Clonando o repositório brightnessctl..."
    git clone https://github.com/Hummer12007/brightnessctl.git "$MAIN_DIR/brightnessctl"
else
    echo "==> Repositório brightnessctl já existe."
fi

# Entra no diretório
echo "Entrando em $MAIN_DIR/brightnessctl..."
cd "$MAIN_DIR/brightnessctl"

echo "Atualizando repositório..."
git pull

# --- INÍCIO DA CORREÇÃO ---
# Este projeto usa autotools (configure/make), NÃO Meson.
echo "Configurando com autotools..."
# O autogen.sh pode ser necessário se o 'configure' não existir
if [ ! -f "configure" ]; then
    ./autogen.sh
fi
./configure

echo "Compilando com make..."
make

echo "Instalando com make install..."
sudo make install
# --- FIM DA CORREÇÃO ---

# Verificando a instalação
if command -v brightnessctl > /dev/null; then
    echo "brightnessctl instalado com sucesso!"
else
    echo "Erro na instalação do brightnessctl."
fi

# Volta para o diretório principal
echo "Retornando para $MAIN_DIR"
cd "$MAIN_DIR"

#==================================================
# The Silver Searcher (ag)
#==================================================
echo "Verificando The Silver Searcher (ag)..."
if command -v ag >/dev/null 2>&1; then
    echo "O The Silver Searcher (ag) já está instalado."
else
    echo "O The Silver Searcher não foi encontrado. Instalando..."
    if [ ! -d "$MAIN_DIR/the_silver_searcher" ]; then
        git clone https://github.com/ggreer/the_silver_searcher.git "$MAIN_DIR/the_silver_searcher"
    fi
    cd "$MAIN_DIR/the_silver_searcher"
    git pull
    
    ./autogen.sh
    ./configure
    make
    sudo make install

    if command -v ag >/dev/null 2>&1; then
        echo "The Silver Searcher (ag) instalado com sucesso!"
    else
        echo "Erro na instalação do The Silver Searcher!"
    fi
fi
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

    # Garante que o repositório exista com a URL correta
    if [ ! -d "$MAIN_DIR/git-sync" ]; then
        echo "Clonando git-sync..."
        git clone https://github.com/AkashRajpurohit/git-sync.git "$MAIN_DIR/git-sync"
    fi
    
    # Entra no diretório
    cd "$MAIN_DIR/git-sync"
    git pull
    
    # Compila e instala
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

    # Garante que o repositório exista com a URL correta
    if [ ! -d "$MAIN_DIR/xkblayout-state" ]; then
        echo "Clonando xkblayout-state (fork nonpop)..."
        # --- A URL CORRETA ESTÁ AQUI ---
        git clone https://github.com/nonpop/xkblayout-state.git "$MAIN_DIR/xkblayout-state"
    fi
    
    # Entra no diretório
    echo "Entrando em $MAIN_DIR/xkblayout-state..."
    cd "$MAIN_DIR/xkblayout-state"
    git pull
    
    # Compila e instala (Este projeto usa 'make')
    echo "Compilando xkblayout-state..."
    make
    sudo make install

    # Força o shell a re-escanear o PATH
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

# Garante que o repositório exista
if [ ! -d "$MAIN_DIR/indicator-sound-switcher" ]; then
    echo "Clonando indicator-sound-switcher (fork 'yktoo')..."
    git clone https://github.com/yktoo/indicator-sound-switcher.git "$MAIN_DIR/indicator-sound-switcher"
fi

# Entra no diretório
echo "Entrando em $MAIN_DIR/indicator-sound-switcher..."
cd "$MAIN_DIR/indicator-sound-switcher"
git pull

# --- INÍCIO DA CORREÇÃO ---
# Limpa o diretório 'build' antigo da tentativa falhada de 'cmake'
echo "Limpando diretório 'build' antigo..."
sudo rm -rf build

# Instala com pip. Agora deve funcionar,
# pois o 'gettext' (instalado via apt) está disponível
# para o setup.py construir os ficheiros .mo
echo "Instalando com pip (setup.py)..."
sudo pip3 install . --break-system-packages
# --- FIM DA CORREÇÃO ---

# Força o shell a re-escanear o PATH
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

# --- INÍCIO DA CORREÇÃO ---
# Tenta carregar o módulo 'hid_apple', caso ele não esteja ativo.
# O -q (quiet) suprime erros caso o módulo não exista.
echo "Tentando carregar o módulo 'hid_apple'..."
sudo modprobe -q hid_apple

# Define o arquivo de parâmetro
FNMODE_FILE="/sys/module/hid_apple/parameters/fnmode"

# Verifica se o arquivo de controle do 'hid_apple' REALMENTE existe
if [ -f "$FNMODE_FILE" ]; then
    echo "Módulo 'hid_apple' encontrado. Aplicando fnmode=2..."
    
    # 2 = Teclas F1-F12 são o padrão.
    echo 2 | sudo tee "$FNMODE_FILE"

    # Torna a mudança permanente
    echo "Tornando a configuração do Keychron permanente..."
    echo "options hid_apple fnmode=2" | sudo tee /etc/modprobe.d/hid_apple.conf

    echo "Configuração do Keychron K2 (hid_apple) aplicada com sucesso!"
    echo "AVISO: Você precisará rodar 'sudo update-initramfs -u' ou reiniciar o PC."

else
    echo "AVISO: O arquivo '$FNMODE_FILE' não foi encontrado."
    echo "O seu kernel pode já usar um driver dedicado (hid_keychron)."
    echo "Esta etapa foi pulada, pois provavelmente não é necessária."
fi
# --- FIM DA CORREÇÃO ---

cd "$MAIN_DIR"

#==================================================
# Configuração do Vim & vim-plug
#==================================================

# --- INÍCIO DA CORREÇÃO ---
# Esta secção usa SCRIPT_DIR (definido no topo do script)
# para encontrar 'dotvim' e 'dotvimrc' ao lado do script .sh

# Define a fonte dos seus dotfiles do Vim
VIM_CONFIG_SOURCE="$SCRIPT_DIR" 

if [ ! -d "$VIM_CONFIG_SOURCE/dotvim" ] || [ ! -f "$VIM_CONFIG_SOURCE/dotvimrc" ]; then
    echo "AVISO: 'dotvim' ou 'dotvimrc' não encontrados em $VIM_CONFIG_SOURCE."
    echo "Pulando a configuração do Vim. O PlugInstall manual será necessário."
else
    echo "Configurações do Vim encontradas em $VIM_CONFIG_SOURCE."
    
    # 1. Linkar seu .vimrc
    ln -sf "$VIM_CONFIG_SOURCE/dotvimrc" "$HOME/.vimrc"
    echo "Linkado: $VIM_CONFIG_SOURCE/dotvimrc -> ~/.vimrc"
    
    # 2. Linkar sua pasta .vim
    ln -sf "$VIM_CONFIG_SOURCE/dotvim" "$HOME/.vim"
    echo "Linkado: $VIM_CONFIG_SOURCE/dotvim -> ~/.vim"

    # 3. Agora, instalar o vim-plug DENTRO da estrutura linkada
    echo "Instalando o vim-plug..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    if [ ! -f ~/.vim/autoload/plug.vim ]; then
        echo "Falha na instalação do vim-plug." && exit 1
    else
        echo "vim-plug instalado com sucesso!"
    fi

    # 4. Agora, rodar o PlugInstall
    echo "Instalando plugins definidos no seu .vimrc..."
    vim +PlugInstall +qall
    echo "Instalação de plugins do Vim concluída."
fi
# --- FIM DA CORREÇÃO ---


#==================================================
# Configuração de Links Simbólicos (Dotfiles)
#==================================================

# --- INÍCIO DA CORREÇÃO ---
# Esta secção usa SCRIPT_DIR para encontrar 'doti3' ao lado do script .sh
I3_CONFIG_SOURCE="$SCRIPT_DIR/doti3"

if [ -d "$I3_CONFIG_SOURCE" ]; then
    echo "Diretório doti3 encontrado em: $I3_CONFIG_SOURCE"
    echo "Criando link simbólico para a configuração do i3..."
    
    if [ ! -e "$HOME/.i3" ]; then
        ln -sf "$I3_CONFIG_SOURCE" "$HOME/.i3"
        echo "Linkado: $I3_CONFIG_SOURCE -> ~/.i3"
    fi

    # Garante que o diretório ~/.i3 exista para o cp
    mkdir -p "$HOME/.i3"

    echo "Copiando os arquivos de configuração do i3 (de doti3)..."
    if [ -f "$I3_CONFIG_SOURCE/config_git" ]; then
        cp "$I3_CONFIG_SOURCE/config_git" "$HOME/.i3/config"
    fi
    if [ -f "$I3_CONFIG_SOURCE/i3blocks.conf_git" ]; then
        cp "$I3_CONFIG_SOURCE/i3blocks.conf_git" "$HOME/.i3/i3blocks.conf"
    fi
    
    # Confere os scripts de i3blocks DENTRO de $MAIN_DIR
    # (como você confirmou)
    echo "Copiando scripts do i3blocks (de $MAIN_DIR)..."
    if [ -f "$MAIN_DIR/i3blocks/wifi_git" ]; then
        cp "$MAIN_DIR/i3blocks/wifi_git" "$MAIN_DIR/i3blocks/wifi"
    fi
    if [ -f "$MAIN_DIR/i3blocks/battery_git" ]; then
        cp "$MAIN_DIR/i3blocks/battery_git" "$MAIN_DIR/i3blocks/battery"
    fi
    
else
    echo "AVISO: Diretório 'doti3' não encontrado em $SCRIPT_DIR. Pulando configs do i3."
fi
# --- FIM DA CORREÇÃO ---

# Verificação final do lightdm
if ! dpkg -l | grep -q lightdm; then
    echo "AVISO: lightdm não foi instalado corretamente!"
else
    echo "lightdm instalado com sucesso!"
fi

echo "=============================================="
echo "Instalação e configuração concluídas!"
echo "AVISOS IMPORTANTES:"
echo "1. Configure manualmente seus plugins do Vim (veja aviso no script)."
echo "2. Certifique-se que seu repositório 'doti3' está em $MAIN_DIR."
echo "3. Reinicie seu shell (ou 'source ~/.bashrc' / 'source ~/.zshrc') para aplicar mudanças de PATH."
echo "=============================================="

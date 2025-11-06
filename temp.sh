tu vai ter uma unica tarefa. eu tenho um arquivo.sh que configura e instala tudo no meu sistema. tu vai fazer o seguinte: verifique TODO o codigo e veja se tem algum erro e se vai rodar direto. depois organize o codigo, coloque todas as instalacoes de dependencias apt tals no inicio do codigo com o setup la. E padronizar o layout dos noves de acordo com o que esta sendo instalado, com esse exemplo:

#==================================================

# i3 (Airblader)

#==================================================


segue o codigo completo:

#!/bin/bash

# Instalando dependências necessárias
sudo apt update
sudo apt install -y git meson ninja-build build-essential \
  libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev \
  libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev \
  libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev \
  libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev libxcb-shape0-dev \
  xcb-proto pkg-config libglib2.0-dev libev-dev lightdm make

MAIN_DIR=~/git/submodules
mkdir -p "$MAIN_DIR"

# Verificando se o diretório ~/git existe
if [ ! -d "$MAIN_DIR" ]; then
  echo "Diretório $MAIN_DIR não existe. Criando..."
  mkdir -p "$MAIN_DIR"  # Cria o diretório ~/git se não existir
  cd "$MAIN_DIR"
else
  echo "Diretório $MAIN_DIR já existe."
  cd "$MAIN_DIR"
fi

set -e

# Instalando i3 (Airblader)
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
cd ..

# Instalando i3blocks
if [ ! -d "i3blocks" ]; then
    echo "Clonando o repositório do i3blocks..."
    git clone https://github.com/vivien/i3blocks.git i3blocks && cd i3blocks
else
    echo "==> Repositório i3blocks já existe, atualizando..."
    cd i3blocks && git pull
fi

meson setup build --prefix=/usr
ninja -C build
sudo ninja -C build install
cd ..

# Instalando i3blocks-contrib
if [ ! -d "i3blocks-contrib" ]; then
    echo "Clonando o repositório do i3blocks-contrib..."
    git clone https://github.com/vivien/i3blocks-contrib.git i3blocks-contrib && cd i3blocks-contrib
else
    echo "==> Repositório i3blocks-contrib já existe, atualizando..."
    cd i3blocks-contrib && git pull
fi

# Criando diretório de configuração do i3blocks, se necessário
if [ ! -d "$HOME/.config/i3blocks" ]; then
  echo "Diretório de configuração do i3blocks não existe. Criando..."
  mkdir -p "$HOME/.config/i3blocks"
fi

# Gerando configuração do i3blocks
./autogen.sh
./configure

# Preparar o Meson build
if [ ! -d build ]; then
    meson setup build
fi

# Compilar usando o Ninja
ninja -C build

# Instalar
sudo ninja -C build install

# Limpeza após a compilação
git reset --hard
git clean -fd
cd ..

# Instalar outras dependências úteis
sudo apt-get -y install xbacklight alsa-utils pulseaudio feh arandr \
    lxappearance thunar rofi compton systemd i3lock jq

# Opcional: Verificar se o lightdm foi instalado corretamente
if ! dpkg -l | grep -q lightdm; then
    echo "lightdm não foi instalado corretamente!"
else
    echo "lightdm instalado com sucesso!"
fi

# Criando o link simbólico para a configuração do i3
if [ ! -e "$HOME/.i3" ]; then
    ln -sf "$MAIN_DIR/doti3" "$HOME/.i3"
fi

# Copiando os arquivos de configuração do i3
cp "$MAIN_DIR/doti3/config_git" "$HOME/.i3/config"
cp "$MAIN_DIR/doti3/i3blocks.conf_git" "$HOME/.i3/i3blocks.conf"
cp "$MAIN_DIR/i3blocks/wifi_git" "$MAIN_DIR/i3blocks/wifi"
cp "$MAIN_DIR/i3blocks/battery_git" "$MAIN_DIR/i3blocks/battery"

# Instalando o xkb-layout-state
cd "$MAIN_DIR/../../submodules/xkblayout-state/"
make
sudo ln -sf "$MAIN_DIR/../../submodules/xkblayout-state/xkblayout-state" /usr/bin/xkblayout-state
cd "$MAIN_DIR"

#i3-layout-manager
if [ ! -d "$MAIN_DIR/i3-layout-manager" ]; then
    echo "Clonando o repositório do i3-layout-manager..."
    git clone https://github.com/klaxalk/i3-layout-manager.git "$MAIN_DIR/i3-layout-manager" && cd "$MAIN_DIR/i3-layout-manager"
else
    echo "==> Repositório i3-layout-manager já existe, atualizando..."
    cd "$MAIN_DIR/i3-layout-manager" && git pull
fi

# Instalando dependências necessárias
sudo apt-get install -y \
    libxcb-xinerama0-dev libev-dev libxkbcommon-dev \
    libyajl-dev libxcb-util0-dev libstartup-notification0-dev

# Preparando o build com Meson
if [ ! -d build ]; then
    meson setup build
fi

# Compilando com Ninja
ninja -C build

# Instalando
sudo ninja -C build install

# Limpeza após a compilação
git reset --hard
git clean -fd
cd ..

#zsh-syntax-highlighting
if [ ! -d "$MAIN_DIR/zsh-syntax-highlighting" ]; then
    echo "Clonando o repositório zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$MAIN_DIR/zsh-syntax-highlighting" && cd "$MAIN_DIR/zsh-syntax-highlighting"
else
    echo "==> Repositório zsh-syntax-highlighting já existe, atualizando..."
    cd "$MAIN_DIR/zsh-syntax-highlighting" && git pull
fi

ZSH_CUSTOM="$ZSH_CUSTOM"/plugins
if [ ! -d "$ZSH_CUSTOM" ]; then
    mkdir -p "$ZSH_CUSTOM"
fi

# Linkando o plugin para o diretório de plugins do Zsh
ln -sf "$MAIN_DIR/zsh-syntax-highlighting" "$ZSH_CUSTOM/zsh-syntax-highlighting"

# Verificando se o arquivo de configuração do Zsh existe e adicionando o plugin ao arquivo ~/.zshrc
if ! grep -q 'zsh-syntax-highlighting' ~/.zshrc; then
    echo "Adicionando o plugin zsh-syntax-highlighting ao arquivo ~/.zshrc..."
    echo "plugins=( \$(plugins) zsh-syntax-highlighting )" >> ~/.zshrc
fi

# Recarregando o Zsh para aplicar as mudanças
source ~/.zshrc

# Limpeza após a instalação
git reset --hard
git clean -fd
cd ..

# Atualizar os pacotes e instalar dependências
sudo apt update
sudo apt install -y git build-essential libevent-dev libncurses5-dev \
    pkg-config automake autoconf

#tmux
if [ ! -d "$MAIN_DIR/tmux" ]; then
    echo "Clonando o repositório tmux..."
    git clone https://github.com/tmux/tmux.git "$MAIN_DIR/tmux" && cd "$MAIN_DIR/tmux"
else
    echo "==> Repositório tmux já existe, atualizando..."
    cd "$MAIN_DIR/tmux" && git pull
fi

# Preparando o ambiente para compilar o tmux
./autogen.sh  # Executa o autogen para gerar o configure
./configure   # Configura o tmux com as opções do sistema
make          # Compila o tmux

# Instalando o tmux
sudo make install

# Limpeza após a compilação
cd ..
git reset --hard
git clean -fd

echo "tmux instalado com sucesso!"

#tmuxinator
if [ ! -d "$MAIN_DIR/tmuxinator" ]; then
    echo "Clonando o repositório tmuxinator..."
    git clone https://github.com/tmuxinator/tmuxinator.git "$MAIN_DIR/tmuxinator" && cd "$MAIN_DIR/tmuxinator"
else
    echo "==> Repositório tmuxinator já existe, atualizando..."
    cd "$MAIN_DIR/tmuxinator" && git pull
fi

# Instalar dependências do Ruby (se não tiver gem)
gem install bundler
bundle install

# Instalar o tmuxinator globalmente
gem install tmuxinator

# Limpeza após a instalação
git reset --hard
git clean -fd
cd ..

#fzf
if [ ! -d "$MAIN_DIR/fzf" ]; then
    echo "Clonando o repositório fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$MAIN_DIR/fzf" && cd "$MAIN_DIR/fzf"
else
    echo "==> Repositório fzf já existe, atualizando..."
    cd "$MAIN_DIR/fzf" && git pull
fi

# Instalando o fzf
echo "Instalando o fzf..."
./install --bin

# Verificando a instalação
if command -v fzf > /dev/null; then
    echo "fzf instalado com sucesso!"
else
    echo "Erro na instalação do fzf."
fi
cd ..

# Atualizar pacotes
sudo apt update
sudo apt install -y git python3-pip

#ranger
if [ ! -d "$MAIN_DIR/ranger" ]; then
    echo "Clonando o repositório ranger..."
    git clone https://github.com/ranger/ranger.git "$MAIN_DIR/ranger" && cd "$MAIN_DIR/ranger"
else
    echo "==> Repositório ranger já existe, atualizando..."
    cd "$MAIN_DIR/ranger" && git pull
fi

# Instalando dependências do ranger
echo "Instalando dependências do ranger..."
pip3 install -r requirements.txt

# Instalando o ranger
echo "Instalando o ranger..."
sudo make install

# Verificando a instalação
if command -v ranger > /dev/null; then
    echo "ranger instalado com sucesso!"
else
    echo "Erro na instalação do ranger."
fi
cd ..

# Atualizar pacotes
sudo apt update
sudo apt install -y git pandoc

# Clonando o repositório pandoc-goodies
if [ ! -d "$MAIN_DIR/pandoc-goodies" ]; then
    echo "Clonando o repositório pandoc-goodies..."
    git clone https://github.com/tajmone/pandoc-goodies.git "$MAIN_DIR/pandoc-goodies" && cd "$MAIN_DIR/pandoc-goodies"
else
    echo "==> Repositório pandoc-goodies já existe, atualizando..."
    cd "$MAIN_DIR/pandoc-goodies" && git pull
fi

# Instalando o pandoc-goodies
echo "Instalando pandoc-goodies..."
# No caso do pandoc-goodies, a instalação basicamente é garantir que o repositório está no lugar correto, 
# pois ele já contém scripts prontos para uso.

# Adicionando o diretório de scripts ao PATH
echo "Adicionando os scripts do pandoc-goodies ao PATH..."
echo 'export PATH="$HOME/git/submodules/pandoc-goodies/scripts:$PATH"' >> ~/.bashrc

# Recarregando o .bashrc para aplicar mudanças
source ~/.bashrc

# Verificando se o pandoc-goodies está acessível
if command -v pandoc-goodies > /dev/null; then
    echo "pandoc-goodies instalado com sucesso!"
else
    echo "Erro na instalação do pandoc-goodies."
fi
cd ..

#brightnessctl
if [ ! -d "$MAIN_DIR/brightnessctl" ]; then
    echo "Clonando o repositório brightnessctl..."
    git clone https://github.com/HuskyDG/brightnessctl.git "$MAIN_DIR/brightnessctl" && cd "$MAIN_DIR/brightnessctl"
else
    echo "==> Repositório brightnessctl já existe, atualizando..."
    cd "$MAIN_DIR/brightnessctl" && git pull
fi

# Usando Meson para configurar o build
meson setup build

# Compilando com Ninja
ninja -C build

# Instalando
sudo ninja -C build install

# Verificando a instalação
if command -v brightnessctl > /dev/null; then
    echo "brightnessctl instalado com sucesso!"
else
    echo "Erro na instalação do brightnessctl."
fi
cd ..

# Atualizar o sistema e instalar dependências
echo "Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar o Vim
echo "Instalando o Vim..."
sudo apt install -y vim

# Verificar se o Vim foi instalado corretamente
echo "Verificando a instalação do Vim..."
vim --version || { echo "Falha na instalação do Vim."; exit 1; }

# Instalar o vim-plug (gerenciador de plugins para o Vim)
echo "Instalando o vim-plug..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Verificar se o vim-plug foi instalado corretamente
echo "Verificando a instalação do vim-plug..."
if [ -f ~/.vim/autoload/plug.vim ]; then
  echo "vim-plug instalado com sucesso!"
else
  echo "Falha na instalação do vim-plug." && exit 1
fi

# Adicionar configuração inicial do vim-plug no .vimrc
echo "Configurando o vim-plug no .vimrc..."
if ! grep -q "plug 'junegunn/vim-plug'" ~/.vimrc; then
  cat <<EOL >> ~/.vimrc
" Configuração do vim-plug
call plug#begin('~/.vim/plugged')

" Plugins serão carregados a partir da lista
EOL
  echo ".vimrc configurado com vim-plug!"
else
  echo ".vimrc já contém a configuração do vim-plug."
fi

# Define o caminho do diretório
DIR="$HOME/git/submodules/appconfig"

# Verifica se o diretório existe
if [ ! -d "$DIR" ]; then
  echo "Diretório $DIR não existe. Criando..."
  mkdir -p "$DIR"
fi

# Define o caminho completo do arquivo plugin_list.txt
PLUGIN_LIST="$DIR/plugin_list.txt"

# Cria o arquivo plugin_list.txt com a lista de plugins
echo "Criando o arquivo plugin_list.txt em $PLUGIN_LIST..."

cat <<EOL > "$PLUGIN_LIST"
ctrlp.vim
tmuxline.vim
vim-glsl.vim
deoplete.vim
ultisnips.vim
vim-multiple-cursors.vim
GoldenView.vim
vim-airline.vim
vim-ros.vim
mail.vim
vim-argwrap.vim
vim-startify_git.vim
neomake.vim
vim-clang-format_git.vim
vimtex.vim
nerdtree.vim
vim-commentary.vim
vim-tmux-runner.vim
quick-scope.vim
vim-conflicted.vim
vimwiki_git.vim
syntastic.vim
vim-cpp-enhanced-highlight.vim
youcompleteme.vim
tagbar.vim
vim-easy-align.vim
EOL

echo "Arquivo plugin_list.txt criado com sucesso em $PLUGIN_LIST."


# Caminho para o arquivo com a lista de plugins (modifique conforme o seu diretório)
PLUGIN_LIST_PATH="$HOME/git/submodules/appconfig/plugin_list.txt"

# Verificar se o arquivo com os plugins existe
if [ ! -f "$PLUGIN_LIST_PATH" ]; then
  echo "Arquivo de plugins não encontrado: $PLUGIN_LIST_PATH"
  exit 1
fi

# Adicionar os plugins no .vimrc
echo "Adicionando plugins ao .vimrc..."
while IFS= read -r plugin; do
  # Adiciona cada plugin ao arquivo .vimrc
  echo "Plug 'pluginconfig/$plugin'" >> ~/.vimrc
done < "$PLUGIN_LIST_PATH"

# Finaliza a configuração no .vimrc
echo "Finalizando a configuração do .vimrc..."
cat <<EOL >> ~/.vimrc
call plug#end()

EOL

# Verificar se os plugins foram adicionados corretamente
echo "Plugins adicionados ao .vimrc. O conteúdo do arquivo é:"
cat ~/.vimrc

# Instalar os plugins automaticamente no Vim
echo "Instalando os plugins no Vim..."
vim +PlugInstall +qall

# Finalizar o processo
echo "Plugins instalados com sucesso. Tudo pronto!"

#The Silver Searcher
echo "Instalando dependências para o The Silver Searcher (ag)..."
sudo apt-get update
sudo apt-get install -y build-essential automake pkg-config libpcre3 libpcre3-dev zlib1g-dev

# Verifica se o ag (The Silver Searcher) já está instalado
if command -v ag >/dev/null 2>&1; then
    echo "O The Silver Searcher (ag) já está instalado."
else
    # Baixando o repositório do ag
    echo "O The Silver Searcher não foi encontrado. Instalando..."
    cd "$MAIN_DIR"
    git clone https://github.com/ggreer/the_silver_searcher.git

    # Instalando
    cd the_silver_searcher
    ./build.sh

    # Verificando se a instalação foi bem-sucedida
    if command -v ag >/dev/null 2>&1; then
        echo "The Silver Searcher (ag) instalado com sucesso!"
    else
        echo "Erro na instalação do The Silver Searcher!"
    fi
fi

#git-sync
echo "Instalando dependências para o git-sync..."
sudo apt-get update
sudo apt-get install -y golang

# Verifica se o git-sync já está instalado
if command -v git-sync >/dev/null 2>&1; then
    echo "O git-sync já está instalado."
else
    # Baixando o repositório do git-sync
    echo "O git-sync não foi encontrado. Instalando..."
    
    # Configura o GOPATH (caso não esteja configurado)
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin

    # Baixando e compilando o git-sync
    cd "$MAIN_DIR"
    git clone https://github.com/kohkohk/git-sync.git
    cd git-sync

    # Compilando o git-sync
    go build -o git-sync

    # Verificando se a instalação foi bem-sucedida
    if command -v git-sync >/dev/null 2>&1; then
        echo "git-sync instalado com sucesso!"
    else
        echo "Erro na instalação do git-sync!"
    fi
fi

#xkblayout-state
echo "Instalando dependências para o xkblayout-state..."
sudo apt-get update
sudo apt-get install -y build-essential libx11-dev libxkbfile-dev

# Verifica se o xkblayout-state já está instalado
if command -v xkblayout-state >/dev/null 2>&1; then
    echo "O xkblayout-state já está instalado."
else
    # Baixando o repositório do xkblayout-state
    echo "O xkblayout-state não foi encontrado. Instalando..."
    
    # Clonando o repositório
    cd "$MAIN_DIR"
    git clone https://github.com/pln/xkblayout-state.git
    cd xkblayout-state

    # Compilando o xkblayout-state
    make

    # Instalando o xkblayout-state
    sudo make install

    # Verificando se a instalação foi bem-sucedida
    if command -v xkblayout-state >/dev/null 2>&1; then
        echo "xkblayout-state instalado com sucesso!"
    else
        echo "Erro na instalação do xkblayout-state!"
    fi
fi

#indicator-sound-switcher
echo "Instalando dependências para o indicator-sound-switcher..."
sudo apt-get update
sudo apt-get install -y build-essential libgtk-3-dev libappindicator3-dev \
  libcanberra-gtk3-dev gnome-shell-extension-appindicator

# Baixando o repositório do indicator-sound-switcher
echo "Baixando o indicator-sound-switcher..."
cd "$MAIN_DIR"
git clone https://github.com/Maartenba/indicator-sound-switcher.git
cd indicator-sound-switcher

# Instalando o indicador
echo "Instalando o indicator-sound-switcher..."
make
sudo make install

# Verificando se o indicator-sound-switcher foi instalado com sucesso
if command -v indicator-sound-switcher >/dev/null 2>&1; then
    echo "indicator-sound-switcher instalado com sucesso!"
else
    echo "Erro na instalação do indicator-sound-switcher!"
fi

# Instala as dependências necessárias
echo "Instalando dependências para as teclas de função do Keychron K2..."
sudo apt-get update
sudo apt-get install -y xbindkeys xdotool

# Baixando o script para configuração das teclas de função
echo "Baixando o script de configuração para teclas de função do Keychron K2..."
cd "$MAIN_DIR"
git clone https://github.com/dundus/keychron-k2-function-keys-linux.git
cd keychron-k2-function-keys-linux

# Definindo as configurações para as teclas de função
echo "Configurando teclas de função do Keychron K2..."
cp config/xbindkeysrc ~/.xbindkeysrc

# Criando um arquivo para iniciar o xbindkeys automaticamente na inicialização
echo "Adicionando xbindkeys para iniciar na inicialização..."
echo "xbindkeys" >> ~/.xprofile

# Adicionando configurações específicas para teclas de função
echo "Configurações para teclas de função do Keychron K2 aplicadas com sucesso!"

# Iniciando o xbindkeys
xbindkeys

# Verificando se o xbindkeys foi iniciado corretamente
if pgrep -x "xbindkeys" > /dev/null; then
    echo "xbindkeys está funcionando corretamente."
else
    echo "Erro ao iniciar xbindkeys!"
fi


echo "Instalação completa!"

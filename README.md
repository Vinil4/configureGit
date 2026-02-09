# configureGit
automatiza a configuracao do git no pc.

**configurar somente git**
```bash
sudo apt install -y git &&
mkdir -p ~/git &&
cd ~/git &&
git clone https://github.com/Vinil4/configureGit.git &&
cd ~/git/configureGit &&
chmod +x config.sh &&
./config.sh
```

**configurar todo sistema**\
Instala as dependencias, configura toda a interface com o i3, VIM e tmux.\
Testado somente no ubuntu 24.02.
```bash
mkdir -p ~/git &&
cd ~/git &&
git clone git@github.com:Vinil4/configureGit.git &&
cd ~/git/configureGit &&
chmod +x setup-linux.sh &&
chmod +x setup-environment.sh &&
./setup-linux.sh &&
./setup-environment.sh
```

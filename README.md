# configureGit
automatiza a configuracao do git no pc.\

**configurar somente git**\
```bash
mkdir -p ~/git &&
cd ~/git &&
git clone https://github.com/Vinil4/configureGit.git &&
cd ~/git/configureGit &&
chmod +x config.sh &&
./config.sh
```

**configurar todo sistema**\
Instala as dependencias, configura toda a interface com o i3 e instalao ROS 2 Jazzy.\
Testado somente no ubuntu 24.02.\
```bash
mkdir -p ~/git &&
cd ~/git &&
git clone https://github.com/Vinil4/configureGit.git &&
cd ~/git/configureGit &&
chmod +x linux-extras.sh &&
chmod +x throws.sh &&
./linux-extras.sh &&
./throws.sh
```

# configureGit
automatiza a configuracao do git no pc.

**configurar somente git**
```bash
mkdir -p ~/git &&
cd ~/git &&
git clone https://github.com/Vinil4/configureGit.git &&
cd ~/git/configureGit-main &&
chmod +x config.sh &&
./config.sh
```

**configurar tado sistema**
```bash
mkdir -p ~/git &&
cd ~/git &&
git clone https://github.com/Vinil4/configureGit.git &&
cd ~/git/configureGit-main &&
chmod +x config.sh &&
chmod +x linux-extras.sh &&
chmod +x throws.sh &&
./config.sh &&
./linux-extras.sh &&
./throws.sh
```

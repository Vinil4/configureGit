# configureGit
automatiza a configuracao do git no pc.

**configurar somente git**
```bash
mkdir -p ~/git &&
cd ~/git &&
git clone https://github.com/Vinil4/configureGit.git &&
cd ~/git/configureGit &&
chmod +x config.sh &&
./config.sh
```

**configurar todo sistema**
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

# Script déploiement Centreon pour Wazo/Xivo

This script has been writed by Kévin Perez for AtConnect Anglet

[![asciicast](http://www.atconnect.net/images/header/logo.png)


## Compatible with Debian 7/8/9 only.
#### Need Bash 4.2 at least to run.

# Step 1 - Run update and install git
```
apt-get update && apt-get install git-core -y && apt-get install curl -y

```
# Step 2 - Clone the repository and install it
```
cd /tmp
git clone https://github.com/AtConnect/ScriptWazoXivoDeploiement
cd ScriptWazoXivoDeploiement
chmod a+x lancercescriptsurwazoxivo.sh
./lancercescriptsurwazoxivo.sh
```


## Versions
- **2.5** Kévin Perez  
  - *Fix:* `ssl` enable and force ssl
  - *Fix:* `openssl` install to solve an error of ssl on certain system
- **2.0** Kévin Perez
  - *New:* New design
  - *Fix:* `grammar error` in command_nrpe  
  - *Fix:* Stop the script if `Debian 6`
  - *Fix:* Stop the script if a `past install` has been runned
- **1.0** Kévin Perez
  - *New:* Repository deleted

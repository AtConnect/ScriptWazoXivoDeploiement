![logo](http://www.atconnect.net/images/header/logo.png)
# ScriptWazoXivoDeploiement
### Script de deploiement pour Atconnect pour Debian 7/8/9
### Le but est d'installer et configurer NRPE et NAGIOS afin de pouvoir communiquer avec Centreon.

# How to Install :
### Step 1 :
```
apt-get update && apt-get install git-core -y
```
### Step 2 :
```

cd /tmp
git clone https://github.com/AtConnect/ScriptWazoXivoDeploiement ScriptWazoXivoDeploiement
cd ScriptWazoXivoDeploiement
chmod a+x lancercescriptsurwazoxivo.sh && ./lancercescriptsurwazoxivo.sh
```

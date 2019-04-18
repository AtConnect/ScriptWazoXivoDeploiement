# ScriptWazoXivoDeploiement
# Script de deploiement pour Atconnect pour Debian 9/8
# Le but est d'installer et configurer NRPE et NAGIOS afin de pouvoir communiquer avec Centreon.

# How to Install :
# Step 1 :
```
apt-get update && apt-get install git-core -y
```
# Step 2 :
```

cd /tmp
git clone https://github.com/AtConnect/ScriptWazoXivoDeploiement ScriptWazoXivoDeploiement
cd ScriptWazoXivoDeploiement
chmod a+x lancercescriptsurwazoxivo.sh && ./lancercescriptsurwazoxivo.sh
```

# Script déploiement Centreon pour Wazo/Xivo

A Bash function to run tasks in parallel and display pretty output as they complete.

[![asciicast](https://asciinema.org/a/34219.png)](https://asciinema.org/a/34219)


## Compatible with Debian 7/8/9 only.
### Need Bash 4.2 at least to run.

# Step 1 - Run update and install git
```
apt-get update && apt-get install git -y && apt-get install curl -y

```
# Step 2 - Clone the repository and install it
```
cd /tmp
git clone https://github.com/AtConnect/ScriptWazoXivoDeploiement
cd ScriptWazoXivoDeploiement
chmod a+x lancercescriptsurwazoxivo.sh
./lancercescriptsurwazoxivo.sh
```

- **2.0**
  - *Fix:* `grammar error` in command_nrpe
  - *Fix:* New design
  - *Fix:* Stop the script if Debian 6
  - *Fix:* Stop the script if a past install has been runned
- **1.0**
  - *New:* Repository deleted

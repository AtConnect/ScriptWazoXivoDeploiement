#!/usr/bin/env bash

set -e -o pipefail

#Update of the system only if update has been run without problem
clear
VERSION=$(cat /etc/debian_version)
if [[ "$VERSION" = 6.* ]]; then
	 exit 1;
fi

function CheckVersion(){
	VERSION=$(cat /etc/debian_version)
	if [[ "$VERSION" = 6.* ]]; then
		exit 1
	fi

}
function CheckPastInstall(){
	FILE="/usr/local/nagios/etc/command_nrpe.cfg"
	FILE2="/usr/local/nagios/etc/nrpe.cfg"
	if [[ -f $FILE ]] || [[ -f $FILE2 ]]; then
	    exit 1
	fi
}


# shellcheck source=concurrent.lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/concurrent.lib.sh"

success() {
    local args=(
    	- "Checking version of the system"                 CheckVersion\
    	- "The script has been runned in the past"         CheckPastInstall\
        - "Updating System"                                UpdateSystem\
        - "Downloading NRPE"                               DownloadNRPE\
        - "Installation of NRPE"                           InstallNRPE\
        - "Installation of IPTables"                       InstallIptables\
        - "Configuration of NRPE"                          ConfigNRPE\
        - "Installation of NRPE Plugins"                   NRPEPlugins\
        - "Configuration of NRPE Plugins"                  ConfigNRPEPlugins\
        - "Configuration of Sudoers"                       ConfSudoers\
        - "Copying Scripts for Centreon"                   CopyScripts\
        - "End of Installation"                            End\
        --sequential
        
    )

    concurrent "${args[@]}"
}



function UpdateSystem(){
	echo "Update System" >> logs
	apt-get update >> logs
	echo "Install of apps" >> logs	
	apt-get install autoconf -y >> logs
	apt-get install automake -y >> logs
	apt-get install gcc -y >> logs
	apt-get install libc6 -y >> logs
	apt-get install libmcrypt-dev -y >> logs
	apt-get install make -y >> logs
	apt-get install libssl-dev -y >> logs
	apt-get install wget -y >> logs
	apt-get install expect -y >> logs
	apt-get install htop -y >> logs
	apt-get install iotop -y >> logs
	apt-get install openssl -y >> logs
}

function DownloadNRPE(){
	cd /tmp || exit 1
	wget --no-check-certificate -q -O nrpe.tar.gz https://github.com/NagiosEnterprises/nrpe/archive/nrpe-3.2.1.tar.gz >> logs
	tar xzf nrpe.tar.gz >> logs
	cd /tmp/nrpe-nrpe-3.2.1/
}

function InstallNRPE(){
	echo "Install BINARIES and more" >> logs
	cd /tmp/nrpe-nrpe-3.2.1/
	./configure --enable-command-args --enable-ssl
	make all >>logs
	make install-groups-users >> logs
	make install >> logs
	make install-config >> logs
	echo >> /etc/services
	echo '# Nagios services' >> /etc/services
	echo 'nrpe    5666/tcp' >> /etc/services
	
	if [[ "$VERSION" = 7.* ]]; then
		make install-init >> logs
		update-rc.d nrpe defaults >> logs
	elif [[ "$VERSION" = 8.* ]]; then	
		make install-init >> logs
		systemctl enable nrpe.service >> logs
	elif [[ "$VERSION" = 9.* ]]; then
		make install-init >> logs
		systemctl enable nrpe.service >> logs
	else
		 exit 1;
	fi
}

function InstallIptables(){
	echo "Install Iptables rules" >> logs
	iptables -I INPUT -p tcp --destination-port 5666 -j ACCEPT
	echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
	echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
	apt-get -y install iptables-persistent >> logs	
}

function ConfigNRPE(){
	sed -i -r 's/.*allowed_hosts=127.0.0.1.*/allowed_hosts=127.0.0.1,::1,195.135.72.13/g' /usr/local/nagios/etc/nrpe.cfg
	sed -i -r 's/.*dont_blame_nrpe.*/dont_blame_nrpe=1/g' /usr/local/nagios/etc/nrpe.cfg
	echo "include=/usr/local/nagios/etc/command_nrpe.cfg" >> /usr/local/nagios/etc/nrpe.cfg
	
}

function NRPEPlugins(){
	echo "Install NRPE plugins for NRPE" >> logs
	apt-get install bc -y >> logs
	apt-get install gawk -y >> logs
	apt-get install dc -y >> logs
	apt-get install build-essential -y >> logs
	apt-get install snmp -y >> logs
	apt-get install libnet-snmp-perl -y >> logs
	apt-get install gettext -y >> logs
	cd /tmp ||  exit 1
	wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz >> logs
	tar zxf nagios-plugins.tar.gz >> logs
}

function ConfigNRPEPlugins(){
	cd /tmp/nagios-plugins-release-2.2.1/ ||  exit 1
	./tools/setup >> logs
	./configure >> logs
	make >> logs
	make install >> logs
	
	if [[ "$VERSION" = 7.* ]]; then
		service nrpe start
	elif [[ "$VERSION" = 8.* ]]; then
		systemctl start nrpe.service
	elif [[ "$VERSION" = 9.* ]]; then
		systemctl start nrpe.service
	else
		 exit 1;
	fi
	
}

function ConfSudoers(){
	echo "#Rule for nagios/nrpe" >> /etc/sudoers
	echo "nagios ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
}
function CopyScripts(){
	echo "Installation des scripts wazo/xivo" >> logs
	cd /tmp/ScriptWazoXivoDeploiement ||  exit 1
	cp commandnrpe/command_nrpe.cfg /usr/local/nagios/etc/command_nrpe.cfg
	cp base/nagisk.pl /usr/local/nagios/libexec/nagisk.pl
	cp base/check_services_wazo_xivo.pl /usr/local/nagios/libexec/check_services_wazo_xivo.pl
	cp base/checkversionwazoxivo.sh /usr/local/nagios/libexec/checkversionwazoxivo.sh
	cp base/checkuptimewazoxivo.sh /usr/local/nagios/libexec/checkuptimewazoxivo.sh
	cd /usr/local/nagios ||  exit 1
	chmod -R 755 libexec/
}

function End(){
	service nrpe restart
	echo "Finish" >> logs
}


main() {
    if [[ -n "${1}" ]]; then
        "${1}"
    else
        echo
        echo "################################################################################" 
		echo -e "\033[45m#               Installation of NRPE and NAGIOS for Centreon                   #\033[0m"
		echo -e "\033[45m#                     Compatible with Debian 7/8/9 only                        #\033[0m"
		echo "#                    Writed by Kévin Perez for AtConnect                       #"
		echo "# The task is in progress, please wait a few minutes while i'm doing your job !#"
		echo "################################################################################" 
		echo "--------------------------------------------------------------------------------"
        success
        
    fi
}

main "${@}"

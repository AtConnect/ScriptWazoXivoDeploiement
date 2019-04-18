#!/bin/bash
#Update of the system only if update has been run without problem
clear
VERSION=$(cat /etc/debian_version)
if [[ "$VERSION" = 6.* ]]; then
	exit;
fi

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
}

function DownloadNRPE(){
	cd /tmp || exit
	wget --no-check-certificate -q -O nrpe.tar.gz https://github.com/NagiosEnterprises/nrpe/archive/nrpe-3.2.1.tar.gz >>/dev/null 2>logs
	tar xzf nrpe.tar.gz >> logs
	cd /tmp/nrpe-nrpe-3.2.1/
}

function InstallNRPE(){
	echo "Install BINARIES and more" >> logs
	./configure --enable-command-args >>/dev/null 2>logs
	make all >>/dev/null 2>logs
	make install-groups-users >>/dev/null 2>logs
	make install >>/dev/null 2>logs
	make install-config >>/dev/null 2>logs
	echo >> /etc/services
	echo '# Nagios services' >> /etc/services
	echo 'nrpe    5666/tcp' >> /etc/services
	
	if [[ "$VERSION" = 7.* ]]; then
		make install-init >>/dev/null 2>logs
		update-rc.d nrpe defaults >>/dev/null 2>logs
	elif [[ "$VERSION" = 8.* ]]; then	
		make install-init >>/dev/null 2>logs
		systemctl enable nrpe.service >> logs
	elif [[ "$VERSION" = 9.* ]]; then
		make install-init >>/dev/null 2>logs
		systemctl enable nrpe.service >> logs
	else
		exit;
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
	cd /tmp || exit
	wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz >>/dev/null 2>logs
	tar zxf nagios-plugins.tar.gz >> logs
}

function ConfigNRPEPlugins(){
	cd /tmp/nagios-plugins-release-2.2.1/ || exit
	./tools/setup >>/dev/null 2>logs
	./configure >>/dev/null 2>logs
	make >>/dev/null 2>logs
	make install >>/dev/null 2>logs
	
	if [[ "$VERSION" = 7.* ]]; then
		service nrpe start
	elif [[ "$VERSION" = 8.* ]]; then
		systemctl start nrpe.service
	elif [[ "$VERSION" = 9.* ]]; then
		systemctl start nrpe.service
	else
		exit;
	fi
	
}

function ConfSudoers(){
	echo "#Rule for nagios/nrpe" >> /etc/sudoers
	echo "nagios ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
}
function CopyScripts(){
	echo "Installation des scripts wazo/xivo" >> logs
	cd /tmp/ScriptWazoXivoDeploiement || exit
	cp command_nrpe.cfg /usr/local/nagios/etc/command_nrpe.cfg
	cp nagisk.pl /usr/local/nagios/libexec/nagisk.pl
	cp check_services_wazo_xivo.pl /usr/local/nagios/libexec/check_services_wazo_xivo.pl
	cd /usr/local/nagios ||exit
	chmod -R 755 libexec/
}

function End(){
	service nrpe restart
	echo "Finish" >> logs
}


#
# Description : delay executing script
#
function delay()
{
    sleep 0.2;
}

#
# Description : print out executing progress
# 
CURRENT_PROGRESS=0
function progress()
{
    PARAM_PROGRESS=$1;
    PARAM_PHASE=$2;

    if [ $CURRENT_PROGRESS -le 0 -a $PARAM_PROGRESS -ge 0 ]  ; then echo -ne "[..........................] (0%)  $PARAM_PHASE \r"  ; UpdateSystem; fi;
    if [ $CURRENT_PROGRESS -le 5 -a $PARAM_PROGRESS -ge 5 ]  ; then echo -ne "[#.........................] (5%)  $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 10 -a $PARAM_PROGRESS -ge 10 ]; then echo -ne "[##........................] (10%) $PARAM_PHASE \r"  ; DownloadNRPE; fi;
    if [ $CURRENT_PROGRESS -le 15 -a $PARAM_PROGRESS -ge 15 ]; then echo -ne "[###.......................] (15%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 20 -a $PARAM_PROGRESS -ge 20 ]; then echo -ne "[####......................] (20%) $PARAM_PHASE \r"  ; InstallNRPE; fi;
    if [ $CURRENT_PROGRESS -le 25 -a $PARAM_PROGRESS -ge 25 ]; then echo -ne "[#####.....................] (25%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 30 -a $PARAM_PROGRESS -ge 30 ]; then echo -ne "[######....................] (30%) $PARAM_PHASE \r"  ; InstallIptables; fi;
    if [ $CURRENT_PROGRESS -le 35 -a $PARAM_PROGRESS -ge 35 ]; then echo -ne "[#######...................] (35%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 40 -a $PARAM_PROGRESS -ge 40 ]; then echo -ne "[########..................] (40%) $PARAM_PHASE \r"  ; ConfigNRPE; fi;
    if [ $CURRENT_PROGRESS -le 45 -a $PARAM_PROGRESS -ge 45 ]; then echo -ne "[#########.................] (45%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 50 -a $PARAM_PROGRESS -ge 50 ]; then echo -ne "[##########................] (50%) $PARAM_PHASE \r"  ; NRPEPlugins; fi;
    if [ $CURRENT_PROGRESS -le 55 -a $PARAM_PROGRESS -ge 55 ]; then echo -ne "[###########...............] (55%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 60 -a $PARAM_PROGRESS -ge 60 ]; then echo -ne "[############..............] (60%) $PARAM_PHASE \r"  ; ConfigNRPEPlugins; fi;
    if [ $CURRENT_PROGRESS -le 65 -a $PARAM_PROGRESS -ge 65 ]; then echo -ne "[#############.............] (65%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 70 -a $PARAM_PROGRESS -ge 70 ]; then echo -ne "[###############...........] (70%) $PARAM_PHASE \r"  ; ConfSudoers; fi;
    if [ $CURRENT_PROGRESS -le 75 -a $PARAM_PROGRESS -ge 75 ]; then echo -ne "[#################.........] (75%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 80 -a $PARAM_PROGRESS -ge 80 ]; then echo -ne "[####################......] (80%) $PARAM_PHASE \r"  ; CopyScripts; fi;
    if [ $CURRENT_PROGRESS -le 85 -a $PARAM_PROGRESS -ge 85 ]; then echo -ne "[#######################...] (85%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 90 -a $PARAM_PROGRESS -ge 90 ]; then echo -ne "[##########################] (100%) $PARAM_PHASE \r" ; delay; fi;
    if [ $CURRENT_PROGRESS -le 100 -a $PARAM_PROGRESS -ge 100 ];then echo -ne "[##########################] (100%) $PARAM_PHASE \n" ; End; fi;

    CURRENT_PROGRESS=$PARAM_PROGRESS;
}
echo "Installation of NRPE and NAGIOS for Centreon"
echo "Compatible with only Debian 7/8/9"
echo "Writed by Kévin Perez for AtConnect"
echo "The task is in progress, please wait a few seconds while i'm doing your job !"
#Jusqu'a 10 on reste sur initialize

progress 10 Initialize
progress 20 "Download NRPE        "
progress 30 "Install NRPE         "
progress 40 "Install Iptables     "
progress 50 "Config NRPE          "
progress 60 "NRPE Plugins         "
progress 70 "Config NRPE Plugins  "
progress 80 "Configuration Sudoers"
progress 90 "Copying Scripts      "
progress 100 "Done Successful installation "

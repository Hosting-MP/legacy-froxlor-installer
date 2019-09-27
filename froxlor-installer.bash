#!/bin/bash
#---------------------------------------------------------------------
# froxlor-install.sh
#
# Froxlor Installer
#
# Script: froxlor-install.bash
# Version: 1.1.0
# Author: Hosting-MP.de <info@hosting-mp.com>
# Description: This script will install all components needed to run
# Froxlor (https://froxlor.org) on your server.
#---------------------------------------------------------------------


#---------------------------------------------------------------------
# First make sure everything is compatible
#---------------------------------------------------------------------
  wget -q -O otherFunctions.bash https://raw.githubusercontent.com/Hosting-MP/froxlor-installer/master/otherFunctions.bash || echo -e "\e[31mFailed downloading \e[95minitial\e[31m resource!\e[0m" | exit 1
  source "otherFunctions.bash" || echo -e "\e[31mFailed loading resource!\e[0m" | exit 1

  runAsRoot
  isOSsupported
  calledScriptAsSupposed


#---------------------------------------------------------------------
# Global variables
#---------------------------------------------------------------------

# directory where froxlor-install.bash is located in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOGFILE=$DIR/froxlor-installer.log



# Starting logger
touch $LOGFILE
echo "$(date "+%d.%m.%Y %T") : Starting work" > $LOGFILE 2>&1


#---------------------------------------------------------------------
# Download resources
#---------------------------------------------------------------------

# download spinner class which makes the installation process more visual
wget -q -O spinner.sh https://raw.githubusercontent.com/tlatsas/bash-spinner/master/spinner.sh || echo -e "\e[31mFailed downloading \e[95manimation\e[31m resource!\e[0m" | exit 1
source "spinner.sh"

# download file with functions (better overview)
wget -q -O froxlor-install-components.bash https://raw.githubusercontent.com/Hosting-MP/froxlor-installer/master/froxlor-install-components.bash || echo -e "\e[31mFailed downloading \e[95mcomponent\e[31m resource!\e[0m" | exit 1
mkdir $DIR/basic
basicFiles="clamav database quota ioncubeLoaders php-fpm phpmyadmin rkhunter system visualFrontend"
for i in $basicFiles; do
  wget -q -O basic/$i.bash https://raw.githubusercontent.com/Hosting-MP/froxlor-installer/master/basic/$i.bash || echo -e "\e[31mFailed downloading resource \e[95m$i\e[31m!\e[0m" | exit 1
  wait
done

mkdir $DIR/froxlorWeb
froxlorWebFiles="awstats bind9 cron extrausers logrotate setupFroxlorGit userdataINC webserver webSql"
for i in $froxlorWebFiles; do
  wget -q -O froxlorWeb/$i.bash https://raw.githubusercontent.com/Hosting-MP/froxlor-installer/master/froxlorWeb/$i.bash || echo -e "\e[31mFailed downloading resource \e[95m$i\e[31m!\e[0m" | exit 1
  wait
done


#---------------------------------------------------------------------
# Load resources
#---------------------------------------------------------------------
loadResource() {
  source "$DIR/${1}.bash" || echo -e "\e[31mFailed loading resource!\e[0m" | exit 1
}

loadResource "froxlor-install-components"
loadResource "otherFunctions"



######################################################################
########################### Actual Process ###########################
######################################################################



#---------------------------------------------------------------------
# Collecting data and asking user
#---------------------------------------------------------------------
  loadResource "basic/visualFrontend"
  ask 1


#---------------------------------------------------------------------
# Starting actual install process
#---------------------------------------------------------------------

  # set hostname to previously asked value
  hostnamectl set-hostname $hostname

  installComponent "basic/system"

  getPHPv
  getPHPdir

  installComponent "basic/php-fpm"
  installComponent "basic/database"
  installComponent "basic/phpmyadmin"
  installComponent "basic/quota"
  installComponent "basic/ioncubeLoaders"
  installComponent "basic/rkhunter"
  installComponent "basic/clamav"

  installComponent "froxlorWeb/setupFroxlorGit"
  installComponent "froxlorWeb/webserver"


#---------------------------------------------------------------------
# Collecting other data and asking user
#---------------------------------------------------------------------
  ask 2


#---------------------------------------------------------------------
# Continue install process
#---------------------------------------------------------------------
  installComponent "froxlorWeb/extrausers"
  installComponent "froxlorWeb/bind9"
  installComponent "froxlorWeb/logrotate"
  installComponent "froxlorWeb/cron"
  installComponent "froxlorWeb/awstats"
  installComponent "froxlorWeb/userdataINC"
  installComponent "froxlorWeb/webSql"


  if [ -f /var/www/html/lib/userdata.inc.php ]; then
    # do not run in shell as if there are errors directly show them to user
    php /var/www/html/scripts/froxlor_master_cronjob.php --force
  fi


  removeInstallerFiles
  rm froxlor-install-components.bash


#---------------------------------------------------------------------
# Sending user message that installed
#---------------------------------------------------------------------
  ask 3


#---------------------------------------------------------------------
# Finished install process
#---------------------------------------------------------------------

echo "$(date "+%d.%m.%Y %T") : Finished Part 2/2" >> $LOGFILE 2>&1
echo "$(date "+%d.%m.%Y %T") : Finished Part" >> $LOGFILE 2>&1
exit 0

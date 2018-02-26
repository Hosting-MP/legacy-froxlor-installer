#!/bin/bash

# Check if this script is run with root permissions
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Starting logger
LOGFILE=froxlor-installer.log
touch $LOGFILE
echo "$(date "+%d.%m.%Y %T") : Starting work" >> $LOGFILE 2>&1

# Run a command in the background.
_evalBg() {
    # no hurry
    sleep 0.2
    # $@ &>>$LOGFILE & disown --> this might be preferred methode but nohup seems to do the job just as good but more beautiful
    # eval "nohup $@ & > $LOGFILE 2>&1" &>/dev/null;
    nohup $@ >>$LOGFILE 2>&1 &
    stop_spinner $?
    wait
}

wget -q -O spinner.sh https://raw.githubusercontent.com/tlatsas/bash-spinner/master/spinner.sh
source "spinner.sh"

ifDirExists() {
LINK_OR_DIR=$1
if [ -d $LINK_OR_DIR ]; then
  if [ -L $LINK_OR_DIR ]; then
    # It is a symlink!
    # Symbolic link specific commands go here.
    return 0
  else
    # It's a directory!
    # Directory command goes here.
    return 0
  fi
  else
  return 1
fi
}

logError() {
  ERROR_msg=$1
  echo -e "\e[31mError during installation:\e[0m $ERROR_msg"
  echo "$(date "+%d.%m.%Y %T") : Error during installation: $ERROR_msg" >> $LOGFILE 2>&1
}

isVM() {
  if [ "$(hostnamectl | grep Chassis)" == "           Chassis: vm" ]; then
    return 0
  fi
}

getPHPversion() {
  # https://gist.github.com/SpekkoRice/694e4e33ee298361b642
  v="$(php -v|grep -m 1 --only-matching --perl-regexp "7\.\\d")"
  # https://blog.ueffing.net/post/2012/06/19/php-version-mit-bash-herausfinden/
  v2="$(sLong=`php -v | grep PHP -m 1 | awk '{print $2}'`; echo ${sLong:0:3})"
  
  if [ ! return $v == "" ]; then
    return $v;
  elif [ ! return $v == "" ]; then
    return $v2;
	else
	return 1;
  fi
}

######### Collecting data and asking user ##########

# clear terminal before installation process
printf "\033c"

echo -e "\e[32m    #####################\e[0m"
echo -e "\e[32m    # \e[0m\e[42mFroxlor Installer\e[49m\e[32m #\e[0m"
echo -e "\e[32m    #####################\e[0m"
echo ""
echo ""
echo -e "\e[93m--> \e[91mCollecting data first:\e[0m"
echo ""
echo ""
echo -e "\e[94m------------------------\e[0m"
while [[ $mdbpasswd = "" ]]; do
   read -sp 'Database root password: ' mdbpasswd
   if [ -z $mdbpasswd ] ; then
      echo $'\e[31mfailed\e[0m'
   else
      echo $'\e[32msuccess\e[0m'
   fi
done
echo -e "\e[94m------------------------\e[0m"
while [[ $hostname = "" ]]; do
   read -e -p 'Hostname: ' -i "$(hostname -f)" hostname
   if [ -z $hostname ] ; then
      echo $'\e[31mfailed\e[0m'
   else
      echo $'\e[32msuccess\e[0m'
   fi
done
echo -e "\e[94m------------------------\e[0m"
while true; do
    read -p "Mark system as clean for rkhunter? [Yn]" yn
    yn=${yn:-y}
    case $yn in
        [Yy]* ) propupd=true; break;;
        [Nn]* ) propupd=false; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo -e "\e[94m------------------------\e[0m"
while true; do
    read -p "Create additional root user for froxlor and do not use system root (when no system root will be made froxlor compatible, not recommended)? [Yn]" fryn
    fryn=${fryn:-y}
    case $fryn in
        [Yy]* ) createFroxlorRootPassword=true; break;;
        [Nn]* ) createFroxlorRootPassword=false; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo -e "\e[94m------------------------\e[0m"

dpkg-reconfigure tzdata

######### Starting actual install process ##########

echo -e "\e[93m--> \e[91mStarting the installation process!\e[0m"
echo ""

hostnamectl set-hostname $hostname

start_spinner "Updating repos..."
cmd="apt-get update";
_evalBg "${cmd}";
sleep 1
start_spinner "Updating packages..."
cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade";
_evalBg "${cmd}";
start_spinner "Updating system..."
cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade";
_evalBg "${cmd}";

#echo -e "System updated \e[32msuccessfully\e[0m"

start_spinner "Installing required components (takes a long time)..."
cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils debconf-utils \
                dialog apache2-utils mcrypt curl bzip2 zip unzip tar wget git \
                apache2 php php-fpm php-json php-gd php-imagick imagemagick php-curl php-mcrypt \
                php-xsl php-yaml php-fileinfo php-uploadprogress php-geoip geoip-database-contrib \
                php-apcu php-bcmath php-dom php-gnupg php-imap php-mailparse php-mbstring \
                php-memcached php-mysql php-pdo php-pdo-mysql php-sqlite3 sqlite3 \
                php-pspell spell aspell-de php-phar php-posix php-pear php-tidy \
                php-yaml php-zip php-intl php-memcache php-xmlrpc rkhunter \
                nscd libnss-extrausers apache2-suexec-pristine bind9 logrotate awstats \
                clamav clamav-daemon";
_evalBg "${cmd}";

#echo -e "Components installed \e[32msuccessfully\e[0m"

phpenmod pdo
phpenmod pdo_mysql
phpenmod pdo_sqlite

start_spinner "Restarting PHP fpm"
cmd="systemctl restart php7.0-fpm";
_evalBg "${cmd}";

start_spinner "Making PHP fpm start on boot"
cmd="systemctl enable php7.0-fpm";
_evalBg "${cmd}";

start_spinner "Enable apache2 modules"
cmd="a2enmod rewrite ssl proxy_fcgi setenvif actions headers suexec";
_evalBg "${cmd}";

start_spinner "Enable PHP fpm for apache2"
cmd="a2enconf php7.0-fpm";
_evalBg "${cmd}";

start_spinner "Restarting apache2"
cmd="systemctl restart apache2";
_evalBg "${cmd}";

#echo -e "Enabled components \e[32msuccessfully\e[0m"

export DEBIAN_FRONTEND="noninteractive"
debconf-set-selections <<< "mariadb-server mysql-server/root_password password $mdbpasswd"
debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password $mdbpasswd"
start_spinner "Installing database server..."
cmd="apt-get install -y mariadb-server";
_evalBg "${cmd}";

#echo -e "Installed database-server \e[32msuccessfully\e[0m"

if $createFroxlorRootPassword ; then
  # Generate froxlorroot password
  froxlorrootpassword="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-24};echo;)"
  mysql -u root -p$mdbpasswd <<EOF
CREATE USER 'froxlorroot'@'localhost' IDENTIFIED BY '$froxlorrootpassword';
GRANT ALL PRIVILEGES ON * . * TO 'froxlorroot'@'localhost' WITH GRANT OPTION;
UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE user = 'froxlorroot' AND plugin = 'unix_socket';
FLUSH PRIVILEGES;
EOF
  echo -e "Added froxlor root user to DB \e[32msuccessfully\e[0m"
else
  # ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$mdbpasswd';
  mysql -u root -p$mdbpasswd <<EOF
UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE user = 'root' AND plugin = 'unix_socket';
FLUSH PRIVILEGES;
EOF
  echo -e "Enabled DB \e[32msuccessfully\e[0m for root"
fi

# export DEBIAN_FRONTEND="noninteractive"
# APP_PASS="your-app-pwd"
# echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
# echo "phpmyadmin phpmyadmin/mysql/app-pass password $APP_PASS" | debconf-set-selections
# echo "phpmyadmin phpmyadmin/app-password-confirm password $APP_PASS" | debconf-set-selections
# echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections

# apt-get install -y phpmyadmin

if [ -f /var/www/html/index.html ]; then
    rm /var/www/html/index.html
fi
start_spinner "Setting up froxlor..."
cmd="git clone https://github.com/Froxlor/Froxlor.git /var/www/html";
_evalBg "${cmd}";

cat <<EOF > /etc/cron.daily/update-froxlor
#!/bin/bash
git --git-dir='/var/www/html' pull origin master
RESULT=$?
if [ $RESULT -eq 0 ]; then
  exit 0
else
  /usr/bin/git --git-dir='/var/www/html' pull origin master
  RESULT=$?
  if [ $RESULT -eq 0 ]; then
    exit 0
  else
    logger -i "Failed to update froxlor git repo"
    exit 1
  fi
fi
EOF

#minute=shuf -i 0-59 -n 1
#hour=shuf -i 0-23 -n 1
#
#cmd="crontab -l | { cat; echo "0 0 * * * some entry"; } | crontab";
#_evalBg "${cmd}";

start_spinner "Creating group for froxlor web"
cmd="groupadd -f froxlorlocal";
_evalBg "${cmd}";

start_spinner "Creating user for froxlor web"
cmd="useradd -s /bin/false -g froxlorlocal froxlorlocal";
_evalBg "${cmd}";

start_spinner "Setting user perms on froxlor web"
cmd="chown -R froxlorlocal:froxlorlocal /var/www/html";
_evalBg "${cmd}";

#echo -e "Setup froxlor web \e[32msuccessfully\e[0m"

start_spinner "Installing system quota..."
cmd="apt-get install -y quota quotatool";
_evalBg "${cmd}";


# enable quota and check for virtualized environments
if ! [ -f /proc/user_beancounters ]; then
  if [ `cat /etc/fstab | grep ',usrjquota' | wc -l` -eq 0 ] || [ `cat /etc/fstab | grep ',grpjquota' | wc -l` -eq 0 ] || [ `cat /etc/fstab | grep ',usrquota' | wc -l` -eq 0 ] || [ `cat /etc/fstab | grep ',grpquota' | wc -l` -eq 0 ]; then
    sed -i 's/errors=remount-ro/errors=remount-ro,usrquota,grpquota/g' /etc/fstab
    start_spinner "Remounting filesystem to enable quota"
    cmd="mount -o remount /"
    _evalBg "${cmd}"
    if quotacheck -acugm; then
      if [ -f /aquota.user ]; then
        touch /aquota.user
        chmod 600 /aquota.user
        if [ -f /aquota.group ]; then
          touch /aquota.group
          chmod 600 /aquota.group
        fi
      fi
      quotaon -aug
      elif [ "$(grep -i QFMT_V2 /boot/config-`uname -r`)" == "CONFIG_QFMT_V2=y" ] || [ "$(grep -i QFMT_V2 /boot/config-`uname -r`)" == "CONFIG_QFMT_V2=m" ]; then
        if quotacheck -F vfsv1 -acugm; then
          sed -i 's/errors=remount-ro,usrquota,grpquota/usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv1/g' /etc/fstab
          modprobe quota_v1
          modprobe quota_v2
          start_spinner "Remounting filesystem to enable journaled quota"
          cmd="mount -o remount /"
          _evalBg "${cmd}"
          quotacheck -F vfsv1 -acugmf
          quotaon -F vfsv1 -aug
          elif quotacheck -F vfsv0 -acugm; then
            sed -i 's/errors=remount-ro,usrquota,grpquota/usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0/g' /etc/fstab
            modprobe quota_v1
            modprobe quota_v2
            start_spinner "Remounting filesystem to enable journaled quota"
            cmd="mount -o remount /"
            _evalBg "${cmd}"
            quotacheck -F vfsv0 -acugmf
            quotaon -F vfsv0 -aug
            else
              # create quoter files ..just in case
              touch /aquota.user /aquota.group
              chmod 600 /aquota.user
              chmod 600 /aquota.group
              quotaoff -af
              # removing applied quota tags
              sed -i 's/errors=remount-ro,usrquota,grpquota/errors=remount-ro/g' /etc/fstab
              echo -e "Enabling quotas \e[31mfailed\e[0m (already enabled?)"
              start_spinner "Remounting filesystem to disable journaled quota"
              cmd="mount -o remount /"
              _evalBg "${cmd}";
        fi
    fi
  fi
fi


#echo -e "Enabled quotas \e[32msuccessfully\e[0m"

# download and install ioncube loaders to php
start_spinner "Downloading ioncube loaders..."
cmd="wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz";
_evalBg "${cmd}";
if ifDirExists "tmp-icl"; then
  logError "ioncube loaders, directory already exists"
  else
  mkdir tmp-icl
fi
start_spinner "Extracting ioncube loaders..."
cmd="tar -C tmp-icl -xzf ioncube_loaders_lin_x86-64.tar.gz";
_evalBg "${cmd}";
# how to get the php extension directory??
if ifDirExists "/usr/lib/php/20151012"; then
  cp tmp-icl/ioncube/ioncube_loader_lin_7.0.so /usr/lib/php/20151012
  else
  logError "ioncube loaders, php extention directory at wrong place"
fi
touch /etc/php/7.0/fpm/conf.d/00-ioncube.ini
chmod 0777 /etc/php/7.0/fpm/conf.d/00-ioncube.ini
chown root:root /etc/php/7.0/fpm/conf.d/00-ioncube.ini
cat <<EOF > /etc/php/7.0/fpm/conf.d/00-ioncube.ini
zend_extension = "/usr/lib/php/20151012/ioncube_loader_lin_7.0.so"
EOF
rm ioncube_loaders_lin_x86-64.tar.gz
rm -R tmp-icl
start_spinner "Disable mod php for apache2"
cmd="a2dismod php7.0";
_evalBg "${cmd}";
start_spinner "Restarting apache2"
cmd="systemctl restart apache2";
_evalBg "${cmd}";
start_spinner "Restarting PHP fpm"
cmd="systemctl restart php7.0-fpm";
_evalBg "${cmd}";

#echo -e "Added ioncubeloader \e[32msuccessfully\e[0m"

# updating rkhunter database
if [ "$(rkhunter --version | grep "Rootkit Hunter 1.")" == "Rootkit Hunter 1.4.2" ]; then
  sed -i "s/UPDATE_MIRRORS=0/UPDATE_MIRRORS=1/g" /etc/rkhunter.conf
  sed -i "s/MIRRORS_MODE=1/MIRRORS_MODE=0/g" /etc/rkhunter.conf
  sed -i "s/WEB_CMD=\"\/bin\/false\"/WEB_CMD=\"\"/g" /etc/rkhunter.conf
fi
start_spinner "Setting up rootkit hunter..."
cmd="rkhunter --versioncheck";
_evalBg "${cmd}";
start_spinner "Updating rootkit hunter..."
cmd="rkhunter --update";
_evalBg "${cmd}";

# scan filesystem with rkhunter once to set these values als clean
if $propupd ; then
  start_spinner "Setting file system to genuine in rkhunter..."
  cmd="rkhunter --propupd";
  _evalBg "${cmd}";
fi

#echo -e "Installed rkhunter \e[32msuccessfully\e[0m"

# setting up clamav
mkdir /home/clamavinfected
cat <<EOF > /etc/cron.daily/clamd-froxlor
#!/bin/bash
clamscan --max-filesize=20000M --max-scansize=20000M --recursive --move=/home/clamavinfected --infected /home
EOF
sed -i 's/DatabaseMirror db.local.clamav.net/DatabaseMirror db.de.clamav.net/g' /etc/clamav/freshclam.conf

# setting up extrausers according to froxlor config
mkdir -p /var/lib/extrausers
touch /var/lib/extrausers/{passwd,group,shadow}
rm /etc/nsswitch.conf
touch /etc/nsswitch.conf
chown root:root /etc/nsswitch.conf
cat <<EOF > /etc/nsswitch.conf
# /etc/nsswitch.conf
#
# Example configuration of GNU Name Service Switch functionality.
# If you have the 'glibc-doc-reference' and 'info' packages installed, try:
# 'info libc "Name Service Switch"' for information about this file.

passwd:         compat extrausers
group:          compat extrausers
shadow:         compat extrausers
gshadow:        files

hosts:          files dns
networks:       files dns

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files
netmasks:       files
netgroup:       files
bootparams:     files

netgroup:       nis
EOF
start_spinner "Restarting nscd..."
cmd="systemctl restart nscd";
_evalBg "${cmd}";
nscd --invalidate=group

# setting up bind9 according to froxlor config
echo "include \"/etc/bind/froxlor_bind.conf\";" >> /etc/bind/named.conf.local
touch /etc/bind/froxlor_bind.conf
chown bind:0 /etc/bind/froxlor_bind.conf
chmod 0644 /etc/bind/froxlor_bind.conf
start_spinner "Restarting nameserver..."
cmd="systemctl restart bind9";
_evalBg "${cmd}";

# setting up apache2 according to froxlor config
mkdir -p /var/customers/webs/
mkdir -p /var/customers/logs/
mkdir -p /var/customers/tmp
chmod 1777 /var/customers/tmp
a2dismod userdir

cat <<EOF > /etc/apache2/conf-enabled/acme.conf
Alias "/.well-known/acme-challenge" "/var/www/html/.well-known/acme-challenge"
<Directory "/var/www/html/.well-known/acme-challenge">
	Require all granted
</Directory>
EOF
start_spinner "Restarting apache2"
cmd="systemctl restart apache2";
_evalBg "${cmd}";

# setting up logrotate according to froxlor config
cat <<EOF > /etc/logrotate.d/froxlor
#
# Froxlor logrotate snipet
#
/var/customers/logs/*.log {
  missingok
  weekly
  rotate 4
  compress
  delaycompress
  notifempty
  create
  sharedscripts
  postrotate
  /etc/init.d/apache2 reload > /dev/null 2>&1 || true
  endscript
}
EOF
chmod 0644 "/etc/logrotate.d/froxlor"
chown root:root "/etc/logrotate.d/froxlor"

# setting up awstats according to froxlor config
cp /usr/share/awstats/tools/awstats_buildstaticpages.pl /usr/bin/
# mv /etc/awstats//awstats.conf /etc/awstats//awstats.model.conf
ln -s /etc/awstats/awstats.conf /etc/awstats/awstats.model.conf
sed -i.bak 's/^DirData/# DirData/' /etc/awstats//awstats.model.conf
sed -i.bak 's|^\\(DirIcons=\\).*$|\\1\\"/awstats-icon\\"|' /etc/awstats//awstats.model.conf
rm /etc/cron.d/awstats

echo ""
echo -e "\e[92mFirst part of installation finished\e[0m"
echo ""
echo -e "Continue froxlor install in your web browser:"
echo -e "    \e[4mhttp://$( wget -qO- ipv4.icanhazip.com )\e[0m"
if $createFroxlorRootPassword ; then
  echo ""
  echo ""
  echo -e "Froxlor-Password (unprivileged): $(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;)"
  echo -e "FroxlorRoot: User=\e[1mfroxlorroot\e[0m Password=\e[1m$froxlorrootpassword\e[0m"
  echo -e "Froxlor-Admin-Password: $(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12};echo;)"
  echo -e "Copy these to the web browser installation process. \e[5mFroxlorRoot-Password is mandatory and case-sensitive!\e[0m"
fi
echo ""
echo ""
echo -e "Keep this information at a save place. We do not save it for you!"
echo ""
echo ""
echo -e "\e[33mOnce completed the web part of installation continue here..\e[0m"
echo "$(date "+%d.%m.%Y %T") : Finished Part 1/2" >> $LOGFILE 2>&1

sleep 2

# wait for user to finish web part of installation to let him continue then here
webfinished=false
while ! $webfinished; do
    read -p "Webinstallation completed so continue here? [Yn]" yn
    yn=${yn:-y}
    case $yn in
        [Yy]* ) webfinished=true; break;;
        [Nn]* ) webfinished=false;;
        * ) echo "Please answer yes or no.";;
    esac
done

while [[ $froxlordatabasename = "" ]]; do
   read -e -p 'Froxlor database name (unprivileged): ' -i "froxlor" froxlordatabasename
   if [ -z $froxlordatabasename ] ; then
      echo $'\e[31mfailed\e[0m'
   else
      echo $'\e[32msuccess\e[0m'
   fi
done

# setting up cron according to froxlor config
cat <<EOF > /etc/cron.d/froxlor
#
# Set PATH, otherwise restart-scripts won't find start-stop-daemon
#
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#
# Regular cron jobs for the froxlor package
#
# Please check that all following paths are correct
#
*/5 * * * * root    /usr/bin/nice -n 5 /usr/bin/php -q /var/www/html/scripts/froxlor_master_cronjob.php
EOF
chmod 0640 "/etc/cron.d/froxlor"
chown root:root "/etc/cron.d/froxlor"
start_spinner "Restarting cron"
cmd="systemctl restart cron";
_evalBg "${cmd}";

# enable quota in froxlor
mysql -u root -p$mdbpasswd $froxlordatabasename <<EOF
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 144;
UPDATE panel_settings SET value = '/usr/sbin/quotatool' WHERE panel_settings.settingid = 146;
UPDATE panel_settings SET value = '$(findmnt -n -o SOURCE --target /var/customers)' WHERE panel_settings.settingid = 147;
EOF

# enable webalizer in froxlor
mysql -u root -p$mdbpasswd $froxlordatabasename <<EOF
UPDATE panel_settings SET value = '0' WHERE panel_settings.settingid = 109;
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 118;
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 119;
UPDATE panel_settings SET value = '/usr/share/awstats/tools/' WHERE panel_settings.settingid = 133;
UPDATE panel_settings SET value = '/usr/lib/cgi-bin/' WHERE panel_settings.settingid = 153;
EOF

# enable php-fpm in froxlor
mysql -u root -p$mdbpasswd $froxlordatabasename <<EOF
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 55;
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 67;
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 75;
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 139;
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 179;
EOF

# if it is Debian 9 or Ubuntu 16.04 - 18.04 enable mod_proxy_fcgi
if [ "$(cat /etc/os-release | grep "VERSION_ID")" == "VERSION_ID=\"9\"" ] || [ "$(cat /etc/os-release | grep "VERSION_ID")" == "VERSION_ID=\"17.10\"" ] || [ "$(cat /etc/os-release | grep "VERSION_ID")" == "VERSION_ID=\"16.04\"" ] || [ "$(cat /etc/os-release | grep "VERSION_ID")" == "VERSION_ID=\"18.04\"" ]; then
mysql -u root -p$mdbpasswd $froxlordatabasename <<EOF
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 75;
EOF
fi

echo ""
echo -e "\e[92mInstallation finished\e[0m"
echo ""
echo -e "You may want to 'rebuild config files' in froxlor web."
echo ""
echo ""
echo -e "Do not forget to run mysql_secure_installation"
echo ""
echo "$(date "+%d.%m.%Y %T") : Finished Part 2/2" >> $LOGFILE 2>&1
echo "$(date "+%d.%m.%Y %T") : Finished Part" >> $LOGFILE 2>&1
exit 0

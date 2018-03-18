#---------------------------------------------------------------------
# Function: SetupSystem
#    Update system and install required components
#---------------------------------------------------------------------
setupSystem() {

  # Updating system to make sure we do not install old software
  start_spinner "Updating repos..."
  cmd="apt-get update";
  _evalBg "${cmd}";
  # waiting as it sometimes takes a second to apply changes on mirrorfile
  sleep 1
  start_spinner "Updating packages..."
  cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade";
  _evalBg "${cmd}";
  start_spinner "Updating system..."
  cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade";
  _evalBg "${cmd}";



  start_spinner "Installing required components (takes a long time)..."
  # for now they are the same but Ubuntu is likely to be updated more recently
  INSTALL_PKGsDEBIAN="apt-utils debconf-utils clamav clamav-daemon \
                  dialog apache2-utils mcrypt curl bzip2 zip unzip tar wget git \
                  apache2 php php-fpm php-json php-gd php-imagick imagemagick php-curl php-mcrypt \
                  php-xsl php-fileinfo php-uploadprogress php-geoip geoip-database-contrib \
                  php-apcu php-bcmath php-dom php-gnupg php-imap php-mailparse php-mbstring \
                  php-memcached php-mysql php-pdo php-pdo-mysql php-sqlite3 sqlite3 \
                  php-pspell spell aspell-de php-phar php-posix php-pear php-tidy tidy \
                  php-yaml php-zip php-intl php-memcache php-xmlrpc rkhunter certbot \
                  nscd libnss-extrausers apache2-suexec-pristine bind9 logrotate awstats"
  INSTALL_PKGsUBUNTU="apt-utils debconf-utils clamav clamav-daemon \
                  dialog apache2-utils mcrypt curl bzip2 zip unzip tar wget git \
                  apache2 php php-fpm php-json php-gd php-imagick imagemagick php-curl php-mcrypt \
                  php-xsl php-fileinfo php-uploadprogress php-geoip geoip-database-contrib \
                  php-apcu php-bcmath php-dom php-gnupg php-imap php-mailparse php-mbstring \
                  php-memcached php-mysql php-pdo php-pdo-mysql php-sqlite3 sqlite3 \
                  php-pspell spell aspell-de php-phar php-posix php-pear php-tidy tidy \
                  php-yaml php-zip php-intl php-memcache php-xmlrpc rkhunter certbot \
                  nscd libnss-extrausers apache2-suexec-pristine bind9 logrotate awstats"

  if [ $DISTRO = "Debian" ]; then
    cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $INSTALL_PKGsDEBIAN";
    _evalBg "${cmd}";
  elif [ $DISTRO = "Ubuntu" ]; then
    cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $INSTALL_PKGsUBUNTU";
    _evalBg "${cmd}";
  else
    echo "No methode for other OS than Debian/Ubuntu prepared yet"
  fi


### This procedure takes ages so not use it now ###
# for i in $INSTALL_PKGsUBUNTU; do
  # cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $i";
  # _evalBg "${cmd}";
# done

}
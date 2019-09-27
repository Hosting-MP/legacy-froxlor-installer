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
                  php php-fpm php-json php-gd php-imagick imagemagick php-curl php-mcrypt \
                  php-xsl php-fileinfo php-geoip geoip-database-contrib \
                  php-apcu php-bcmath php-dom php-gnupg php-imap php-mailparse php-mbstring \
                  php-memcached php-mysql php-pdo php-pdo-mysql php-sqlite3 sqlite3 \
                  php-pspell spell aspell-de php-phar php-posix php-pear php-tidy tidy \
                  php-yaml php-zip php-intl php-memcache php-xmlrpc rkhunter certbot \
                  libnss-extrausers bind9 logrotate awstats vim composer"
  INSTALL_PKGsUBUNTU="apt-utils debconf-utils clamav clamav-daemon \
                  dialog apache2-utils mcrypt curl bzip2 zip unzip tar wget git \
                  php php-fpm php-json php-gd php-imagick imagemagick php-curl php-mcrypt \
                  php-xsl php-fileinfo php-geoip geoip-database-contrib \
                  php-apcu php-bcmath php-dom php-gnupg php-imap php-mailparse php-mbstring \
                  php-memcached php-mysql php-pdo php-pdo-mysql php-sqlite3 sqlite3 \
                  php-pspell spell aspell-de php-phar php-posix php-pear php-tidy tidy \
                  php-yaml php-zip php-intl php-memcache php-xmlrpc rkhunter certbot \
                  libnss-extrausers bind9 logrotate awstats vim composer"
  INSTALL_PKGsDEBIAN_apache="apache2 apache2-suexec-pristine php-uploadprogress"
  INSTALL_PKGsUBUNTU_apache=" apache2 apache2-suexec-pristine php-uploadprogress"
  INSTALL_PKGsDEBIAN_nginx="nginx"
  INSTALL_PKGsUBUNTU_nginx="nginx"

  if [ "$webserverChoice" = "" ] || [ -z $webserverChoice ]; then
    if command -v apache2 2>/dev/null; then
      webserverChosen="apache"
      return 0
    fi
  elif [ "$webserverChoice" = "apache" ]; then
    if command -v apache2 2>/dev/null; then
      webserverChosen="apache"
      return 0
    fi
  elif [ "$webserverChoice" = "nginx" ]; then
    if command -v nginx 2>/dev/null; then
      webserverChosen="nginx"
      return 0
    fi
  else
    echo -e "\e[31mError choosing webserver. Maybe there is already an webserver installed.\e[0m"
    exit 1
  fi

  if [[ $DISTRO = "Debian" ]]; then
    cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $INSTALL_PKGsDEBIAN";
    _evalBg "${cmd}";
    if [[ $webserverChosen = "apache" ]]; then
      cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $INSTALL_PKGsDEBIAN_apache";
      _evalBg "${cmd}";
    fi
    if [[ $webserverChosen = "nginx" ]]; then
      cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $INSTALL_PKGsDEBIAN_nginx";
      _evalBg "${cmd}";
    fi
  elif [[ $DISTRO = "Ubuntu" ]]; then
    cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $INSTALL_PKGsUBUNTU";
    _evalBg "${cmd}";
    if [[ $webserverChosen = "apache" ]]; then
      cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $INSTALL_PKGsUBUNTU_apache";
      _evalBg "${cmd}";
    fi
    if [[ $webserverChosen = "nginx" ]]; then
      cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $INSTALL_PKGsUBUNTU_nginx";
      _evalBg "${cmd}";
    fi
  else
    echo "No methode for other OS than Debian/Ubuntu prepared yet"
  fi


### This procedure takes ages so not use it now ###
# for i in $INSTALL_PKGsUBUNTU; do
  # cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $i";
  # _evalBg "${cmd}";
# done

}

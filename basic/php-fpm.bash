#---------------------------------------------------------------------
# Function: SetupPHPfpm
#    Install php-fpm and make it default
#---------------------------------------------------------------------
setupPHPfpm() {

  # This does not generate any output usually so run it directly
  phpenmod pdo
  phpenmod pdo_mysql
  phpenmod pdo_sqlite

  start_spinner "Restarting PHP fpm"
  cmd="systemctl restart php$PHPv-fpm";
  _evalBg "${cmd}";

  start_spinner "Making PHP fpm start on boot"
  cmd="systemctl enable php$PHPv-fpm";
  _evalBg "${cmd}";

  if [ $webserverChosen = "apache" ]; then
    start_spinner "Enable apache2 modules"
    cmd="a2enmod rewrite ssl http2 proxy_fcgi setenvif actions headers suexec";
    _evalBg "${cmd}";

    start_spinner "Enable PHP fpm for apache2"
    cmd="a2enconf php$PHPv-fpm";
    _evalBg "${cmd}";

    restartApache

    # disable mod_php to use fpm from now on
    start_spinner "Disable mod php for apache2"
    cmd="a2dismod php$PHPv userdir";
    _evalBg "${cmd}";

    restartApache
  fi
  if [ $webserverChosen = "nginx" ]; then
    sed -i 's!#location ~ \\.php$ {!location ~ \\.php$ { fastcgi_pass unix:/run/php/php'"$PHPv"'-fpm.sock; }!g' /etc/nginx/sites-enabled/default

    restartNginx
  fi

}

#---------------------------------------------------------------------
# Function: InstallPHPmyAdmin
#    Install PHPmyAdmin to manage DBServr
#---------------------------------------------------------------------
installPHPmyAdmin() {

  echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/dbconfig-upgrade boolean false" | debconf-set-selections
  # echo "phpmyadmin phpmyadmin/mysql/app-pass password $APP_PASS" | debconf-set-selections
  # echo "phpmyadmin phpmyadmin/app-password-confirm password $APP_PASS" | debconf-set-selections
  start_spinner "Installing phpmyadmin..."
  cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y phpmyadmin";
  _evalBg "${cmd}";

}
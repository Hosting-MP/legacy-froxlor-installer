#---------------------------------------------------------------------
# Function: InstallDBServer
#    Install sql database server
#---------------------------------------------------------------------
installDBServer() {

  # export DEBIAN_FRONTEND="noninteractive"
  if [ $DISTRO = "Debian" ]; then
    debconf-set-selections <<< "mariadb-server mysql-server/root_password password $mdbpasswd"
    debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password $mdbpasswd"
    start_spinner "Installing database server..."
    cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server";
    _evalBg "${cmd}";
  elif [ $DISTRO = "Ubuntu" ]; then
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $mdbpasswd"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mdbpasswd"
    start_spinner "Installing database server..."
    cmd="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server";
    _evalBg "${cmd}";
  else
    echo "No methode for other OS prepared yet"
  fi

}

setupDBServer() {

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

}
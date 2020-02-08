#---------------------------------------------------------------------
# Command shell
#---------------------------------------------------------------------
# Run a command in the background.
_evalBg() {
    # no hurry
    sleep 0.2
    if [ "$installMethode" = "disown" ]; then
      # --> this might be preferred methode but nohup seems to do the job just as good but more beautiful
      $@ >>$LOGFILE 2>&1 & disown
    elif [ "$installMethode" = "nohup" ]; then
      # eval "nohup $@ & > $LOGFILE 2>&1" &>/dev/null;
      nohup $@ >>$LOGFILE 2>&1 &
    fi
    wait
    stop_spinner $?
}


#---------------------------------------------------------------------
# Check if script is executed with root permissions
#---------------------------------------------------------------------
runAsRoot() {

  # Check if this script is run with root permissions
  if [[ $EUID -ne 0 ]]; then
     echo "This script must be run as root" 1>&2
     exit 1
  else
    return 0
  fi

}


#---------------------------------------------------------------------
# Check if OS is supported
#---------------------------------------------------------------------
isOSsupported() {

  if [ "`lsb_release -is`" = "Debian" ]; then
    DISTRO="Debian"
    return 0
  elif [ "`lsb_release -is`" = "Ubuntu" ]; then
    DISTRO="Ubuntu"
    return 0
  else
    echo "Unsupported Operating System";
    exit 1
  fi

  if [[ "`lsb_release -r | grep -oP "[0-9]+" | head -1`" == *"10"* ]]; then
    DISTROv="10"
    return 0
  elif [[ "`lsb_release -r | grep -oP "[0-9]+" | head -1`" == *"18"* ]]; then
    DISTROv="18"
    return 0
  else
    DISTROv="999"
  fi

}


#---------------------------------------------------------------------
# check if user called script as supposed
#---------------------------------------------------------------------
calledScriptAsSupposed() {

  # let user choose between nohup or disown
  installMethodeChoice=$1
  if [ "$installMethodeChoice" = "" ] || [ -z $installMethodeChoice ]; then
    #nohup is default now
    installMethode="nohup"
    return 0
  elif [ "$installMethodeChoice" = "disown" ]; then
    # installMethode="disown" not yet working
    echo -e "Switching to nohup as disown is not available yet"
    installMethode="nohup"
    return 0
  elif [ "$installMethodeChoice" = "nohup" ]; then
    installMethode="nohup"
    return 0
  else
    echo -e "\e[31mError executing command. Use:\e[0m"
    echo "$0 <disown|nohup>"
    exit 1
  fi

}


#---------------------------------------------------------------------
# Webserver functions
#---------------------------------------------------------------------
restartApache() {
  start_spinner "Restarting apache2"
  cmd="systemctl restart apache2";
  _evalBg "${cmd}";
}

restartNginx() {
  start_spinner "Restarting nginx"
  cmd="systemctl restart nginx";
  _evalBg "${cmd}";
}

getPHPv() {
  # https://gist.github.com/SpekkoRice/694e4e33ee298361b642
  v="$(php -v|grep -m 1 --only-matching --perl-regexp "7.\d")"
  # https://blog.ueffing.net/post/2012/06/19/php-version-mit-bash-herausfinden/
  v2="$(sLong=`php -v | grep PHP -m 1 | awk '{print $2}'`; echo ${sLong:0:3})"

  # check if php has been installed successfully and if so which version
  if [ ! $v == "" ]; then
    PHPv=$v;
  elif [ ! $v2 == "" ]; then
    PHPv=$v2;
  else
    echo "\e[31mFailed\e[0m to fetch php, not installed?"
    exit 1
  fi
}

getPHPdir() {
  d="$(find /usr/lib/php -name "20*" -type d)"
  if [ ! $d == "" ]; then
    PHPdir=$d;
  else
    echo "\e[31mFailed\e[0m to find php-mod directory, custom installation?"
    exit 1
  fi
}


#---------------------------------------------------------------------
# Other functions
#---------------------------------------------------------------------

# Check if a directory exists
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

genRandomPasswd() {
  lenght=$1
  echo "$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-$lenght};echo;)"
  return 0
}


# append errors to the install log
logError() {
  ERROR_msg=$1
  echo -e "\e[31mError during installation:\e[0m $ERROR_msg"
  echo "$(date "+%d.%m.%Y %T") : Error during installation: $ERROR_msg" >> $LOGFILE 2>&1
}


# check whether this is a virtual machine (tested for KVM/XEN but not yet for VMware and oVZ/LXC)
isVM() {
  if [ "$(hostnamectl | grep Chassis)" == "           Chassis: vm" ]; then
    return 0
  fi
}

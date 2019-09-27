#---------------------------------------------------------------------
# Function: Ask
#    Throw questions in different parts of installation
#---------------------------------------------------------------------
ask() {

  if [ $1 -eq 1 ]; then
    # clear terminal before installation process
    printf "\033c"

    # Installer header
    echo -e "        \e[32m\e[42m#####################\e[49m\e[0m"
    echo -e "        \e[32m\e[42m#\e[49m\e[0m\e[33m Froxlor Installer \e[32m\e[42m#\e[49m\e[0m"
    echo -e "        \e[32m\e[42m#####################\e[49m\e[0m"
    echo ""
    echo ""
    echo -e "\e[93m--> \e[91mCollecting data first:\e[0m"
    echo ""
    echo ""

    # Asking for user data
    if ([ $DISTRO = "Debian" ] && [ $DISTROv = "9" ]) || ([ $DISTRO = "Ubuntu" ] && [ $DISTROv = "16" ]); then
      echo -e "\e[94m------------------------\e[0m"
      while [[ $mdbpasswd = "" ]]; do
        read -sp 'Database root password: ' mdbpasswd
        if [ -z $mdbpasswd ] ; then
          echo $'\e[31mfailed\e[0m'
        else
          echo $'\e[32msuccess\e[0m'
        fi
      done
    fi
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
      read -p "Choose apache2 or nginx as webserver? [apache or nginx]" ws
      ws=${ws:-apache}
      case $yn in
        [Apacheapache]* ) webserverChoice=apache; break;;
        [Nginxnginx]* ) webserverChoice=nginx; break;;
        * ) echo "Please answer apache or nginx.";;
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
    while true; do
      read -p "Update froxlor automatically (might break your system; DEV)? [yN]" yn
      yn=${yn:-n}
      case $yn in
        [Yy]* ) dailyUpdateFroxlor=true; break;;
        [Nn]* ) dailyUpdateFroxlor=false; break;;
        * ) echo "Please answer yes or no.";;
      esac
    done
    echo -e "\e[94m------------------------\e[0m"

    dpkg-reconfigure tzdata

    echo -e "\e[93m--> \e[91mStarting the installation process!\e[0m"
    echo ""

  elif [ $1 -eq 2 ]; then
    ### pause installation process to let user continue in browser with froxlor web installer
    printf "\033c"
    echo ""
    echo -e "\e[92mFirst part of installation finished\e[0m"
    echo ""
    echo -e "Continue froxlor install in your web browser:"
    echo -e "    \e[4mhttp://$( wget -qO- ipv4.icanhazip.com )\e[0m"
    if $createFroxlorRootPassword; then
      echo ""
      echo ""
      froxlorunprivilegedpasswd="$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;)"
      echo -e "Froxlor-Password (unprivileged): $froxlorunprivilegedpasswd"
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
    echo -e "\e[91mDo not try moving files from /tmp or similar as proposed by webinterface.\e[33m We will do this for you. ;)\e[0m"
    echo "$(date "+%d.%m.%Y %T") : Finished Part 1/2" >> $LOGFILE 2>&1

    sleep 2


    # wait for user to finish web part of installation to let him continue then here
    echo -e "\e[94m------------------------\e[0m"
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
    echo -e "\e[94m------------------------\e[0m"
    while [[ $froxlordatabasename = "" ]]; do
      read -e -p 'Froxlor database name (unprivileged): ' -i "froxlor" froxlordatabasename
      if [ -z $froxlordatabasename ] ; then
        echo $'\e[31mfailed\e[0m'
      else
        echo $'\e[32msuccess\e[0m'
      fi
    done
    if [ ! -z $froxlorunprivilegedpasswd ]; then
      echo -e "\e[94m------------------------\e[0m"
      while true; do
        read -p "Should we use auto generated password for froxlor db? [Yn]" yn
        yn=${yn:-y}
        case $yn in
          [Yy]* ) useFroxlorUnprivilegedPasswd=true; break;;
          [Nn]* ) useFroxlorUnprivilegedPasswd=false; break;;
          * ) echo "Please answer yes or no.";;
        esac
      done
    fi
    froxlorUnprivilegedPassword=
    if [ ! -z $useFroxlorUnprivilegedPasswd ]; then
      froxlorUnprivilegedPassword=$froxlorunprivilegedpasswd
    else
      echo -e "\e[94m------------------------\e[0m"
      while [[ $udbpasswd = "" ]]; do
        read -sp 'Froxlor db passwword (unprivileged): ' udbpasswd
        if [ -z $udbpasswd ] ; then
          echo $'\e[31mfailed\e[0m'
        else
          echo $'\e[32msuccess\e[0m'
          froxlorUnprivilegedPassword=$udbpasswd
        fi
      done
    fi
  elif [ $1 -eq 3 ]; then
    printf "\033c"
    echo ""
    echo -e "\e[92mInstallation finished\e[0m"
    echo ""
    echo -e "You may want to 'rebuild config files' in froxlor web."
    echo ""
    echo ""
    echo -e "\e[31mDo not forget to run mysql_secure_installation\e[0m"
    echo ""
  fi
}

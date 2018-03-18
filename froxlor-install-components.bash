installComponent() {
  loadResource $1

  #---------------------------------------------------------------------
  # Setup system
  #---------------------------------------------------------------------
  if [ "$1" = "basic/system" ]; then
    setupSystem
  fi

  if [ "$1" = "basic/php-fpm" ]; then
    setupPHPfpm
  fi

  if [ "$1" = "basic/database" ]; then
    installDBServer
    setupDBServer
  fi

  if [ "$1" = "basic/phpmyadmin" ]; then
    installPHPmyAdmin
  fi

  if [ "$1" = "basic/quota" ]; then
    setupQuota
  fi

  if [ "$1" = "basic/ioncubeLoaders" ]; then
    installICL
  fi

  if [ "$1" = "basic/rkhunter" ]; then
    setupRKHunter
  fi

  if [ "$1" = "basic/clamav" ]; then
    setupClamAV
  fi


  #---------------------------------------------------------------------
  # Setup Froxlor web
  #---------------------------------------------------------------------
  if [ "$1" = "froxlorWeb/setupFroxlorGit" ]; then
    installFroxlorWeb
  fi

  if [ "$1" = "froxlorWeb/webserver" ]; then
    setupWebServer
  fi
  
  if [ "$1" = "froxlorWeb/extrausers" ]; then
    setupExtraUsers
  fi
  
  if [ "$1" = "froxlorWeb/bind9" ]; then
    setupBind9
  fi
  
  if [ "$1" = "froxlorWeb/logrotate" ]; then
    setupLogrotate
  fi
  
  if [ "$1" = "froxlorWeb/cron" ]; then
    setupCron
  fi
  
  if [ "$1" = "froxlorWeb/awstats" ]; then
    setupAwstats
  fi
  
  if [ "$1" = "froxlorWeb/userdataINC" ]; then
    setupUserdataINC
  fi

  if [ "$1" = "froxlorWeb/webSql" ]; then
    setupWebSql
  fi

}

removeInstallerFiles() {
  rm spinner.sh
  rm -R $DIR/basic
  rm -R $DIR/froxlorWeb
}
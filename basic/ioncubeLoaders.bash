#---------------------------------------------------------------------
# Function: InstallICL
#    Download and install ioncube loaders for php
#---------------------------------------------------------------------
installICL() {

  # download and install ioncube loaders to php
  start_spinner "Downloading ioncube loaders..."
  cmd="wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz";
  _evalBg "${cmd}";

  if ifDirExists "$DIR/tmp-icl"; then
    logError "ioncube loaders, directory already exists"
  else
    mkdir $DIR/tmp-icl
  fi

  start_spinner "Extracting ioncube loaders..."
  cmd="tar -C tmp-icl -xzf ioncube_loaders_lin_x86-64.tar.gz";
  _evalBg "${cmd}";
  # how to get the php extension directory??
  if ifDirExists "$PHPdir"; then
    cp "tmp-icl/ioncube/ioncube_loader_lin_${PHPv}.so" "$PHPdir"
  else
    logError "ioncube loaders, php extention directory at wrong place"
  fi

  # creating conf for ioncube loaders in php
  touch "/etc/php/${PHPv}/fpm/conf.d/00-ioncube.ini"
  chmod 0777 "/etc/php/${PHPv}/fpm/conf.d/00-ioncube.ini"
  chown root:root "/etc/php/${PHPv}/fpm/conf.d/00-ioncube.ini"
  cat <<EOF > "/etc/php/${PHPv}/fpm/conf.d/00-ioncube.ini"
zend_extension = "${PHPdir}/ioncube_loader_lin_${PHPv}.so"
EOF
  # remove everything we no longer need from ioncube loaders
  rm ioncube_loaders_lin_x86-64.tar.gz
  rm -R tmp-icl

}

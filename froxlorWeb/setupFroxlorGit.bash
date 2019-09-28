#---------------------------------------------------------------------
# Function: InstallFroxlorWeb
#    Setup web part of Froxlor
#---------------------------------------------------------------------
installFroxlorWeb() {

  # cloning froxlor git repo
  if [ -f /var/www/html/index*.html ]; then
      rm /var/www/html/index*.html
  fi
  start_spinner "Setting up froxlor..."
  cmd="git clone https://github.com/Froxlor/Froxlor.git /var/www/html";
  _evalBg "${cmd}";


  if $dailyUpdateFroxlor ; then
  # adding new cronjob to update froxlor daily
    cat <<EOF > /etc/cron.daily/update-froxlor
#!/bin/bash
git --git-dir='/var/www/html/.git' pull origin master
RESULT=$?
if [ $RESULT -eq 0 ]; then
  exit 0
else
  /usr/bin/git --git-dir='/var/www/html/.git' pull origin master
  RESULT=$?
  if [ $RESULT -eq 0 ]; then
    exit 0
  else
    logger -i "Failed to update froxlor git repo"
    exit 1
  fi
fi
EOF
  fi


  # creating user and group for froxlor vhost user
  start_spinner "Creating group for froxlor web"
  cmd="groupadd -f froxlorlocal";
  _evalBg "${cmd}";

  start_spinner "Creating user for froxlor web"
  cmd="useradd -s /bin/false -g froxlorlocal froxlorlocal";
  _evalBg "${cmd}";

  start_spinner "Setting user perms on froxlor web"
  cmd="chown -R froxlorlocal:froxlorlocal /var/www/html";
  _evalBg "${cmd}";

  start_spinner "Running composer"
  cmd="composer install -d /var/www/html --no-dev";
  _evalBg "${cmd}";

}

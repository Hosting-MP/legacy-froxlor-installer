#---------------------------------------------------------------------
# Function: SetupRKHunter
#    Setup RKhunter and scan filesystem
#---------------------------------------------------------------------
setupRKHunter() {

  # updating rkhunter database as there is an issue with one version (Debian 9 default as time of initial release)
  if [ "$(rkhunter --version | grep "Rootkit Hunter 1.")" == "Rootkit Hunter 1.4.2" ]; then
    sed -i "s/UPDATE_MIRRORS=0/UPDATE_MIRRORS=1/g" /etc/rkhunter.conf
    sed -i "s/MIRRORS_MODE=1/MIRRORS_MODE=0/g" /etc/rkhunter.conf
    sed -i "s/WEB_CMD=\"\/bin\/false\"/WEB_CMD=\"\"/g" /etc/rkhunter.conf
  fi
  start_spinner "Setting up rootkit hunter..."
  cmd="rkhunter --versioncheck";
  _evalBg "${cmd}";
  start_spinner "Updating rootkit hunter..."
  cmd="rkhunter --update";
  _evalBg "${cmd}";
  # scan filesystem with rkhunter once to set these values als clean
  if $propupd ; then
    start_spinner "Setting file system to genuine in rkhunter..."
    cmd="rkhunter --propupd";
    _evalBg "${cmd}";
  fi

}
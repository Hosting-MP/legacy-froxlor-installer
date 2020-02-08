#---------------------------------------------------------------------
# Function: SetupLogrotate
#    Setup Logrotate so froxlor can make use of it
#---------------------------------------------------------------------
setupLogrotate() {

  # setting up logrotate according to froxlor config
  if [[ "$webserverChoice" = "apache" ]]; then
    cat <<EOF > /etc/logrotate.d/froxlor
#
# Froxlor logrotate snipet
#
/var/customers/logs/*.log {
  missingok
  daily
  rotate 7
  compress
  delaycompress
  notifempty
  create
  sharedscripts
  postrotate
  /etc/init.d/apache2 reload > /dev/null 2>&1 || true
  endscript
}
EOF
elif [[ "$webserverChoice" = "nginx" ]]; then
  cat <<EOF > /etc/logrotate.d/froxlor
#
# Froxlor logrotate snipet
#
/var/customers/logs/*.log {
  missingok
  daily
  rotate 7
  compress
  delaycompress
  notifempty
  create
  sharedscripts
  postrotate
  /etc/init.d/nginx reload > /dev/null 2>&1 || true
  endscript
}
EOF
fi

  chmod 0644 "/etc/logrotate.d/froxlor"
  chown root:root "/etc/logrotate.d/froxlor"

}

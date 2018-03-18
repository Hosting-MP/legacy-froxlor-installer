#---------------------------------------------------------------------
# Function: SetupLogrotate
#    Setup Logrotate so froxlor can make use of it
#---------------------------------------------------------------------
setupLogrotate() {

  # setting up logrotate according to froxlor config
  cat <<EOF > /etc/logrotate.d/froxlor
#
# Froxlor logrotate snipet
#
/var/customers/logs/*.log {
  missingok
  weekly
  rotate 4
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
  chmod 0644 "/etc/logrotate.d/froxlor"
  chown root:root "/etc/logrotate.d/froxlor"

}
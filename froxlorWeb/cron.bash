#---------------------------------------------------------------------
# Function: SetupCron
#    Setup a Cronjob for froxlor (though this should happen automatically by the end of installation process)
#---------------------------------------------------------------------
setupCron() {

  # setting up cron according to froxlor config
  cat <<EOF > /etc/cron.d/froxlor
#
# Set PATH, otherwise restart-scripts won't find start-stop-daemon
#
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#
# Regular cron jobs for the froxlor package
#
# Please check that all following paths are correct
#
*/5 * * * * root    /usr/bin/nice -n 5 /usr/bin/php -q /var/www/html/scripts/froxlor_master_cronjob.php
EOF
  chmod 0640 "/etc/cron.d/froxlor"
  chown root:root "/etc/cron.d/froxlor"
  start_spinner "Restarting cron"
  cmd="systemctl restart cron";
  _evalBg "${cmd}";

}
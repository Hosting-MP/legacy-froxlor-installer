#---------------------------------------------------------------------
# Function: SetupClamAV
#    Setup ClamAV to daily scan customer files
#---------------------------------------------------------------------
setupClamAV() {

  # setting up clamav
  mkdir /home/clamavinfected
  cat <<EOF > /etc/cron.daily/clamd-froxlor
  #!/bin/bash
clamscan --max-filesize=2G --max-scansize=2G --recursive --move=/home/clamavinfected --infected /var/customers
EOF
  sed -i 's/DatabaseMirror db.local.clamav.net/DatabaseMirror db.de.clamav.net/g' /etc/clamav/freshclam.conf

}

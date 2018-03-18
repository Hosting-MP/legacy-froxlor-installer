#---------------------------------------------------------------------
# Function: SetupClamAV
#    Setup ClamAV to daily scan customer files
#---------------------------------------------------------------------
setupClamAV() {

  # setting up clamav
  mkdir /home/clamavinfected
  cat <<EOF > /etc/cron.daily/clamd-froxlor
  #!/bin/bash
clamscan --max-filesize=20000M --max-scansize=20000M --recursive --move=/home/clamavinfected --infected /var/customers
EOF
  sed -i 's/DatabaseMirror db.local.clamav.net/DatabaseMirror db.de.clamav.net/g' /etc/clamav/freshclam.conf

}
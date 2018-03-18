#---------------------------------------------------------------------
# Function: SetupExtraUsers
#    Setup ExtraUsers so froxlor can make use of it
#---------------------------------------------------------------------
setupExtraUsers() {

  # setting up extrausers according to froxlor config
  mkdir -p /var/lib/extrausers
  touch /var/lib/extrausers/{passwd,group,shadow}
  rm /etc/nsswitch.conf
  touch /etc/nsswitch.conf
  chown root:root /etc/nsswitch.conf
  cat <<EOF > /etc/nsswitch.conf
# /etc/nsswitch.conf
#
# Example configuration of GNU Name Service Switch functionality.
# If you have the 'glibc-doc-reference' and 'info' packages installed, try:
# 'info libc "Name Service Switch"' for information about this file.

passwd:         compat extrausers
group:          compat extrausers
shadow:         compat extrausers
gshadow:        files

hosts:          files dns
networks:       files dns

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files
netmasks:       files
netgroup:       files
bootparams:     files

netgroup:       nis
EOF
  start_spinner "Restarting nscd..."
  cmd="systemctl restart nscd";
  _evalBg "${cmd}";
  nscd --invalidate=group

}
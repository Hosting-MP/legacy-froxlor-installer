#---------------------------------------------------------------------
# Function: SetupBind9
#    Setup Bind9 so froxlor can make use of it
#---------------------------------------------------------------------
setupBind9() {

  # setting up bind9 according to froxlor config
  echo "include \"/etc/bind/froxlor_bind.conf\";" >> /etc/bind/named.conf.local
  touch /etc/bind/froxlor_bind.conf
  chown bind:0 /etc/bind/froxlor_bind.conf
  chmod 0644 /etc/bind/froxlor_bind.conf
  start_spinner "Restarting nameserver..."
  cmd="systemctl restart bind9";
  _evalBg "${cmd}";

}
#---------------------------------------------------------------------
# Function: SetupUserdataINC
#    Setup UserdataINC to finish installation process and enable login
#---------------------------------------------------------------------
setupUserdataINC() {

  # setup login file
  froxlorrootName=
  if $createFroxlorRootPassword ; then
    froxlorrootName="froxlorroot"
  else
    froxlorrootName="root"
    froxlorrootpassword=$mdbpasswd
  fi
  cat <<EOF > /var/www/html/lib/userdata.inc.php
<?php
// automatically generated userdata.inc.php for Froxlor
\$sql['host']='localhost';
\$sql['user']='$froxlordatabasename';
\$sql['password']='$froxlorUnprivilegedPassword';
\$sql['db']='$froxlordatabasename';
\$sql_root[0]['caption']='Default';
\$sql_root[0]['host']='localhost';
\$sql_root[0]['user']='$froxlorrootName';
\$sql_root[0]['password']='$froxlorrootpassword';
// enable debugging to browser in case of SQL errors
\$sql['debug'] = false;
?>
EOF
  chown froxlorlocal:froxlorlocal /var/www/html/lib/userdata.inc.php

}
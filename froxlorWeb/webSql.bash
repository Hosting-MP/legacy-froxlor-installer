#---------------------------------------------------------------------
# Function: SetupWebSql
#    Setting values in database to enable all component installed
#---------------------------------------------------------------------
setupWebSql() {

  # enable quota in froxlor
  mysql -u root -p$mdbpasswd $froxlordatabasename <<EOF
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 144;
UPDATE panel_settings SET value = '/usr/sbin/quotatool' WHERE panel_settings.settingid = 146;
UPDATE panel_settings SET value = '$(findmnt -n -o SOURCE --target /var/customers)' WHERE panel_settings.settingid = 147;
EOF

  # enable webalizer in froxlor
  mysql -u root -p$mdbpasswd $froxlordatabasename <<EOF
UPDATE panel_settings SET value = '0' WHERE panel_settings.settingid = 109;
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 118;
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 119;
UPDATE panel_settings SET value = '/usr/share/awstats/tools/' WHERE panel_settings.settingid = 133;
UPDATE panel_settings SET value = '/usr/lib/cgi-bin/' WHERE panel_settings.settingid = 153;
EOF

  # enable php-fpm in froxlor
  mysql -u root -p$mdbpasswd $froxlordatabasename <<EOF
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 55;
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 67;
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 75;
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 139;
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 179;
EOF

  # set phpmyadmin url in froxlor
  mysql -u root -p$mdbpasswd $froxlordatabasename <<EOF
UPDATE panel_settings SET value = 'http://$( wget -qO- ipv4.icanhazip.com )/phpmyadmin' WHERE panel_settings.settingid = 217;
EOF

  # if it is Debian 9 or Ubuntu 16.04 - 18.04 enable mod_proxy_fcgi and libnss-extrausers
  if [ "`lsb_release -is`" = "Debian" ] || [ "`lsb_release -is`" = "Ubuntu" ]; then
    if [ "$(cat /etc/os-release | grep "VERSION_ID")" == "VERSION_ID=\"9\"" ] || [ "$(cat /etc/os-release | grep "VERSION_ID")" == "VERSION_ID=\"17.10\"" ] || [ "$(cat /etc/os-release | grep "VERSION_ID")" == "VERSION_ID=\"16.04\"" ] || [ "$(cat /etc/os-release | grep "VERSION_ID")" == "VERSION_ID=\"18.04\"" ]; then
      mysql -u root -p$mdbpasswd $froxlordatabasename <<EOF
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 75;
UPDATE panel_settings SET value = '1' WHERE panel_settings.settingid = 212;
EOF
    fi
  fi

}
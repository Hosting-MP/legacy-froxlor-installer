#---------------------------------------------------------------------
# Function: SetupQuota
#    Enable system quota
#---------------------------------------------------------------------
setupQuota() {

  # first install system quota components
  start_spinner "Installing system quota..."
  cmd="apt-get install -y quota quotatool";
  _evalBg "${cmd}";


  # get mount point of directory as in fstab
  if [ "$(df -PT "/var/www/html" | awk 'NR==2 {print $2}')" = "ext4" ]; then
    fstabWro="$(df "/var/www/html" | tail -1 | awk '{ print $6 }')       ext4    errors=remount-ro"
    fstabDefaults="$(df "/var/www/html" | tail -1 | awk '{ print $6 }')       ext4    defaults"
  elif [ "$(df -PT "/var/www/html" | awk 'NR==2 {print $2}')" = "ext3" ]; then
    fstabWro="$(df "/var/www/html" | tail -1 | awk '{ print $6 }')       ext3    errors=remount-ro"
    fstabDefaults="$(df "/var/www/html" | tail -1 | awk '{ print $6 }')       ext3    defaults"
  else
    fstabWro="errors=remount-ro"
    fstabDefaults="defaults"
  fi


  # enable quota and check for virtualized environments
  if ! [ -f /proc/user_beancounters ]; then
    if [ `cat /etc/fstab | grep ',usrjquota' | wc -l` -eq 0 ] || [ `cat /etc/fstab | grep ',grpjquota' | wc -l` -eq 0 ] || [ `cat /etc/fstab | grep ',usrquota' | wc -l` -eq 0 ] || [ `cat /etc/fstab | grep ',grpquota' | wc -l` -eq 0 ]; then
      sed -i "s/$fstabWro/$fstabWro,usrquota,grpquota/g" /etc/fstab
      sed -i "s/$fstabDefaults/$fstabDefaults,usrquota,grpquota/g" /etc/fstab
      start_spinner "Remounting filesystem to enable quota"
      cmd="mount -o remount /"
      _evalBg "${cmd}"
      if quotacheck -acugm; then
        if [ -f /aquota.user ]; then
          touch /aquota.user
          chmod 600 /aquota.user
        fi
        if [ -f /aquota.group ]; then
          touch /aquota.group
          chmod 600 /aquota.group
        fi
        quotaon -aug
        # if command above failed it is likely that this is a virtualized enviroment with journaled quota but we check that before
      elif [ "$(grep -i QFMT_V2 /boot/config-`uname -r`)" == "CONFIG_QFMT_V2=y" ] || [ "$(grep -i QFMT_V2 /boot/config-`uname -r`)" == "CONFIG_QFMT_V2=m" ]; then
        if quotacheck -F vfsv1 -acugm; then
          sed -i 's/errors=remount-ro,usrquota,grpquota/errors=remount-ro,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv1/g' /etc/fstab
          sed -i 's/defaults,usrquota,grpquota/defaults,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv1/g' /etc/fstab
          modprobe quota_v1
          modprobe quota_v2
          start_spinner "Remounting filesystem to enable journaled quota"
          cmd="mount -o remount /"
          _evalBg "${cmd}"
          quotacheck -F vfsv1 -acugmf
          quotaon -F vfsv1 -aug
        # maybe it is an older version of filesystem (probably oVZ)
        elif quotacheck -F vfsv0 -acugm; then
          sed -i 's/errors=remount-ro,usrquota,grpquota/errors=remount-ro,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0/g' /etc/fstab
          sed -i 's/defaults,usrquota,grpquota/defaults,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0/g' /etc/fstab
          modprobe quota_v1
          modprobe quota_v2
          start_spinner "Remounting filesystem to enable journaled quota"
          cmd="mount -o remount /"
          _evalBg "${cmd}"
          quotacheck -F vfsv0 -acugmf
          quotaon -F vfsv0 -aug
        else
          # create quoter files ..just in case
          touch /aquota.user /aquota.group
          chmod 600 /aquota.user
          chmod 600 /aquota.group
          quotaoff -af
          # removing applied quota tags if activating quota is not possible
          sed -i 's/errors=remount-ro,usrquota,grpquota/errors=remount-ro/g' /etc/fstab
          sed -i 's/errors=remount-ro,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv1/errors=remount-ro/g' /etc/fstab
          sed -i 's/errors=remount-ro,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0/errors=remount-ro/g' /etc/fstab
          sed -i 's/defaults,usrquota,grpquota/defaults/g' /etc/fstab
          sed -i 's/defaults,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv1/defaults/g' /etc/fstab
          sed -i 's/defaults,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0/defaults/g' /etc/fstab
          echo -e "Enabling quotas \e[31mfailed\e[0m (already enabled?)"
          start_spinner "Remounting filesystem to disable journaled quota"
          cmd="mount -o remount /"
          _evalBg "${cmd}";
        fi
	  else
        # leave quota files ..just in case
        quotaoff -af
        # removing applied quota tags if activating quota is not possible
		# w/ remount on error
        sed -i 's/errors=remount-ro,usrquota,grpquota/errors=remount-ro/g' /etc/fstab
        sed -i 's/errors=remount-ro,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv1/errors=remount-ro/g' /etc/fstab
        sed -i 's/errors=remount-ro,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0/errors=remount-ro/g' /etc/fstab
		# w/ defauls
        sed -i 's/defaults,usrquota,grpquota/defaults/g' /etc/fstab
        sed -i 's/defaults,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv1/defaults/g' /etc/fstab
        sed -i 's/defaults,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0/defaults/g' /etc/fstab
		# reverted all changes so remount to have everything as before/default
        echo -e "Enabling quotas \e[31mfailed\e[0m (already enabled?)"
        start_spinner "Remounting filesystem to disable quota"
        cmd="mount -o remount /"
        _evalBg "${cmd}";
      fi
	else
	  echo -e "It looks like quota is already installed so not modifying it"
    fi
  fi

}
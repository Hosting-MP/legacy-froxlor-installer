#---------------------------------------------------------------------
# Function: SetupAwstats
#    Setup Awstats so froxlor can make use of it
#---------------------------------------------------------------------
setupAwstats() {

  # setting up awstats according to froxlor config
  cp /usr/share/awstats/tools/awstats_buildstaticpages.pl /usr/bin/
  ln -s /etc/awstats/awstats.conf /etc/awstats/awstats.model.conf
  sed -i.bak 's/^DirData/# DirData/' /etc/awstats//awstats.model.conf
  sed -i.bak 's|^\\(DirIcons=\\).*$|\\1\\"/awstats-icon\\"|' /etc/awstats//awstats.model.conf
  rm /etc/cron.d/awstats

}
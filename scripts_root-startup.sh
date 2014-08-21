#! /bin/sh
# /root/scripts/root-startup.sh
#

# Some things that run at startup
# Should be called from /etc/init.d/root-startup

MY_LOG_FILE=~root/scripts/root-startup.log 2>&1

date                            >> $MY_LOG_FILE
~root/scripts/checkip.sh        >> $MY_LOG_FILE
~root/scripts/tz-update.sh      >> $MY_LOG_FILE
~root/scripts/allfiles.sh       >> $MY_LOG_FILE
~root/scripts/hostname-set.sh   >> $MY_LOG_FILE

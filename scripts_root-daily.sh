#!/bin/sh

# Alan Meyer
# https://github.com/alanmeyer

# Called by cron
# crontab -e to edit when called

MY_LOG_FILE=~root/scripts/root-daily.log
MY_DATE=`date +"%Y-%m-%d"`
MY_TIME=`date +"%T"`
MY_DATE_TIME="$MY_DATE"" ""$MY_TIME"

echo $MY_DATE_TIME Start                            >> $MY_LOG_FILE
who -q | grep users                                 >> $MY_LOG_FILE
cat /var/log/auth.log | grep "Failed password"      >> $MY_LOG_FILE
~root/scripts/allfiles.sh                           >> $MY_LOG_FILE
~root/scripts/updateall.sh                          >> $MY_LOG_FILE
~root/scripts/letsencrypt/letsencrypt-auto renew    >> $MY_LOG_FILE
/var/www/www-data.sh                                >> $MY_LOG_FILE
echo $MY_DATE_TIME Finish                           >> $MY_LOG_FILE
#echo $MY_DATE_TIME Reboot                           >> $MY_LOG_FILE
#reboot

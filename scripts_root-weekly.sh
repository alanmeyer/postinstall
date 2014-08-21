#!/bin/sh

# Called by cron
# crontab -e to edit when called

MY_LOG_FILE=~root/scripts/root-weekly.log
MY_DATE=`date +"%Y-%m-%d"`
MY_TIME=`date +"%T"`
MY_DATE_TIME="$MY_DATE"" ""$MY_TIME"

echo $MY_DATE_TIME Start                        >> $MY_LOG_FILE
echo $MY_DATE_TIME Finish                       >> $MY_LOG_FILE
echo $MY_DATE_TIME Reboot                       >> $MY_LOG_FILE
/bin/sync
/sbin/reboot

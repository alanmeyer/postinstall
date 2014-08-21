#!/bin/bash
# http://www.dslreports.com/forum/r27923249-new-automation-address-for-a-script-to-find-public-ip-
# ATM 2013-05-21

wget --quiet -O - http://checkip.dyndns.org | sed -e 's/^.*Current IP Address: //g' -e 's/<.*$//g'

exit 0

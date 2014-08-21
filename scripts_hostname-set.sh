#!/bin/sh
# Alan Meyer
# https://github.com/alanmeyer/postinstall
# Note: Use this to update host information
#       Useful on VPS that resets the host information
#       Add this to the boot-time scripts
IP=<set_by_script>
HOST=<set_by_script>
DOMAIN=<set_by_script>
FQDN=$HOST"."$DOMAIN
# Note: Be sure FQDN appears first
sed -i 's/'$IP'.*/'$IP' '$FQDN' '$HOST' localhost localhost.localdomain/g' /etc/hosts
echo $HOST > /etc/hostname
service hostname restart
hostname
hostname -f

#! /bin/sh
# /root/scripts/pubkey-add.sh
#
# Add a public key that is reported missing during apt-get update

SERVER=subkeys.pgp.net
sudo apt-key adv --keyserver hkp://$SERVER --recv-keys $1

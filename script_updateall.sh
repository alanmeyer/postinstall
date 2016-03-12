#!/bin/sh

# Alan Meyer
# https://github.com/alanmeyer

apt-get clean -y -qq
apt-get autoclean -y -qq
dpkg --configure -a
dpkg --clear-avail
apt-get install -f -y -qq
apt-get --fix-missing install -y -qq
apt-get --purge autoremove -y -qq
apt-get --fix-missing update -y -qq
apt-get update -y -qq
apt-get dist-upgrade -y -qq

#!/bin/sh

# Alan Meyer
# https://github.com/alanmeyer

MY_LE_DIR=/etc/letsencrypt/live/ocmeyer.com
MY_SSL_DIR=/etc/apache2/ssl
MY_SCR_DIR=~/scripts

MY_PEM_0=linkpems.sh
MY_PEM_1=chain.pem
MY_PEM_2=fullchain.pem
MY_PEM_3=privkey.pem
MY_PEM_4=cert.pem

rm -f $MY_SSL_DIR/$MY_PEM_0
rm -f $MY_SSL_DIR/$MY_PEM_1
rm -f $MY_SSL_DIR/$MY_PEM_2
rm -f $MY_SSL_DIR/$MY_PEM_3
rm -f $MY_SSL_DIR/$MY_PEM_4

ln -s $MY_SCR_DIR/$MY_PEM_0 $MY_SSL_DIR/$MY_PEM_0
ln -s $MY_LE_DIR/$MY_PEM_1  $MY_SSL_DIR/$MY_PEM_1
ln -s $MY_LE_DIR/$MY_PEM_2  $MY_SSL_DIR/$MY_PEM_2
ln -s $MY_LE_DIR/$MY_PEM_3  $MY_SSL_DIR/$MY_PEM_3
ln -s $MY_LE_DIR/$MY_PEM_4  $MY_SSL_DIR/$MY_PEM_4

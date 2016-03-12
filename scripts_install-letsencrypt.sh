#!/bin/sh

# Alan Meyer
# https://github.com/alanmeyer

MY_SCR_DIR=~/scripts

# https://letsencrypt.org/getting-started/

cd $MY_SCR_DIR
git clone https://github.com/letsencrypt/letsencrypt
cd $MY_SCR_DIR/letsencrypt
./letsencrypt-auto --help

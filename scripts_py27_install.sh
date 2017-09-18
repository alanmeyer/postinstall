#!/bin/bash

# Alan Meyer
# https://github.com/alanmeyer/postinstall

# Called by cron
# crontab -e to edit when called

MY_LOG_FILE=~/scripts/py27_install.log
MY_DATE=`date +"%Y-%m-%d"`
MY_TIME=`date +"%T"`
MY_DATE_TIME="$MY_DATE"" ""$MY_TIME"

echo $MY_DATE_TIME Start                                        >> $MY_LOG_FILE
# https://danieleriksson.net/2017/02/08/how-to-install-latest-python-on-centos/
# Python 2.7.13:
wget http://python.org/ftp/python/2.7.13/Python-2.7.13.tar.xz   >> $MY_LOG_FILE
tar xf Python-2.7.13.tar.xz                                     >> $MY_LOG_FILE
cd Python-2.7.13                                                >> $MY_LOG_FILE
./configure --prefix=/usr/local --enable-unicode=ucs4 --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib" >> $MY_LOG_FILE
make && make altinstall                                         >> $MY_LOG_FILE
cd ..                                                           >> $MY_LOG_FILE

## Python 3.6.2:
#wget http://python.org/ftp/python/3.6.2/Python-3.6.2.tar.xz
#tar xf Python-3.6.2.tar.xz
#cd Python-3.6.2
#./configure --prefix=/usr/local --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
#make && make altinstall

# Strip the Python 2.7 binary:
strip /usr/local/lib/libpython2.7.so.1.0
## Strip the Python 3.6 binary:
#strip /usr/local/lib/libpython3.6m.so.1.0

alias python27=/usr/local/bin/python2.7
alias python2.7=/usr/local/bin/python2.7
echo 'alias python27=/usr/local/bin/python2.7' | tee -a ~/.bashrc
echo 'alias python2.7=/usr/local/bin/python2.7' | tee -a ~/.bashrc

wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py
# Then execute it using Python 2.7 and/or Python 3.6:
#python get-pip.py
#python2.7 get-pip.py
## python3.6 get-pip.py
#pip install --upgrade pip

echo $MY_DATE_TIME Finish                                       >> $MY_LOG_FILE

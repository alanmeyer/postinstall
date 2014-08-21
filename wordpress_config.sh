#!/bin/sh
# Wordpress Configuration
# Alan Meyer
# https://github.com/alanmeyer/postinstall
# https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-on-ubuntu-14-04

APT_INSTALL='apt-get -y -f --allow-unauthenticated install'

cd ~
wget http://wordpress.org/latest.tar.gz -O latest.tar.gz
tar xzvf latest.tar.gz
sudo apt-get update
$APT_INSTALL php5-gd libssh2-php
cd wordpress
cp wp-config-sample.php wp-config.php
sed -i "s/^\(define('DB_NAME',\).*/\1 'wordpress');/g"            wp-config.php
sed -i "s/^\(define('DB_USER',\).*/\1 'wordpress');/g"            wp-config.php
sed -i "s/^\(define('DB_PASSWORD',\).*/\1 'default_password');/g" wp-config.php
rsync -avP ~/wordpress/ /var/www/html
rm -r ~/wordpress
mkdir -p /var/www/html/wp-content/uploads
cd /var/www/html
sudo chown -R www-data:www-data *
echo '#!/bin/sh'                       | tee    /var/www/www-data.sh
echo 'chown -R www-data:www-data html' | tee -a /var/www/www-data.sh
chmod +x /var/www/www-data.sh

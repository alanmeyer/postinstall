#!/bin/sh
# Apache2 SSL Configuration
# Alan Meyer
# https://github.com/alanmeyer/postinstall

GIT_SHARE=<from_config_script>
APACHE_SSL_DIR=/etc/apache2/ssl
APACHE_SITES_DIR=/etc/apache2/sites-available

if [ "$#" -ne 3 ]; then
    echo "usage: apache2_ssl_config.sh hostname domain maildomain webdomain"
    exit 1;
fi

echo "fqdn:        " $1.$2
echo "mail domain: " $3
echo "web domain:  " $4

a2enmod ssl
service apache2 stop

rm -f apache2_ssl_ssl.crt
rm -f apache2_ssl_ca-bundle.pem
rm -f apache2_ssl_000-default.conf
rm -f apache2_ssl_private-encrypted.key

wget $GIT_SHARE/apache2_ssl_ssl.crt
wget $GIT_SHARE/apache2_ssl_ca-bundle.pem
wget $GIT_SHARE/apache2_ssl_000-default.conf

mkdir -p $APACHE_SSL_DIR
mv apache2_ssl_ssl.crt          $APACHE_SSL_DIR/ssl.crt
mv apache2_ssl_ca-bundle.pem    $APACHE_SSL_DIR/ca-bundle.pem
mv apache2_ssl_000-default.conf $APACHE_SITES_DIR/000-default.conf

sed -i 's,\(ServerName\),\1 '"$4"',g'               $APACHE_SITES_DIR/000-default.conf
sed -i 's,\(Redirect\),\1 https://'"$4"',g'         $APACHE_SITES_DIR/000-default.conf
sed -i 's,\(ServerAdmin\),\1 webmaster@'"$3"',g'    $APACHE_SITES_DIR/000-default.conf

wget $GIT_SHARE/apache2_ssl_private-encrypted.key
openssl rsa -in apache2_ssl_private-encrypted.key -out apache2_ssl_private.key
mv apache2_ssl_private.key $APACHE_SSL_DIR/private.key
rm -f apache2_ssl_private-encrypted.key
service apache2 start

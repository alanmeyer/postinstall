#!/bin/sh
# Alan Meyer
# https://github.com/alanmeyer/postinstall

APT_INSTALL='apt-get -y -f --allow-unauthenticated install'

if [ "$#" -ne 3 ]; then
    echo "usage: dovecot_config.sh hostname domain maildomain"
    exit 1;
fi

echo "fqdn:        " $1.$2
echo "mail domain: " $3

export DEBIAN_FRONTEND=noninteractive 
$APT_INSTALL dovecot-core dovecot-imapd

# Stop
service dovecot stop
service postfix stop

# Backup original files
cp -n /etc/postfix/main.cf                  /etc/postfix/main.cf.orig.dovecot
cp -n /etc/postfix/master.cf                /etc/postfix/master.cf.orig.dovecot
cp -n /etc/dovecot/conf.d/10-auth.conf      /etc/dovecot/conf.d/10-auth.conf.orig
cp -n /etc/dovecot/conf.d/10-mail.conf      /etc/dovecot/conf.d/10-mail.conf.orig
cp -n /etc/dovecot/conf.d/10-master.conf    /etc/dovecot/conf.d/10-master.conf.orig
cp -n /etc/dovecot/conf.d/10-ssl.conf       /etc/dovecot/conf.d/10-ssl.conf.orig
cp -n /etc/dovecot/conf.d/15-lda.conf       /etc/dovecot/conf.d/15-lda.conf.orig

# Copy the originals back (in case this script is run multiple times)
cp /etc/postfix/main.cf.orig.dovecot        /etc/postfix/main.cf
cp /etc/postfix/master.cf.orig.dovecot      /etc/postfix/master.cf
cp /etc/dovecot/conf.d/10-auth.conf.orig    /etc/dovecot/conf.d/10-auth.conf
cp /etc/dovecot/conf.d/10-mail.conf.orig    /etc/dovecot/conf.d/10-mail.conf
cp /etc/dovecot/conf.d/10-master.conf.orig  /etc/dovecot/conf.d/10-master.conf
cp /etc/dovecot/conf.d/10-ssl.conf.orig     /etc/dovecot/conf.d/10-ssl.conf
cp /etc/dovecot/conf.d/15-lda.conf.orig     /etc/dovecot/conf.d/15-lda.conf


# Create the new keys
rm -f server.key server.crt server.csr
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj /C=US/ST=CA/L=LA/O=SERVER/CN=$3
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
mv server.crt /etc/ssl/certs
mv server.key /etc/ssl/private
rm -f server.csr

# Update Postfix /etc/postfix/main.cf and master.cf to support Dovecot
postconf -e 'smtpd_tls_key_file = /etc/ssl/private/server.key'
postconf -e 'smtpd_tls_cert_file = /etc/ssl/certs/server.crt'
postconf -e 'home_mailbox = Maildir/'
postconf -e 'smtpd_sasl_type = dovecot'
postconf -e 'smtpd_sasl_path = private/auth'
postconf -e 'smtpd_sasl_local_domain ='
postconf -e 'smtpd_sasl_security_options = noanonymous'
postconf -e 'broken_sasl_auth_clients = yes'
postconf -e 'smtpd_sasl_auth_enable = yes'
postconf -e 'smtpd_recipient_restrictions = permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination'
postconf -e 'smtp_tls_security_level = may'
postconf -e 'smtpd_tls_security_level = may'
postconf -e 'smtp_tls_note_starttls_offer = yes'
postconf -e 'smtpd_tls_loglevel = 1'
postconf -e 'smtpd_tls_received_header = yes'

postconf -M submission/inet="submission   inet   n   -   n   -   -   smtpd"
postconf -P submission/inet/syslog_name=postfix/submission
postconf -P submission/inet/smtpd_tls_security_level=encrypt
postconf -P submission/inet/smtpd_sasl_auth_enable=yes
postconf -P submission/inet/smtpd_relay_restrictions=permit_sasl_authenticated,reject
postconf -P submission/inet/milter_macro_daemon_name=ORIGINATING

# Master config change
#wget https://raw.github.com/alanmeyer/postinstall/master/dovecot_10-master.conf -O /etc/dovecot/conf.d/10-master.conf
sed -n '1h;1!H;${;g;s/#\(unix_listener \/var\/spool\/postfix\/private\/auth\).*  #\}/\1 \{\n    mode = 0660\n    user = postfix\n    group = postfix\n  \}/g;p;}' /etc/dovecot/conf.d/10-master.conf.orig > /etc/dovecot/conf.d/10-master.conf

# Auth config change
sed -i 's,\(auth_mechanisms\).*,\1 = plain login,g'                 /etc/dovecot/conf.d/10-auth.conf
sed -i 's,\(disable_plaintext_auth\).*,\1 = yes,g'                  /etc/dovecot/conf.d/10-auth.conf

# Mail config change
# http://wiki2.dovecot.org/BasicConfiguration
sed -i 's,#\(mail_privileged_group =\).*,\1 mail,g'                 /etc/dovecot/conf.d/10-mail.conf

# SSL config change
sed -i 's,#\(ssl = yes\),\1,g'                                      /etc/dovecot/conf.d/10-ssl.conf

# LDA config change
sed -i 's,^#\(postmaster_address\).*,\1 = postmaster@'"$3"',g'      /etc/dovecot/conf.d/15-lda.conf
sed -i 's,^#\(hostname\).*,\1 = '"$1.$2"',g'                        /etc/dovecot/conf.d/15-lda.conf

# Final step
service postfix start
service dovecot start

# Test
# Note: 993, 143 = IMAP
# Note: 110, 995 = POP3
## telnet server.ocmeyer.com 993
### Trying 127.0.0.1...
### Connected to localhost.
### Escape character is '^]'.
### +OK Dovecot (Ubuntu) ready.
#
## telnet server.ocmeyer.com 143
## telnet server.ocmeyer.com 110
## telnet server.ocmeyer.com 995
#
## netstat-nl4

# Configuration file 
# Alan Meyer
# https://github.com/alanmeyer/postinstall
#
# Amavis Spamassassin ClamAV
# https://help.ubuntu.com/community/PostfixAmavisNew

APT_INSTALL='apt-get -y -f --allow-unauthenticated install'

if [ "$#" -ne 3 ]; then
    echo "usage: spamfilter_config.sh hostname domain maildomain"
    exit 1;
fi

echo "fqdn:        " $1.$2
echo "mail domain: " $3

export DEBIAN_FRONTEND=noninteractive 

#$APT_INSTALL amavisd-new spamassassin clamav-daemon spamc
#$APT_INSTALL libnet-dns-perl libmail-spf-perl pyzor razor

service postfix stop
service amavis stop
service spamassassin stop

adduser clamav amavis
adduser amavis clamav

# upgrade the filters
freshclam

#   Save original config files (once only -n)
#   Note: Copy back in case the config is re-run
cp -n /etc/default/spamassassin                         /etc/default/spamassassin.orig
cp -n /etc/amavis/conf.d/15-content_filter_mode         /etc/amavis/conf.d/15-content_filter_mode.orig
cp -n /etc/amavis/conf.d/05-node_id                     /etc/amavis/conf.d/05-node_id.orig
cp -n /etc/postfix/main.cf                              /etc/postfix/main.cf.amavis
cp -n /etc/postfix/master.cf                            /etc/postfix/master.cf.amavis
cp    /etc/default/spamassassin.orig                    /etc/default/spamassassin
cp    /etc/amavis/conf.d/15-content_filter_mode.orig    /etc/amavis/conf.d/15-content_filter_mode
cp    /etc/amavis/conf.d/05-node_id.orig                /etc/amavis/conf.d/05-node_id
cp    /etc/postfix/main.cf.amavis                       /etc/postfix/main.cf
cp    /etc/postfix/master.cf.amavis                     /etc/postfix/master.cf

sed -i 's/^\(ENABLED\).*/\1=1/g'                        /etc/default/spamassassin
sed -i 's/^\(CRON\).*/\1=1/g'                           /etc/default/spamassassin

sed -i 's/^#\(@bypass_.*\)/\1/g'                        /etc/amavis/conf.d/15-content_filter_mode
sed -i 's/^#\(   \\.*\)/\1/g'                           /etc/amavis/conf.d/15-content_filter_mode

sed -i 's/^#\($myhostname\).*/\1 = '\"$1.$2\"';/g'      /etc/amavis/conf.d/05-node_id

postconf -e "content_filter = smtp-amavis:[127.0.0.1]:10024"

postconf -M smtp-amavis/unix="smtp-amavis     unix    -       -       -       -       2       smtp"
postconf -P smtp-amavis/unix/smtp_data_done_timeout=1200
postconf -P smtp-amavis/unix/smtp_send_xforward_command=yes
postconf -P smtp-amavis/unix/disable_dns_lookups=yes
postconf -P smtp-amavis/unix/max_use=20

postconf -M 127.0.0.1:10025/inet="127.0.0.1:10025 inet    n       -       -       -       -       smtpd"
postconf -P 127.0.0.1:10025/inet/content_filter=
postconf -P 127.0.0.1:10025/inet/local_recipient_maps=
postconf -P 127.0.0.1:10025/inet/relay_recipient_maps=
postconf -P 127.0.0.1:10025/inet/smtpd_restriction_classes=
postconf -P 127.0.0.1:10025/inet/smtpd_delay_reject=no
postconf -P 127.0.0.1:10025/inet/smtpd_client_restrictions=permit_mynetworks,reject
postconf -P 127.0.0.1:10025/inet/smtpd_helo_restrictions=
postconf -P 127.0.0.1:10025/inet/smtpd_sender_restrictions=
postconf -P 127.0.0.1:10025/inet/smtpd_recipient_restrictions=permit_mynetworks,reject
postconf -P 127.0.0.1:10025/inet/smtpd_data_restrictions=reject_unauth_pipelining
postconf -P 127.0.0.1:10025/inet/smtpd_end_of_data_restrictions=
postconf -P 127.0.0.1:10025/inet/mynetworks=127.0.0.0/8
postconf -P 127.0.0.1:10025/inet/smtpd_error_sleep_time=0
postconf -P 127.0.0.1:10025/inet/smtpd_soft_error_limit=1001
postconf -P 127.0.0.1:10025/inet/smtpd_hard_error_limit=1000
postconf -P 127.0.0.1:10025/inet/smtpd_client_connection_count_limit=0
postconf -P 127.0.0.1:10025/inet/smtpd_client_connection_rate_limit=0
postconf -P 127.0.0.1:10025/inet/receive_override_options=no_header_body_checks,no_unknown_recipient_checks

postconf -P pickup/unix/content_filter=
postconf -P pickup/unix/receive_override_options=no_header_body_checks

service spamassassin start
service amavis start
service postfix start

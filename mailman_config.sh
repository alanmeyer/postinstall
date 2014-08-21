#!/bin/sh
# Alan Meyer
# https://github.com/alanmeyer/postinstall

MM_CONF=/etc/mailman/mm_cfg.py
APACHE_CONF=/etc/mailman/apache.conf
POSTFIX_MAIN=/etc/postfix/main.cf
POSTFIX_MASTER=/etc/postfix/master.cf
APT_INSTALL='apt-get -y -f --allow-unauthenticated install'

if [ "$#" -ne 3 ]; then
    echo "usage: mailman_config.sh hostname domain maildomain"
    exit 1;
fi

echo "fqdn:        " $1.$2
echo "mail domain: " $3

export DEBIAN_FRONTEND=noninteractive
$APT_INSTALL mailman

# Backup original files (once) & copy back if running multiple times
cp -n $MM_CONF                  $MM_CONF".orig"
cp -n $APACHE_CONF              $APACHE_CONF".orig"
cp -n $POSTFIX_MAIN             $POSTFIX_MAIN".orig.mm"
cp -n $POSTFIX_MASTER           $POSTFIX_MASTER".orig.mm"
cp    $MM_CONF".orig"           $MM_CONF
cp    $APACHE_CONF".orig"       $APACHE_CONF
cp    $POSTFIX_MAIN".orig.mm"   $POSTFIX_MAIN
cp    $POSTFIX_MASTER".orig.mm" $POSTFIX_MASTER


service mailman stop
service dovecot stop
service postfix stop
service apache2 stop

# Create the mailman list using a default password
# then change the mail to a random value for now
# http://wiki.list.org/pages/viewpage.action?pageId=4030543
rmlist -a mailman
newlist -q -l en -u $3 -e $3 mailman administrator@$3 password
/usr/lib/mailman/bin/change_pw -l mailman

# Link into apache
ln -s -f $APACHE_CONF /etc/apache2/sites-enabled/mailman

# Stop using postfix-to-mailman.py
rm -f /etc/mailman/postfix-to-mailman.py
rm -f /etc/mailman/qmail-to-mailman.py
postconf -M# mailman/unix

# http://www.list.org/mailman-install/node12.html
postconf -e 'recipient_delimiter = +'
postconf -e 'unknown_local_recipient_reject_code = 550'

# http://www.list.org/mailman-install/postfix-integration.html
# DEFAULT_EMAIL_HOST = Default domain for email addresses of newly created MLs
# DEFAULT_URL_HOST   = Default host for web interface of newly created MLs
# Note: use x27 as ' escape when nested
sed -i 's/^# \(MTA=\x27Postfix\x27\).*/\1/g'                $MM_CONF
sed -i 's/^\(DEFAULT_EMAIL_HOST\).*/\1 = '\'$3\''/g'        $MM_CONF
sed -i 's/^\(DEFAULT_URL_HOST\).*/\1 = '\'$1.$2\''/g'       $MM_CONF


# http://hswong3i.net/blog/hswong3i/some-suggested-default-setup-new-mailman-list
echo                                               | tee -a $MM_CONF
echo '#------------------------------------------' | tee -a $MM_CONF
echo '# Custom Settiugs'                           | tee -a $MM_CONF
echo 'DEFAULT_ARCHIVE_PRIVATE = 1'                 | tee -a $MM_CONF
echo 'DEFAULT_GENERIC_NONMEMBER_ACTION = 3'        | tee -a $MM_CONF
echo 'DEFAULT_LIST_ADVERTISED = No'                | tee -a $MM_CONF
echo 'DEFAULT_MAX_MESSAGE_SIZE = 0'                | tee -a $MM_CONF
echo 'DEFAULT_MSG_FOOTER = ""'                     | tee -a $MM_CONF
echo 'DEFAULT_MSG_HEADER = ""'                     | tee -a $MM_CONF
echo 'DEFAULT_REQUIRE_EXPLICIT_DESTINATION = No'   | tee -a $MM_CONF

/var/lib/mailman/bin/genaliases
chown list:list /var/lib/mailman/data/aliases*
chmod g+w /var/lib/mailman/data/aliases*
postconf -e 'alias_maps = hash:/etc/aliases, hash:/var/lib/mailman/data/aliases'

service apache2 start
service postfix start
service dovecot start
service mailman start

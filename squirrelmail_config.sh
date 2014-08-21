#!/bin/sh
# Alan Meyer
# https://github.com/alanmeyer/postinstall

CONFIG_FILE=/etc/squirrelmail/config.php
APT_INSTALL='apt-get -y -f --allow-unauthenticated install'

if [ "$#" -ne 3 ]; then
    echo "usage: squirrelmail_config.sh hostname domain maildomain"
    exit 1;
fi

echo "fqdn:        " $1.$2
echo "mail domain: " $3

export DEBIAN_FRONTEND=noninteractive
#$APT_INSTALL squirrelmail

# Backup original files (once) & copy back if running multiple times
cp -n $CONFIG_FILE        $CONFIG_FILE".orig"
cp    $CONFIG_FILE".orig" $CONFIG_FILE

sed -i 's,^\($org_name\).*,\1 = '"\"$1.$2\""';,g'               $CONFIG_FILE
sed -i 's,^\($org_logo_width\).*,\1 = '\'175\'';,g'             $CONFIG_FILE
sed -i 's,^\($org_logo_height\).*,\1 = '\'165\'';,g'            $CONFIG_FILE
sed -i 's,^\($org_title\).*,\1 = '"\"$1.$2\""';,g'              $CONFIG_FILE
sed -i 's,^\($provider_uri\).*,\1 = '\''https://'$1.$2\'';,g'   $CONFIG_FILE
sed -i 's,^\($provider_name\).*,\1 = '\'"$1"\'';,g'             $CONFIG_FILE
sed -i 's,^\($imap_server_type\).*,\1 = '\'dovecot\'';,g'       $CONFIG_FILE
sed -i 's,^\($trash_folder\).*,\1 = '\'Trash\'';,g'             $CONFIG_FILE
sed -i 's,^\($sent_folder\).*,\1 = '\'Sent\'';,g'               $CONFIG_FILE
sed -i 's,^\($draft_folder\).*,\1 = '\'Drafts\'';,g'            $CONFIG_FILE
sed -i 's,^\($default_sub_of_inbox\).*,\1 = false;,g'           $CONFIG_FILE
sed -i 's,^\($force_username_lowercase\).*,\1 = true;,g'        $CONFIG_FILE

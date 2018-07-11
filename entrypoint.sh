#!/bin/ash

set -x

# Changing the open file descriptors limit, otherwise slapd memory
# consumption is crazy
# https://github.com/moby/moby/issues/8231
ulimit -n 1024

if [ ! -d /root/init.d ]; then

    slapadd -n0 -l /tmp/config.ldif -F /etc/openldap/slapd.d/

    rm -rf /root/init.d
    mkdir /root/init.d
    cp -ar /ldap-init.d/config  /root/init.d
    cp -ar /ldap-init.d/data  /root/init.d

    /usr/sbin/slapd -h "ldap:/// ldaps:/// ldapi://localhost/" -d $DEBUG_LEVEL &
    sleep 3

    CONFIG_PWD=$(slappasswd -h "{BCRYPT}" -o module-load="/usr/lib/openldap/pw-bcrypt.so" -s $LDAP_CONFIG_PASSWORD)
    ROOT_PWD=$(slappasswd -h "{BCRYPT}" -o module-load="/usr/lib/openldap/pw-bcrypt.so" -s lb7367mo -s $LDAP_ROOT_PASSWORD)

    if [ -d /root/init.d/config ]; then
        for f in /root/init.d/config/*; do
            sed -i -e "s+%LDAP_ROOT_PASSWORD%+${ROOT_PWD//+/\\+}+g" -e "s+%LDAP_CONFIG_PASSWORD%+${CONFIG_PWD//+/\\+}+g" -e "s+%LDAP_DOMAIN%+${LDAP_DOMAIN//+/\\+}+g" -e "s+%LDAP_ROOT_DN%+${LDAP_ROOT_DN//+/\\+}+g" $f

            cat $f
            ldapmodify -Y EXTERNAL -H ldapi://localhost/ -f $f
        done
    fi

    if [ -d /root/init.d/data ]; then
        for f in /root/init.d/data/*; do
            sed -i -e "s+%LDAP_DOMAIN%+${LDAP_DOMAIN//+/\\+}+g" $f
            ldapadd -x -D $LDAP_ROOT_DN -w $LDAP_ROOT_PASSWORD -f $f
        done
    fi

    pkill slapd
    sleep 3

fi

exec /usr/sbin/slapd -h "ldap:/// ldaps:/// ldapi://localhost/" -d $DEBUG_LEVEL
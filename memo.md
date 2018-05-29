docker run -it --rm --name ldap -v $PWD/data:/tmp/data -p 389:389 alpine ash
docker run -it --rm --name ldap -p 389:389 alpine ash

docker run -it --rm --name ldap -v $PWD/data:/tmp/data -p 389:389 ldap ash

apk update
apk add openldap openldap-overlay-all openldap-clients 
apk add openldap-back-hdb openldap-back-bdb openldap-back-mdb ldapvi

mkdir /run/openldap
chown ldap:ldap /run/openldap
vi /etc/openldap/slapd.conf
slapd -u ldap -g ldap -d 256 -h "ldap:/// ldapi:///" -F /etc/openldap/slapd.d

/usr/sbin/slapadd -n0 -F "/etc/openldap/slapd.d" -l /tmp/config.ldif
/usr/sbin/slapadd -n0 -F "/etc/openldap/slapd.d" -l /tmp/data/a.ldif

cn=Manager,dc=my-domain,dc=com

ldapsearch -x -D "cn=Manager,dc=my-domain,dc=com" -w okada1234! -b


 daemon: bind(7) failed errno=98 (Address in use)

mkdir /var/lib/openldap/run
mkdir /var/lib/openldap/run/ldapi

slapd -d 256 -h "ldap:/// ldapi:///" -F /etc/openldap/slapd.d

ldapadd -x -D "-Y EXTERNAL -H ldapi:// -f /tmp/data/add_rootPw.ldif
ldapmodify -x -D cn=config -w xxxxxxxx -f /tmp/data/change-domain.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/data/memberof-overlay.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/data/refint-overlay.ldif
ldapadd -x -D "#{rootDN}" -w #{rootPw} -f /tmp/data/base.ldif


ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/data/acl.ldif

mkdir /var/lib/openldap/run
mkdir /var/lib/openldap/run/ldapi

mkdir /var/lib/openldap/run/
mkdir /etc/openldap/slapd.d
slapadd -n0 -l /tmp/data/config.ldif -F /etc/openldap/slapd.d
slapd -d 256 -h "ldap:/// ldapi://localhost" -F /etc/openldap/slapd.d


docker run -it --rm --name ldap -v $PWD/data:/tmp/data -p 389:389 ldap
docker exec -it -v $PWD/data:/tmp/data -p 389:389 ldap ash

ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/data/memberof-overlay.ldif
ldapsearch -Y EXTERNAL -H ldapi://localhost/ -b cn=config

ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/data/acl.ldif
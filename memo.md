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

ldapadd -Y EXTERNAL -H ldapi://localhost/ -f /tmp/data/config-password.ldif
ldapmodify -x -D cn=config -w xxxxxxxx -f /tmp/data/change-domain.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/data/memberof-overlay.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/data/refint-overlay.ldif
ldapadd -x -D "#{rootDN}" -w #{rootPw} -f /tmp/data/base.ldif


ldapadd -Y EXTERNAL -H ldapi://localhost/ -f /tmp/data/acl.ldif

mkdir /var/lib/openldap/run
mkdir /var/lib/openldap/run/ldapi

mkdir /var/lib/openldap/run/
mkdir /etc/openldap/slapd.d
slapadd -n0 -l /tmp/data/config.ldif -F /etc/openldap/slapd.d
slapd -d 256 -h "ldap:/// ldapi://localhost" -F /etc/openldap/slapd.d

docker build -t ldap .
docker run -it --rm --name ldap -v $PWD/data:/tmp/data -p 389:389 ldap
docker exec -it  ldap ash

ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/data/memberof-overlay.ldif
ldapsearch -Y EXTERNAL -H ldapi://localhost/ -b cn=config

ldapadd -Y EXTERNAL -H ldapi://localhost/ -f /tmp/data/acl.ldif

ldapadd -x -D "cn=Manager,dc=example,dc=com" -w xxxxxxxx -f /tmp/data/base.ldif
ldapadd -x -D "cn=Manager,dc=example,dc=com" -w xxxxxxxx -f /tmp/data/users.ldif
ldapadd -x -D "cn=Manager,dc=example,dc=com" -w xxxxxxxx -f /tmp/data/groups.ldif   

ldapadd -x -D "cn=Manager,dc=example,dc=com" -w xxxxxxxx -f /tmp/data/newuser.ldif  

ldapi       slapd.args  slapd.pid

 ldapsearch -x -D "uid=testuser14,ou=users,dc=example,dc=com" -w testuser14 -b ou=users,dc=example,dc=com

 ldapdelete -x -D "cn=Manager,dc=example,dc=com" -w xxxxxxxx "uid=testuser14,ou=users,dc=example,dc=com"

ldapsearch -x -D "cn=Manager,dc=example,dc=com" -w secret -b dc=example,dc=com

slappasswd -h "{BCRYPT}" -o module-load="/usr/lib/openldap/pw-bcrypt.so" -s xxxxxxxx


ldapsearch -x -D "cn=Manager,dc=logic-wizard,dc=com" -w xxxxxxxx -b dc=users,ou=logic-wizard,dc=com

docker run -it --rm --name ldap -v $PWD/init:/ldap-init.d -p 389:389 --env-file ./.env ldap
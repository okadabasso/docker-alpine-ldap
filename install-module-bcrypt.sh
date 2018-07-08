
BUILD_ENV=prod

PREFIX=/opt
OPENLDAP_INSTALL_DIR=${PREFIX}/ldap
OPENLDAP_VERSION=2.4.45

# Temporary install deps
apk update
apk add --no-cache make g++ git libtool db-dev groff  krb5-libs

# Build tmp OpenLDAP
mkdir -p ${PREFIX}
cd ${PREFIX}
wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-${OPENLDAP_VERSION}.tgz
tar xzf openldap-${OPENLDAP_VERSION}.tgz
mv openldap-${OPENLDAP_VERSION} ldap
cd ${OPENLDAP_INSTALL_DIR}
./configure --prefix=${PREFIX} --enable-modules
make depend
make
make install

# Build bcrypt OpenLDAP
mkdir -p ${OPENLDAP_INSTALL_DIR}/contrib/slapd-modules/passwd
cd ${OPENLDAP_INSTALL_DIR}/contrib/slapd-modules/passwd
git clone https://github.com/wclarie/openldap-bcrypt.git bcrypt
cd ${OPENLDAP_INSTALL_DIR}/contrib/slapd-modules/passwd/bcrypt
make
make install

# install BCrypt lib
cp /usr/local/libexec/openldap/pw-bcrypt.so /usr/lib/openldap/pw-bcrypt.so

# Remove tmp OpenLDAP build
rm -rf ${OPENLDAP_INSTALL_DIR}
rm -rf /usr/local/libexec

# Remove installed deps
apk del  make g++ git libtool db-dev groff  krb5-libs
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /usr/share/locale/* && \
  rm -rf /usr/share/man/* && \
  rm -rf /usr/share/doc/*

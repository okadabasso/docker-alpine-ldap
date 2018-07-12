#!/bin/sh

apk add --no-cache  make g++ git libtool db-dev groff  krb5-libs
# Build tmp OpenLDAP
mkdir -p ${PREFIX}
cd ${PREFIX}
wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-${OPENLDAP_VERSION}.tgz && \
  tar xzf openldap-${OPENLDAP_VERSION}.tgz && \
  mv openldap-${OPENLDAP_VERSION} ldap
cd ${OPENLDAP_INSTALL_DIR}
./configure --prefix=${PREFIX} --enable-modules && make depend && make && make install

# Build bcrypt OpenLDAP
mkdir -p ${OPENLDAP_INSTALL_DIR}/contrib/slapd-modules/passwd
cd ${OPENLDAP_INSTALL_DIR}/contrib/slapd-modules/passwd
git clone https://github.com/wclarie/openldap-bcrypt.git bcrypt
cd ${OPENLDAP_INSTALL_DIR}/contrib/slapd-modules/passwd/bcrypt
make && make install

cp /usr/local/libexec/openldap/pw-bcrypt.so /usr/lib/openldap/pw-bcrypt.so
rm -rf ${OPENLDAP_INSTALL_DIR} && rm -rf ${PREFIX} && rm -rf /usr/local/libexec

apk del --purge  make g++ git libtool db-dev groff  krb5-libs
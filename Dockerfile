FROM alpine

MAINTAINER michiakiokada <michiakiokada@craft-net.co.jp>

ENV BUILD_ENV=prod
ENV DEBUG_LEVEL=256
ENV LDAP_DOMAIN=dc=example,dc=com
ENV LDAP_ROOT_DN=cn=Manager,dc=example,dc=com
ENV LDAP_ROOT_PASSWORD=secret
ENV LDAP_CONFIG_PASSWORD=secret

#
# create bcrypt module
#
ENV PREFIX=/opt
ENV OPENLDAP_INSTALL_DIR=${PREFIX}/ldap
ENV OPENLDAP_VERSION=2.4.45

RUN apk update && \
  apk add --no-cache \
  openldap \
  openldap-overlay-all \
  openldap-back-mdb \
  openldap-back-monitor \
  ldapvi \
  make g++ git libtool db-dev groff  krb5-libs

# Build tmp OpenLDAP
RUN mkdir -p ${PREFIX}
WORKDIR ${PREFIX}
RUN wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-${OPENLDAP_VERSION}.tgz
RUN tar xzf openldap-${OPENLDAP_VERSION}.tgz
RUN mv openldap-${OPENLDAP_VERSION} ldap
WORKDIR ${OPENLDAP_INSTALL_DIR}
RUN ./configure --prefix=${PREFIX} --enable-modules
RUN make depend
RUN make
RUN make install

# Build bcrypt OpenLDAP
RUN mkdir -p ${OPENLDAP_INSTALL_DIR}/contrib/slapd-modules/passwd
WORKDIR ${OPENLDAP_INSTALL_DIR}/contrib/slapd-modules/passwd
RUN git clone https://github.com/wclarie/openldap-bcrypt.git bcrypt
WORKDIR ${OPENLDAP_INSTALL_DIR}/contrib/slapd-modules/passwd/bcrypt
RUN make
RUN make install

WORKDIR /

# install BCrypt lib
RUN cp /usr/local/libexec/openldap/pw-bcrypt.so /usr/lib/openldap/pw-bcrypt.so

RUN rm -rf ${OPENLDAP_INSTALL_DIR}
RUN rm -rf /usr/local/libexec

# Remove installed deps
RUN apk del --purge  make g++ git libtool db-dev groff  krb5-libs

#
# set up ldap
#
ADD config.ldif /tmp/config.ldif
ADD entrypoint.sh /usr/local/bin/entrypoint.sh

RUN mkdir /etc/openldap/slapd.d && \
  mkdir /var/lib/openldap/run/ && \
  mkdir /var/lib/openldap/run/ldapi

RUN mkdir /ldap-init.d /ldap-init.d/config /ldap-init.d/data
VOLUME ["/ldap-init.d","/var/lib/openldap"]

# moved to entrypoint.sh
#RUN slapadd -n0 -l /tmp/config.ldif -F /etc/openldap/slapd.d/

EXPOSE 389

#ENTRYPOINT ["slapd","-d", "256", "-h", "ldap:/// ldapi://localhost","-F", "/etc/openldap/slapd.d"]
ENTRYPOINT ["entrypoint.sh"]

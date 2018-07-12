FROM alpine:3.8

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
  openldap-clients \
  openldap-overlay-memberof \
  openldap-overlay-refint \
  openldap-overlay-ppolicy \
  openldap-back-mdb \
  openldap-back-monitor

COPY build-pw-bcrypt.sh /tmp/build-pw-bcrypt.sh
RUN sh /tmp/build-pw-bcrypt.sh
WORKDIR /


COPY config.ldif /tmp/config.ldif
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN mkdir /etc/openldap/slapd.d && \
  mkdir /var/lib/openldap/run/ && \
  mkdir /var/lib/openldap/run/ldapi && \
  mkdir /ldap-init.d /ldap-init.d/config /ldap-init.d/data
VOLUME ["/ldap-init.d","/var/lib/openldap"]

# moved to entrypoint.sh
#RUN slapadd -n0 -l /tmp/config.ldif -F /etc/openldap/slapd.d/

EXPOSE 389

#ENTRYPOINT ["slapd","-d", "256", "-h", "ldap:/// ldapi://localhost","-F", "/etc/openldap/slapd.d"]
ENTRYPOINT ["entrypoint.sh"]

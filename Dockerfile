FROM alpine

MAINTAINER michiakiokada <michiakiokada@craft-net.co.jp>

RUN apk update && \
  apk add --no-cache \
  openldap \
  openldap-overlay-all \
  openldap-clients \
  openldap-back-mdb \
  openldap-back-monitor \
  ldapvi


ADD config/config.ldif /tmp/config.ldif

RUN mkdir /etc/openldap/slapd.d && \
  mkdir /var/lib/openldap/run/ && \
  mkdir /var/lib/openldap/run/ldapi

RUN slapadd -n0 -l /tmp/config.ldif -F /etc/openldap/slapd.d/

EXPOSE 389

ENTRYPOINT ["slapd","-d", "256", "-h", "ldap:/// ldapi://localhost","-F", "/etc/openldap/slapd.d"]

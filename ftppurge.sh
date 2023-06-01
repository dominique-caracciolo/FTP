#!/bin/bash
service proftpd stop
rm -rf /etc/proftpd/ssl
apt-get purge proftpd-core proftpd-mod-crypto -y
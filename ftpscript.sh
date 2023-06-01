#!/bin/bash
apt-get install openssl proftpd proftpd-mod-crypto wget curl -y
apt update
service proftpd stop
mkdir -p /etc/proftpd/ssl
chmod 700 /etc/proftpd/ssl
openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/proftpd/ssl/proftpd.key -out /etc/proftpd/ssl/proftpd.crt -days 3650
chmod 600 /etc/proftpd/ssl/proftpd.key
chmod 600 /etc/proftpd/ssl/proftpd.crt
wget https://raw.githubusercontent.com/dominique-caracciolo/ftpfiles/main/modules.conf
wget https://raw.githubusercontent.com/dominique-caracciolo/ftpfiles/main/proftpd.conf
wget https://raw.githubusercontent.com/dominique-caracciolo/ftpfiles/main/tls.conf
chmod 600 tls.conf
chmod 600 modules.conf
chmod 600 proftpd.conf
mv modules.conf /etc/proftpd/modules.conf
mv proftpd.conf /etc/proftpd/proftpd.conf
mv tls.conf /etc/proftpd/tls.conf
service proftpd restart

#!/bin/sh

echo "Creating /etc/fibn ... "
/usr/bin/install -d /etc/fibn -o root -g root -m 600

echo "Copying initial blacklists and whitelist to /etc/fibn ... "
/usr/bin/install -D *txt /etc/fibn -o root -g root -m 600

echo "Copying initial configuration file to /etc/fibn ... "
/usr/bin/install -D fibn.conf /etc/fibn  -o root -g root -m 600

echo "Installing fibn binaries ... "
/usr/bin/install -D fibn_Apply /usr/local/bin  -o root -g root -m 700
/usr/bin/install -D fibn_BuildLocal /usr/local/bin  -o root -g root -m 700
/usr/bin/install -D fibn_Stats /usr/local/bin  -o root -g root -m 700

echo "Populating whitelist with your IP address and Gateway IP address ... "
MYIP=$(hostname -i)
/usr/bin/echo $MYIP >> /etc/fibn/whitelist.txt

/usr/sbin/route -n | /usr/bin/grep 'UG[ \t]' | /usr/bin/awk '{print $2}' | /usr/bin/tr ' ' '\n' >> /etc/fibn/whitelist.txt

exit 0

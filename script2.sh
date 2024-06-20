#!/bin/bash
sudo -i
apt install spawn-fcgi php php-cgi php-cli \
 apache2 libapache2-mod-fcgid -y

sleep 10
mkdir /etc/spawn-fcgi
touch /etc/spawn-fcgi/fcgi.conf
sudo bash -c 'cat > /etc/spawn-fcgi/fcgi.conf << "EOF"
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u www-data -g www-data -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"
EOF'
sudo bash -c 'cat > /etc/systemd/system/spawn-fcgi.service << "EOF"
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/spawn-fcgi/fcgi.conf
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
EOF'

systemctl daemon-reload
systemctl start spawn-fcgi.service
systemctl start spawn-fcgi
systemctl status spawn-fcgi

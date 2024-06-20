#!/bin/bash
sudo -i
sudo touch /etc/default/watchlog
sudo chmod 644 /etc/default/watchlog

sudo touch /var/log/watchlog.log

sudo bash -c 'cat <<EOF > /var/log/watchlog.log
This is a test log file.
You can add any text here.
But make sure it contains the keyword ALERT at least once.
ALERT: is
EOF'

sudo bash -c 'cat <<EOF > /etc/default/watchlog
# Configuration file for my watchlog service
# Place it to /etc/default

# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
EOF'

touch /opt/watchlog.sh

sudo bash -c 'cat > /opt/watchlog.sh << "EOF"
#!/bin/bash

WORD=$1
LOG=$2
DATE=$(date)

if grep $WORD $LOG &> /dev/null
then
  logger "$DATE: I found word, Master!"
else
  exit 0
fi
EOF'
chmod +x /opt/watchlog.sh


sudo bash -c 'cat  > /etc/systemd/system/watchlog.service << "EOF"
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/default/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
EOF'


sudo bash -c 'cat << EOF > /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
EOF'

systemctl daemon-reload
systemctl start watchlog.timer
systemctl start watchlog.service

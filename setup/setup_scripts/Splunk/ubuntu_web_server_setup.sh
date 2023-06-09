#!/bin/sh
apt update -y
timedatectl set-timezone 'Asia/Singapore'
apt-get install apache2 php libapache2-mod-php -y
systemctl start apache2.service

# Routing Table
ip route add 111.0.10.0/24 via 192.168.1.5

# Download and install splunk forwarder
dpkg -i splunk.deb
cat > /opt/splunkforwarder/etc/system/local/user-seed.conf <<EOM
[user_info]
USERNAME=admin
PASSWORD=password123
EOM

# Start splunk service (run this step first before running other `splunk` commands)
/opt/splunkforwarder/bin/splunk enable boot-start --accept-license --answer-yes --no-prompt

# Configure splunk forwarder to forward system logs to SIEM
/opt/splunkforwarder/bin/splunk add forward-server 192.168.1.100:9997 -auth admin:password123
/opt/splunkforwarder/bin/splunk add monitor /var/log/syslog -index main -sourcetype linux_syslog -auth admin:password123 
/opt/splunkforwarder/bin/splunk add monitor /var/log/auth.log -index main -sourcetype linux_secure -auth admin:password123

# Forward apache2 access.log to SIEM (somehow the above method does not work for /var/log/apache2/access.log)
cat >> /opt/splunkforwarder/etc/apps/search/local/inputs.conf <<EOM

[monitor:///var/log/apache2/access.log]
disabled = false
index = main
sourcetype = access_combined
EOM

# Start Splunk Forwarder
/opt/splunkforwarder/bin/splunk start -auth admin:password123

# create startup script
echo '#!/bin/sh' > /opt/startup.sh
echo 'ip route add 111.0.10.0/24 via 192.168.1.5' >> /opt/startup.sh
echo 'systemctl start apache2.service' >> /opt/startup.sh
echo '/opt/splunkforwarder/bin/splunk enable boot-start --accept-license --answer-yes --no-prompt' >> /opt/startup.sh
echo '/opt/splunkforwarder/bin/splunk add forward-server 192.168.1.100:9997 -auth admin:password123' >> /opt/startup.sh
echo '/opt/splunkforwarder/bin/splunk add monitor /var/log/syslog -index main -sourcetype linux_syslog -auth admin:password123' >> /opt/startup.sh
echo '/opt/splunkforwarder/bin/splunk add monitor /var/log/auth.log -index main -sourcetype linux_secure -auth admin:password123' >> /opt/startup.sh
echo '/opt/splunkforwarder/bin/splunk start -auth admin:password123' >> /opt/startup.sh
chmod +x startup.sh

cat > /etc/systemd/system/start.service << EOM
[Unit]
Description=Startup script

[Service]
User=root
WorkingDirectory=/opt
ExecStart=/bin/sh /opt/startup.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOM

systemctl daemon-reload
systemctl enable start.service
systemctl start start.service
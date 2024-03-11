#!/bin/sh
apt update -y
timedatectl set-timezone 'Asia/Singapore'

# Routing Table
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -A FORWARD -j LOG --log-level info
iptables -A FORWARD -i eth1 -o eth2 -j ACCEPT 
iptables -A FORWARD -i eth2 -o eth1 -j ACCEPT

# Download and install splunk forwarder
dpkg -i splunk.deb
cat > /opt/splunkforwarder/etc/system/local/user-seed.conf <<EOM
[user_info]
USERNAME=admin
PASSWORD=password123
EOM
/opt/splunkforwarder/bin/splunk enable boot-start --accept-license --answer-yes --no-prompt

# Configure splunk forwarder to forward web logs and system logs to SIEM
/opt/splunkforwarder/bin/splunk add forward-server 192.168.111.100:9997 -auth admin:password123
/opt/splunkforwarder/bin/splunk add monitor /var/log/syslog -index main -sourcetype linux_syslog -auth admin:password123
/opt/splunkforwarder/bin/splunk add monitor /var/log/auth.log -index main -sourcetype linux_secure -auth admin:password123

# Start Splunk Forwarder 
/opt/splunkforwarder/bin/splunk start -auth admin:password123

# create startup script
echo '#!/bin/sh' > /opt/startup.sh
echo 'echo 1 > /proc/sys/net/ipv4/ip_forward' >> /opt/startup.sh
echo 'iptables -A FORWARD -j LOG --log-level info' >> /opt/startup.sh
echo 'iptables -A FORWARD -i eth2 -o eth1 -j ACCEPT' >> /opt/startup.sh
echo 'iptables -A FORWARD -i eth1 -o eth2 -j ACCEPT' >> /opt/startup.sh
echo '/opt/splunkforwarder/bin/splunk add forward-server 192.168.111.100:9997 -auth admin:password123' >> /opt/startup.sh
echo '/opt/splunkforwarder/bin/splunk add monitor /var/log/syslog -index main -sourcetype linux_syslog -auth admin:password123' >> /opt/startup.sh
echo '/opt/splunkforwarder/bin/splunk add monitor /var/log/auth.log -index main -sourcetype linux_secure -auth admin:password123' >> /opt/startup.sh
echo '/opt/splunkforwarder/bin/splunk start -auth admin:password123' >> /opt/startup.sh
chmod +x /opt/startup.sh

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




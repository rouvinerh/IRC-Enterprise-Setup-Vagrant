#!/bin/sh
apt update -y
# Set up Routing Table
ip route add 111.0.10.0/24 via 192.168.1.5

# Download Splunk Enterprise
wget -O splunk.deb https://download.splunk.com/products/splunk/releases/9.0.3/linux/splunk-9.0.3-dd0128b1f8cd-linux-2.6-amd64.deb
dpkg -i splunk.deb
cat > /opt/splunk/etc/system/local/user-seed.conf <<EOM
[user_info]
USERNAME=admin
PASSWORD=password123
EOM

# Start splunk service (run this step first before running other `splunk` commands)
/opt/splunk/bin/splunk enable boot-start --accept-license --answer-yes --no-prompt
# Enable splunk listener
/opt/splunk/bin/splunk enable listen 9997 -auth admin:password123
service splunk start

# create startup script
echo '#!/bin/sh' > /opt/startup.sh
echo 'ip route add 111.0.10.0/24 via 192.168.1.5' >> /opt/startup.sh
echo '/opt/splunk/bin/splunk enable boot-start --accept-license --answer-yes --no-prompt' >> /opt/startup.sh
echo '/opt/splunk/bin/splunk enable listen 9997 -auth admin:password123' >> /opt/startup.sh
echo 'service splunk start' >> /opt/startup.sh
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
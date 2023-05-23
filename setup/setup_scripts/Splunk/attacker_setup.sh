#!/bin/sh
apt update -y
apt install docker.io
ip route add 192.168.1.0/24 via 111.0.10.5
# install caldera
git clone https://github.com/mitre/caldera.git --recursive
cd /home/vagrant/caldera
pip3 install -r requirements.txt

# install emu plugins
cd /home/vagrant/caldera/plugins/
rm -rf /home/vagrant/caldera/plugins/emu
git clone https://github.com/mitre/emu
cd /home/vagrant/caldera/plugins/emu
./download_payloads.sh

# enable emu and enable caldera
cd /home/vagrant/caldera/conf
rm default.yml
curl https://gist.githubusercontent.com/rouvinerh/5a027647065b60b05c321e651f8b92d6/raw/16f56c7100c57c172d0a54f5395240eda83e7388/default.yml -o default.yml
cd /home/vagrant/caldera

# create startup script
echo '#!/bin/sh' > /opt/startup.sh
echo 'ip route add 192.168.1.0/24 via 111.0.10.5' >> /opt/startup.sh
echo 'cd /home/vagrant/caldera; python3 server.py --insecure' >> /opt/startup.sh
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
#!/bin/sh
apt update -y
apt install docker.io
ip route add 192.168.1.0/24 via 111.0.10.5
# install caldera
git clone https://github.com/mitre/caldera.git --recursive
pip3 install -r /home/vagrant/caldera/requirements.txt
chown -R vagrant:vagrant /home/vagrant/caldera 

# reinstall emu and download payloads 
cd /home/vagrant/caldera/plugins/
rm -rf /home/vagrant/caldera/plugins/emu
git clone https://github.com/mitre/emu
cd /home/vagrant/caldera/plugins/emu
./download_payloads.sh
rm /home/vagrant/caldera/conf/default.yml

# import data file
rm -rf /home/vagrant/caldera/data
unzip /home/vagrant/data.zip -d /home/vagrant/caldera

# create startup script
echo '#!/bin/sh' > /opt/startup.sh
echo 'ip route add 192.168.1.0/24 via 111.0.10.5' >> /opt/startup.sh
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
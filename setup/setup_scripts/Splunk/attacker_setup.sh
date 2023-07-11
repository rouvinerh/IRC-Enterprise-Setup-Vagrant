#!/bin/sh
apt update -y
timedatectl set-timezone 'Asia/Singapore'
ip route add 192.168.1.0/24 via 111.0.10.5

# install docker compose
apt -y install docker.io
mkdir -p /usr/local/lib/docker/cli-plugins
mv /home/vagrant/docker-compose /usr/local/lib/docker/cli-plugins
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# install and put vectr backup
mkdir -p /opt/vectr
cd /opt/vectr
mv /home/vagrant/sra-vectr-runtime-8.8.1-ce.zip /opt/vectr
unzip /opt/vectr/sra-vectr-runtime-8.8.1-ce.zip
mkdir /opt/vectr/user
mkdir /opt/vectr/user/mongo
tar -zxvf /home/vagrant/dump.tgz -C /opt/vectr/user/mongo
rm /home/vagrant/dump.tgz
chown -R vagrant:vagrant /opt/vectr

# install caldera
cd /home/vagrant
git clone https://github.com/mitre/caldera.git --recursive --branch 4.1.0
rm /home/vagrant/caldera/requirements.txt
mv /home/vagrant/requirements.txt /home/vagrant/caldera/requirements.txt
pip3 install -r /home/vagrant/caldera/requirements.txt
chown -R vagrant:vagrant /home/vagrant/caldera 

# update conf files
rm /home/vagrant/caldera/conf/default.yml
rm /home/vagrant/caldera/conf/agents.yml
mv /home/vagrant/default.yml /home/vagrant/caldera/conf/default.yml
mv /home/vagrant/agents.yml /home/vagrant/caldera/conf/agents.yml


# import data file
rm -rf /home/vagrant/caldera/data
unzip /home/vagrant/data.zip -d /home/vagrant/caldera
rm /home/vagrant/data.zip

# unencrypt payloads
python3 /home/vagrant/encrypt.py /home/vagrant/caldera/data/payloads/mimikatz.enc /home/vagrant/caldera/data/payloads/mimikatz.exe dec
python3 /home/vagrant/encrypt.py /home/vagrant/caldera/data/payloads/procdump.enc /home/vagrant/caldera/data/payloads/procdump.exe dec
python3 /home/vagrant/encrypt.py /home/vagrant/caldera/data/payloads/innocent.enc /home/vagrant/caldera/data/payloads/innocent.exe dec
rm /home/vagrant/encrypt.py
rm /home/vagrant/caldera/data/payloads/*.enc

# turn screensaver off
xset -dpms
xset s off

# create startup script
echo '#!/bin/sh' > /opt/startup.sh
echo 'ip route add 192.168.1.0/24 via 111.0.10.5' >> /opt/startup.sh
echo 'xset -dpms' >> /opt/startup.sh
echo 'xset s off' >> /opt/startup.sh
echo 'cd /opt/vectr' >> /opt/startup.sh
echo 'docker compose up -d' >> /opt/startup.sh
echo 'cd /home/vagrant/caldera' >> /opt/startup.sh
echo 'python3 server.py --insecure' >> /opt/startup.sh

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
echo "[+] It takes about 2 minutes for Vectr and Caldera to start!" 
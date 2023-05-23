#!/bin/sh
apt update -y
apt-get install apache2 php libapache2-mod-php -y
systemctl start apache2.service

# Routing Table
ip route add 111.0.10.0/24 via 192.168.1.5
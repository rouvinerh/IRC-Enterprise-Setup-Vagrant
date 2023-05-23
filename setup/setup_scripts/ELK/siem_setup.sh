#!/bin/sh

# Set up Routing Table
ip route add 111.0.10.0/24 via 192.168.1.5

### Install docker and docker-compose
wget -O get-docker.sh https://get.docker.com
chmod +x get-docker.sh
./get-docker.sh
curl -L "https://github.com/docker/compose/releases/download/v2.14.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

### Download docker-elk version 8.2211.1
wget -O docker-elk.zip https://github.com/deviantony/docker-elk/archive/refs/tags/8.2211.1.zip
apt install unzip
unzip docker-elk.zip
mv docker-elk-8.2211.1 docker-elk

### Set up configuration
cd docker-elk

### Run ELK stack
docker-compose up -d
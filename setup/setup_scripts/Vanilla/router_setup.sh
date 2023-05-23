#!/bin/sh
apt update -y

# Routing Table
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -A FORWARD -j LOG --log-level info # Log all FORWARD chain packets, will be logged inside /var/log/kern.log
iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT # public to internal
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT # internal to public

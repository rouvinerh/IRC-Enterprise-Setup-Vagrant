# Network Configuration
There will be 2 subnets in this configuration.
1. External subnet - External network (where attacker resides)
1. Internal subnet - Enterprise's internal network

| Subnet | CIDR Range |
| ------ | ---------- |
| External | `111.0.10.0/24` |
| Internal | `192.168.1.0/24 `|

## Endpoints 

| Subnet | Computer | IP Address | Remarks |
| ------ | -------- | ---------- | ------- |
| External | Attacker | `111.0.10.10` | Attacker machine |
| External | Router | `111.0.10.5` | External Interface of Router |
| Internal | Router | `192.168.1.5` | Internal Interface of Router |
| Internal | Ubuntu Web Server | `192.168.1.200` | Hosts a public vulnerable web application |
| Internal | Windows Host | `192.168.1.151` | Hosts an internal vulnerable web application, Part of Active Directory |
| Internal | Domain Controller | `192.168.1.150` | Domain Controller for the Active Directory |
| Internal | SIEM | `192.168.1.100` | SIEM for the internal network |

## Routing Configuration
Add static routes and configuration to allow packets to be forwarded between internal and external subnet.

### Kali
Forward all internal destination packets to router's external interface
#### Routing Table
| CIDR | Route To |
| ---- | -------- |
| 192.168.1.0/24 | `111.0.10.5` |
`ip route add 192.168.1.0/24 via 111.0.0.5`

### Router 
* Configure router to forward packets from one interface to another
```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT # public to internal
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT # internal to public
```

### Ubuntu Web Server, Windows Host, Domain Controller, ELK SIEM
Forward all external destination packets to router's internal interface
#### Routing Table
| CIDR | Route To |
| ---- | -------- |
| 111.0.0.0/24 | `192.168.1.5` |
* Bash `ip route add 10.0.0.0/8 via 192.168.1.5`
* PowerShell `route /p add 111.0.0.0 mask 255.0.0.0 192.168.1.5 [if 0x2]`

## Firewall Configuration 
`TODO`

# Launch Configuration
Describe the launch configuration of each machine in a simple manner.

## External Subnet 
### Attacker (`111.0.10.10`)
The attacker machine is a Kali 2022 machine (AMI: `ami-039fea51dbe2592e2`). 
1. Add static route to route all traffic to `192.168.1.0/24` (internal subnet) to `111.0.10.5` (router).

### Router (`111.0.10.5`)
The router is a Ubuntu Server 2022 machine (AMI: `ami-055d15d9cfddf7bd3`). This EC2 instance will only be deployed after Ubuntu Web Server is deployed as it needs to fetch the FileBeat debian package from it.
1. Set up forwarding and logging using `iptables` from one interface to another
1. Download FileBeat debian package from `192.168.1.200` (Ubuntu Web Server) and install FileBeat.
1. Update Filebeat.yml using `cat`
1. Start Filebeat service

## Internal Subnet
### Router (`192.168.1.5`)
The router is a Ubuntu Server 2022 machine (AMI: `ami-055d15d9cfddf7bd3`). This EC2 instance will only be deployed after Ubuntu Web Server is deployed as it needs to fetch the FileBeat debian package from it.
1. Set up forwarding and logging using `iptables` from one interface to another
1. Download FileBeat debian package from `192.168.1.200` (Ubuntu Web Server) and install FileBeat.
1. Update Filebeat.yml using `cat`
1. Start Filebeat service

### Ubuntu Web Server (`192.168.1.200`)
The Ubuntu Web Server is a Ubuntu Server 20.04 LTS machine (AMI: `ami-055d15d9cfddf7bd3`). 
1. Update apt packages, install and start apache2
1. Add static route to route all traffic to `111.0.10.0/24` (external subnet) to `192.168.1.5` (router).
1. Download Filebeat package from `artifacts.elastic.co` to `/var/www/html`
1. Install Filebeat
1. Update Filebeat.yml using `cat`
1. Start Filebeat service

### SIEM (`192.168.1.100`)
The SIEM is a Ubuntu Server 20.04 LTS machine (AMI: `ami-055d15d9cfddf7bd3`). 
1. Add static route to route all traffic to `111.0.10.0/24` (external subnet) to `192.168.1.5` (router).
1. Install docker and docker-compose
1. Update elasticsearch.yml and docker-compose using `cat`
1. Use docker-compose to start ELK stack

### DC (`192.168.1.150`)
The DC is a Windows Server 2019 machine (AMI: `ami-050d504434d8b9ec5`)
1. Add static route to route all traffic to `111.0.10.0/24` (external subnet) to `192.168.1.5` (router).
1. Add firewall rule 
1. Add audit policies
1. Add registry keys to enable powershell logging 
1. Hardcode administrator password 
1. Download, install and configure sysmon
1. Download, install and configure Winlogbeat
1. Start Winlogbeat service
1. Set up DC

### Windows Host (`192.168.1.151`)
The Windows Host is a Windows Server 2019 machine (AMI: `ami-050d504434d8b9ec5`)
1. Add static route to route all traffic to `111.0.10.0/24` (external subnet) to `192.168.1.5` (router).
1. Add firewall rule 
1. Add audit policies
1. Add registry keys to enable powershell logging 
1. Hardcode administrator password 
1. Download, install and configure sysmon
1. Download, install and configure Winlogbeat
1. Start Winlogbeat service
1. Wait for DC to be set up and then join AD as `WEBSERVER01`

# FileBeat Configuration 

### Router (`111.0.10.5`/`192.168.1.5`)
Enabled the following filebeat modules:
1. `iptables`
1. `system`

### Router (`192.168.1.200`)
Enabled the following filebeat modules:
1. `apache`
1. `system`
# Enterprise Infrastructure Setup on Vagrant 
This project replicates IRC Enterprise Infrastructure Setup on AWS, and hosts it using Vagrant instead of AWS. There is currently only 1 SIEM available, and it is Splunk. (The other 2 will be added soon).

Vagrant Documentation:
1. [Vagrant Documentation](https://developer.hashicorp.com/vagrant/docs)

# Network Diagram
<img title="Network Diagram" alt="Alt text" src="/Images/network_diagram.png">

# Developer Setup
## Installing Vagrant and Virtualbox
This project needs to have both Vagrant and Virtualbox installed to run.
- [Vagrant](https://developer.hashicorp.com/vagrant/downloads)
- [Virtual Box](https://www.virtualbox.org/wiki/Downloads)

## System Requirements
--

## Set Up
Clone this repository and run `vagrant up` in the directory that `Vagrantfile` is in. 
```bash
git clone https://github.com/rouvinerh/IRC-Enterprise-Setup-Vagrant
cd IRC-Enterprise-Setup-Vagrant
vagrant up
```
For the first time, it takes around 30 minutes to install all VMs and run. Subsequent runs will take around 15 minutes.

## Tear Down
Stop all the VMs and run `destroy` to delete the machines.
```bash
vagrant halt
vagrant destroy --force
```


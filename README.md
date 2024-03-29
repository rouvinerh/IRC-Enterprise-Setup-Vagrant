# Enterprise Infrastructure Setup on Vagrant 
This project replicates the IRC Enterprise Infrastructure Setup, and runs it using Vagrant instead of AWS. The only SIEM available now is Splunk (the other 2 will be added soon).

Tested on Vagrant 2.3.4 and Virtualbox 7.0.8.

Recommended Reading:
1. [Vagrant Documentation](https://developer.hashicorp.com/vagrant/docs)

# Network Diagram
<img title="Network Diagram" alt="Alt text" src="/Images/network_diagram.png">

# Developer Setup
## Installing Vagrant and Virtualbox
This project needs to have both Vagrant 2.3.4 and Virtualbox 7.0.8 installed to run.
- [Vagrant](https://releases.hashicorp.com/vagrant/2.3.4/vagrant_2.3.4_windows_amd64.msi)
- [Virtual Box](https://download.virtualbox.org/virtualbox/7.0.8/VirtualBox-7.0.8-156879-Win.exe)

## System Requirements
At least 24GB of RAM and 100GB of disk space is required for all 6 machines to run smoothly with configurations specified in this repository. The resources used for each machine can be edited in `Vagrantfile` if needed.

## Set Up
Run the following commands to create the environment: 
```bash
git clone https://github.com/rouvinerh/IRC-Enterprise-Setup-Vagrant
cd IRC-Enterprise-Setup-Vagrant
powershell 
# optional to set virtual memory and sleep settings
.\host_settings.ps1
.\download_files.ps1
## computer will restart after running the script
## when restart is complete, run this in an administrator prompt
vagrant up
```
It takes around 10 minutes to download all VMs and run properly. 

## Clean Up
Stop and delete all machines from disk using: 
```bash
vagrant destroy --force
```

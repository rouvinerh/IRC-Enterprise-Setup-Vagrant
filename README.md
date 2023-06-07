# Enterprise Infrastructure Setup on Vagrant 
This project replicates the IRC Enterprise Infrastructure Setup, and runs it using Vagrant instead of AWS. The only SIEM available now is Splunk (the other 2 will be added soon).

Tested on Vagrant 2.3.4 and Virtualbox 7.0.8.

Recommended Reading:
1. [Vagrant Documentation](https://developer.hashicorp.com/vagrant/docs)

# IMPORTANT

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
Do the following:
```bash
git clone https://github.com/rouvinerh/IRC-Enterprise-Setup-Vagrant
cd IRC-Enterprise-Setup-Vagrant
powershell
.\download_files.ps1
vagrant up
```
It takes around 30 minutes to download all VMs and starting. 

## Clean Up
Stop and delete all machines from disk. 
```bash
vagrant halt
vagrant destroy --force
```

## Known Issues
1. The Windows hosts require manual logins to continue running `setup-DC.ps1` and `setup-windows.ps1` to start AD services.
2. The bidirectional clipboard cannot be modified by Vagrant, and has to be configured manually within VirtualBox. Go to Machine > Settings > General > Advanced and changed Shared Clipboard to Bidirectional. 

Vagrant.configure("2") do |config| 
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end  
  # router
  config.vm.define "router" do |router|
    router.vm.box = "hashicorp/bionic64"
    router.vm.hostname = "router"
    
    # network
    router.vm.network "private_network", ip: "192.168.111.5", virtualbox__intnet: "internal_nw"
    router.vm.network "private_network", ip: "111.0.10.5", virtualbox__intnet: "public_nw"

    # scripts
    router.vm.provision "file", source: "setup/setup_files/splunkforwarder.deb", destination: "/home/vagrant/splunk.deb"
    router.vm.provision "shell", path: "setup/setup_scripts/Splunk/router_setup.sh", privileged: true

    # virtualize
    router.vm.provider "virtualbox" do |v, override|
      v.name = "router"
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      v.customize ['modifyvm', :id, '--draganddrop', 'bidirectional']
      v.memory = 1024
      v.cpus = 2
      v.gui = true
    end
  end

  # siem
  config.vm.define "siem" do |siem|
    siem.vm.box = "hashicorp/bionic64"
    siem.vm.hostname = "siem"

    # network
    siem.vm.network "private_network", ip: "192.168.111.100", virtualbox__intnet: "internal_nw"

    # scripts 
    siem.vm.provision "file", source: "setup/setup_files/splunk.deb", destination: "/home/vagrant/splunk.deb"
    siem.vm.provision "shell", path: "setup/setup_scripts/Splunk/siem_setup.sh", privileged: true

    # virtualise
    siem.vm.provider "virtualbox" do |v, override|
      v.name = "siem"
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      v.customize ['modifyvm', :id, '--draganddrop', 'bidirectional']
      v.memory = 2048
      v.cpus = 2
      v.gui = true
    end
  end

  # dc
  config.vm.define "dc" do |dc|
    dc.vm.box = "gusztavvargadr/windows-server"
    dc.vm.hostname = "dc"
    dc.vm.communicator = "winssh"

    # network
    dc.vm.network "private_network", ip: "192.168.111.150", virtualbox__intnet: "internal_nw"

    # upload DC setup file
    dc.vm.provision "file", source: "setup/setup_files/dc/SetupDC.xml", destination: "C:/Users/Public/SetupDC.xml"
    dc.vm.provision "file", source: "setup/setup_files/dc/setup-dc.ps1", destination: "C:/Users/Public/setup-dc.ps1"
    
    dc.vm.provision "file", source: "setup/setup_files/Sysmon.zip", destination: "C:/Users/vagrant/Documents/Sysmon.zip"
    dc.vm.provision "file", source: "setup/setup_files/sysmonconfig-export.xml", destination: "C:/Windows/config.xml"
    dc.vm.provision "file", source: "setup/setup_files/splunkforwarder.msi", destination: "C:/Users/vagrant/Documents/splunkforwarder.msi"

    # scripts
    dc.vm.provision "shell", path: "setup/setup_scripts/Splunk/DC_setup.ps1", privileged: true

    # virtualise
    dc.vm.provider "virtualbox" do |v, override|
      v.name = "DC"
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      v.customize ['modifyvm', :id, '--draganddrop', 'bidirectional']
      v.memory = 8192
      v.cpus = 2
      v.gui = true
    end 
  end

  # attacker
  config.vm.define "attacker" do |kali|
    kali.vm.box = "kalilinux/rolling"
    kali.vm.hostname = "attacker"

    # network 
    kali.vm.network "private_network", ip: "111.0.10.10", virtualbox__intnet: "public_nw"

    # upload caldera files
    kali.vm.provision "file", source: "setup/setup_files/attacker/default.yml", destination: "/home/vagrant/default.yml"
    kali.vm.provision "file", source: "setup/setup_files/attacker/data.zip", destination: "/home/vagrant/data.zip"
    kali.vm.provision "file", source: "setup/setup_files/attacker/agents.yml", destination: "/home/vagrant/agents.yml"
    kali.vm.provision "file", source: "setup/setup_files/attacker/dump.tgz", destination: "/home/vagrant/dump.tgz"
    kali.vm.provision "file", source: "setup/setup_files/attacker/docker-compose", destination: "/home/vagrant/docker-compose"
    kali.vm.provision "file", source: "setup/setup_files/attacker/sra-vectr-runtime-8.8.1-ce.zip", destination: "/home/vagrant/sra-vectr-runtime-8.8.1-ce.zip" 
    kali.vm.provision "file", source: "setup/setup_files/attacker/encrypt.py", destination: "/home/vagrant/encrypt.py"
    kali.vm.provision "file", source: "setup/setup_files/attacker/requirements.txt", destination: "/home/vagrant/requirements.txt"

    # scripts
    kali.vm.provision "shell", path: "setup/setup_scripts/Splunk/attacker_setup.sh", privileged: true

    # virtualise
    kali.vm.provider "virtualbox" do |v, override|
      v.name = "kali"
      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      v.customize ['modifyvm', :id, '--draganddrop', 'bidirectional']
      v.memory = 8192
      v.cpus = 2
      v.gui = true
    end
  end 

#  config.vm.define "web" do |web|
#    web.vm.box = "hashicorp/bionic64"
#    web.vm.hostname= "web-server"
#
#    # network
#    web.vm.network "private_network", ip: "192.168.111.200", virtualbox__intnet: "internal_nw"
#
#    # scripts 
#    web.vm.provision "file", source: "setup/setup_files/splunk.deb", destination: "/home/vagrant/splunk.deb"
#    web.vm.provision "shell", path: "setup/setup_scripts/Splunk/ubuntu_web_server_setup.sh", privileged: true
#
#    # virtualise
#    web.vm.provider "virtualbox" do |v, override|
#      v.name = "web-server"
#      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
#      v.customize ['modifyvm', :id, '--draganddrop', 'bidirectional']
#      v.memory = 2048
#      v.cpus = 2
#      v.gui = true
#    end
#  end 
#
#  config.vm.define "host" do |host|
#    host.vm.box = "gusztavvargadr/windows-10"
#    host.vm.hostname= "host"
#    host.vm.communicator = "winssh"
#    # network 
#    host.vm.network "private_network", ip: "192.168.111.151", virtualbox__intnet: "internal_nw"
#
#    # upload host setup file
#    host.vm.provision "file", source: "setup/setup_files/host/SetupWindows.xml", destination: "C:/Users/Public/SetupWindows.xml"
#    host.vm.provision "file", source: "setup/setup_files/host/setup-windows.ps1", destination: "C:/Users/Public/setup-windows.ps1"
#    host.vm.provision "file", source: "setup/setup_files/Sysmon.zip", destination: "C:/Users/vagrant/Documents/Sysmon.zip"
#    host.vm.provision "file", source: "setup/setup_files/sysmonconfig-export.xml", destination: "C:/Windows/config.xml"
#    host.vm.provision "file", source: "setup/setup_files/splunkforwarder.msi", destination: "C:/Users/vagrant/Documents/splunkforwarder.msi"

#    # scripts
#    host.vm.provision "shell", path: "setup/setup_scripts/Splunk/windows_host_setup.ps1", privileged: true, run: 'always'
#
#    # virtualise
#    host.vm.provider "virtualbox" do |v, override|
#      v.name = "host"
#      v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
#      v.customize ['modifyvm', :id, '--draganddrop', 'bidirectional']
#      v.memory = 4096
#      v.cpus = 2
#      v.gui = true
#    end 
#  end
end
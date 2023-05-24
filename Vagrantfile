Vagrant.configure("2") do |config|
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end
  # router
  config.vm.define "router" do |router|
    router.vm.box = "hashicorp/bionic64"
    router.vm.hostname = "router"
    
    # network
    router.vm.network "private_network", ip: "192.168.1.5"
    router.vm.network "public_network",bridge: "enp0s3", ip: "111.0.10.5"

    # scripts
    router.vm.provision "shell", path: "setup/setup_scripts/Splunk/router_setup.sh", privileged: true

    # virtualize
    router.vm.provider "virtualbox" do |v, override|
      v.name = "router"
      v.memory = 2048
      v.cpus = 1
      v.gui = true
    end
  end

  # siem
  config.vm.define "siem" do |siem|
    siem.vm.box = "hashicorp/bionic64"
    siem.vm.hostname = "siem"

    # network
    siem.vm.network "private_network", ip: "192.168.1.100"

    # scripts 
    siem.vm.provision "shell", path: "setup/setup_scripts/Splunk/siem_setup.sh", privileged: true

    # virtualise
    siem.vm.provider "virtualbox" do |v, override|
      v.name = "siem"
      v.memory = 2048
      v.cpus = 1
      v.gui = true
    end
  end

  # dc
  config.vm.define "dc" do |dc|
    dc.vm.box = "gusztavvargadr/windows-server"
    dc.vm.hostname = "dc"

    # network
    dc.vm.network "private_network", ip: "192.168.1.150"

    # upload DC setup file
    dc.vm.provision "file", source: "setup/setup_files/dc/SetupDC.xml", destination: "C:/Users/Public/SetupDC.xml"
    dc.vm.provision "file", source: "setup/setup_files/dc/setup-dc.ps1", destination: "C:/Users/Public/setup-dc.ps1"

    # scripts
    dc.vm.provision "shell", path: "setup/setup_scripts/Splunk/DC_setup.ps1", privileged: true

    # virtualise
    dc.vm.provider "virtualbox" do |v, override|
      v.name = "DC"
      v.memory = 4096
      v.cpus = 2
      v.gui = true
    end 
  end

  # attacker
  config.vm.define "attacker" do |kali|
    kali.vm.box = "kalilinux/rolling"
    kali.vm.hostname = "attacker"

    # network 
    kali.vm.network "public_network",bridge: "enp0s3", ip: "111.0.10.10"

    # scripts
    kali.vm.provision "shell", path: "setup/setup_scripts/Splunk/attacker_setup.sh", privileged: true

    # upload config file
    kali.vm.provision "file", source: "setup/setup_files/attacker/default.yml", destination: "/home/vagrant/caldera/conf/default.yml"
    
    # virtualise
    kali.vm.provider "virtualbox" do |v, override|
      v.name = "kali"
      v.memory = 4096
      v.cpus = 2
      v.gui = true
    end
  end 


  config.vm.define "web" do |web|
    web.vm.box = "hashicorp/bionic64"
    web.vm.hostname= "web-server"

    # network
    web.vm.network "private_network", ip: "192.168.1.200"

    # scripts 
    web.vm.provision "shell", path: "setup/setup_scripts/Splunk/ubuntu_web_server_setup.sh", privileged: true

    # virtualise
    web.vm.provider "virtualbox" do |v, override|
      v.name = "web-server"
      v.memory = 2048
      v.cpus = 1
      v.gui = true
    end
  end 

  config.vm.define "host" do |host|
    host.vm.box = "gusztavvargadr/windows-server"
    host.vm.hostname= "host"

    # network 
    host.vm.network "private_network", ip: "192.168.1.151"

    # upload host setup file
    host.vm.provision "file", source: "setup/setup_files/host/SetupWindows.xml", destination: "C:/Users/Public/SetupWindows.xml"
    host.vm.provision "file", source: "setup/setup_files/host/setup-windows.ps1", destination: "C:/Users/Public/setup-windows.ps1"

    # scripts
    host.vm.provision "shell", path: "setup/setup_scripts/Splunk/windows_host_setup.ps1", privileged: true, run: 'always'

    # virtualise
    host.vm.provider "virtualbox" do |v, override|
      v.name = "host"
      v.memory = 4096
      v.cpus = 2
      v.gui = true
    end 
  end
end
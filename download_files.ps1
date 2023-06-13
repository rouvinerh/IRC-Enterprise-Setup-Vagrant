$url = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"
$dest = "setup/setup_files/sysmonconfig-export.xml"
Invoke-WebRequest -Uri $url -OutFile $dest

$url = "https://download.sysinternals.com/files/Sysmon.zip"
$dest = "setup/setup_files/Sysmon.zip"
Invoke-WebRequest -Uri $url -OutFile $dest

$url = "https://download.splunk.com/products/universalforwarder/releases/9.0.3/windows/splunkforwarder-9.0.3-dd0128b1f8cd-x64-release.msi"
$dest = "setup/setup_files/splunkforwarder.msi"
Invoke-WebRequest -Uri $url -OutFile $dest

$url = "https://download.splunk.com/products/universalforwarder/releases/9.0.3/linux/splunkforwarder-9.0.3-dd0128b1f8cd-linux-2.6-amd64.deb"
$dest = "setup/setup_files/splunkforwarder.deb"
Invoke-WebRequest -Uri $url -OutFile $dest

$url = "https://download.splunk.com/products/splunk/releases/9.0.3/linux/splunk-9.0.3-dd0128b1f8cd-linux-2.6-amd64.deb"
$dest = "setup/setup_files/splunk.deb"
Invoke-WebRequest -Uri $url -OutFile $dest

$url = "https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-linux-x86_64"
$dest = "setup/setup_files/attacker/docker-compose"
Invoke-WebRequest -Uri $url -OutFile $dest

$url = "https://github.com/SecurityRiskAdvisors/VECTR/releases/download/ce-8.8.1/sra-vectr-runtime-8.8.1-ce.zip"
$dest = "setup/setup_files/attacker/sra-vectr-runtime-8.8.1-ce.zip"
Invoke-WebRequest -Uri $url -OutFile $dest

Write-Host "Downloads complete! Run 'vagrant up' to start VMs :)"
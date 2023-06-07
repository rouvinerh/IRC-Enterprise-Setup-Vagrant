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

Write-Host "Downloads complete! Run 'vagrant up' to start VMs :)"
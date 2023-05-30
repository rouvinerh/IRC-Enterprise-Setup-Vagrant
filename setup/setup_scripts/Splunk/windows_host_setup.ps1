route /p add 111.0.10.0 mask 255.255.255.0 192.168.1.5

netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow
netsh advfirewall firewall add rule name="ICMP Allow incoming V6 echo request" protocol=icmpv6:8,any dir=in action=allow

auditpol /clear /y

auditpol /set /subcategory:"Kerberos Authentication Service" /failure:enable /success:enable
auditpol /set /subcategory:"Kerberos Service Ticket Operations" /failure:enable

auditpol /set /subcategory:"Computer Account Management" /failure:enable /success:enable
auditpol /set /subcategory:"Other Account Management Events" /failure:enable /success:enable
auditpol /set /subcategory:"User Account Management" /failure:enable /success:enable

auditpol /set /subcategory:"Process Creation" /failure:enable /success:enable
auditpol /set /subcategory:"Process Termination" /failure:enable /success:enable

auditpol /set /subcategory:"Account Lockout" /failure:enable
auditpol /set /subcategory:"Group Membership" /failure:enable /success:enable
auditpol /set /subcategory:"Logoff" /success:enable
auditpol /set /subcategory:"Logon" /failure:enable /success:enable
auditpol /set /subcategory:"Other Logon/Logoff Events" /failure:enable /success:enable
auditpol /set /subcategory:"Special Logon" /failure:enable /success:enable

auditpol /set /subcategory:"Other Object Access Events" /failure:enable /success:enable
auditpol /set /subcategory:"Registry" /failure:enable /success:enable

auditpol /set /subcategory:"Audit Policy Change" /failure:enable /success:enable
auditpol /set /subcategory:"Authentication Policy Change" /failure:enable /success:enable
auditpol /set /subcategory:"Filtering Platform Policy Change" /failure:enable /success:enable
auditpol /set /subcategory:"MPSSVC Rule-Level Policy Change" /failure:enable /success:enable

auditpol /set /subcategory:"Sensitive Privilege Use" /success:enable

auditpol /set /subcategory:"Other System Events" /failure:enable /success:enable
auditpol /set /subcategory:"Security State Change" /success:enable

Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" -Name "ProcessCreationIncludeCmdLine_Enabled" -Value 1
if(-not (Test-Path "HKLM:\Software\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging")) { New-Item "HKLM:\Software\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -Force }
Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -Name "EnableModuleLogging" -Value 1
if(-not (Test-Path "HKLM:\Software\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames")) { New-Item "HKLM:\Software\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames" -Force }
Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames" -Name "*" -Value *
if(-not (Test-Path "HKLM:\Software\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging")) { New-Item "HKLM:\Software\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Force }
Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1


# Set password of administrator account for easier RDP
net user Administrator "P@ssw0rd123"


# Downloading Sysmon's config file to C:\Windows
$url = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml"
$dest = "C:\Windows\config.xml"
Invoke-WebRequest -Uri $url -OutFile $dest

# Downloading Sysmon
$url = "https://download.sysinternals.com/files/Sysmon.zip"
$dest = "C:\Users\vagrant\Documents\Sysmon.zip"
Invoke-WebRequest -Uri $url -OutFile $dest

# Unzipping Sysmon
Expand-Archive -Path "C:\Users\vagrant\Documents\Sysmon.zip" -DestinationPath "C:\Users\vagrant\Documents\Sysmon"

# Installing Sysmon
Start-Process -FilePath "Sysmon64.exe" -WorkingDirectory "C:\Users\vagrant\Documents\Sysmon" -ArgumentList "-accepteula","-i C:\Windows\config.xml"

# Downloading Splunk Forwarder for Windows
$url = "https://download.splunk.com/products/universalforwarder/releases/9.0.3/windows/splunkforwarder-9.0.3-dd0128b1f8cd-x64-release.msi"
$dest = "C:\Users\vagrant\Documents\splunkforwarder.msi"
Invoke-WebRequest -Uri $url -OutFile $dest

$RECEIVING_INDEXER="192.168.1.100:9997"
$LOGON_USERNAME="admin"
$LOGON_PASSWORD="password123"
$SET_ADMIN_USER=1
$SPLUNKUSERNAME="admin"
$SPLUNKPASSWORD="password123"
$AGREETOLICENSE="yes"
$LAUNCHSPLUNK=1
$SERVICESTARTTYPE="auto"

msiexec.exe /i $dest RECEIVING_INDEXER=$RECEIVING_INDEXER SET_ADMIN_USER=$SET_ADMIN_USER SPLUNKUSERNAME=$SPLUNKUSERNAME SPLUNKPASSWORD=$SPLUNKPASSWORD AGREETOLICENSE=$AGREETOLICENSE LAUNCHSPLUNK=1 SERVICESTARTTYPE=$SERVICESTARTTYPE /qn

# Wait for Installation to complete
while (-not (Get-WmiObject -Class Win32_Product | Where-Object {$_.name -eq "UniversalForwarder"})) {
  Start-Sleep -Seconds 10
}

$conf = "C:\Program Files\SplunkUniversalForwarder\etc\apps\SplunkUniversalForwarder\local\inputs.conf"

echo @'

[WinEventLog://Application]
checkpointInterval = 5
current_only = 0
disabled = 0
start_from = oldest

[WinEventLog://Security]
checkpointInterval = 5
current_only = 0
disabled = 0
start_from = oldest

[WinEventLog://System]
checkpointInterval = 5
current_only = 0
disabled = 0
start_from = oldest
`
[WinEventLog://ForwardedEvents]
checkpointInterval = 5
current_only = 0
disabled = 0
start_from = oldest

[WinEventLog://Setup]
checkpointInterval = 5
current_only = 0
disabled = 0

[WinEventLog://Windows PowerShell]
disabled = 0
checkpointInterval = 5
start_from = oldest

[WinEventLog://Microsoft-Windows-PowerShell/Operational]
disabled = 0
checkpointInterval = 5
start_from = oldest

[WinEventLog://Microsoft-Windows-Sysmon/Operational]
disabled = false
checkpointInterval = 5
start_from = oldest

'@ > $conf

# Restart SplunkForwarder to apply configuration
Restart-Service SplunkForwarder

# turn off defender
Set-MpPreference -DisableRealtimeMonitoring $true

# run AD script
C:\Users\Public\setup-windows.ps1
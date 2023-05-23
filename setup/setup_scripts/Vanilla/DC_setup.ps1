<powershell>
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
$dest = "C:\Users\Administrator\Desktop\Sysmon.zip"
Invoke-WebRequest -Uri $url -OutFile $dest

# Unzipping Sysmon
Expand-Archive -Path "C:\Users\Administrator\Desktop\Sysmon.zip" -DestinationPath "C:\Users\Administrator\Desktop\Sysmon"

# Installing Sysmon
Start-Process -FilePath "Sysmon64.exe" -WorkingDirectory "C:\Users\Administrator\Desktop\Sysmon" -ArgumentList "-accepteula","-i C:\Windows\config.xml"

## Set up the Active Directory and this host as the DC
# Set up scheduled task as the setup process requires restarting
$url = "https://gist.githubusercontent.com/ChesterSng/f37e7b665dbeb555f82d8c3ca42be7a5/raw/4393f6c2784f109c1309aa85acaa4b089042831c/SetupDC.xml"
$dest = "C:\Users\Public\SetupDC.xml"
Invoke-WebRequest -Uri $url -OutFile $dest

$url = "https://gist.githubusercontent.com/ChesterSng/189b3f5b00b6d82d917f8da6ab81c83e/raw/8037d8cddd82f74659549ba8d085f7dada6ed911/setup-dc.ps1"
$dest = "C:\Users\Public\setup-dc.ps1"
Invoke-WebRequest -Uri $url -OutFile $dest

# Run the script, this process should take ~20mins and will restart multiple times, maybe next time when we use a more powerful instance it can be faster ;_;
C:\Users\Public\setup-dc.ps1
</powershell>
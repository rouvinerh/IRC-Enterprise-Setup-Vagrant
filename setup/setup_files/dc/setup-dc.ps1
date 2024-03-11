# Adapted from https://github.com/CSAdev-engenuity/AdversaryEmulation/blob/main/vm_setup_scripts/windows_server/setup-dc.ps1

#Step 1
if ($env:COMPUTERNAME -ne "dc") {
    $password = "vagrant"
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name 'DefaultUserName' -Type String -Value "vagrant";
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name 'DefaultPassword' -Type String -Value $password;
    if(-not (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon")) { New-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Force }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "1"

    #Replace username and userID placeholders in Scheduled Task XML file with local values
    $sid = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value;
    ((Get-Content -Path C:\Users\Public\SetupDC.xml -Raw) -Replace '{WHOAMI}',(whoami)) -Replace '{SID}',$sid | Set-Content -Path C:\Users\Public\SetupDC.xml;
    #Then use XML file to create Scheduled Task to continue setup process after reboots
    Register-ScheduledTask -TaskName 'SetupDC' -XML (Get-Content -Path C:\Users\Public\SetupDC.xml | Out-String);

    #Install Emulation and Detection tools, can consider to install these later
    # powershell -ep bypass C:\Users\Public\install-tools.ps1;

    Start-Sleep -Seconds 3;
    Rename-Computer -NewName "dc" -Restart
} 
#Step 2
elseif ((Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem).Domain -ne "CSA.local") {
    #Add domain name to auto login
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name 'DefaultDomainName' -Type String -Value "CSA";

    #Create CSA.local domain. Server will restart after domain is created
    Install-WindowsFeature AD-Domain-Services
    Import-Module ADDSDeployment
    $SecPassword = ConvertTo-SecureString "SuperS3cureP@ssw0rd" -AsPlainText -Force
    # needs to restart after the install-ADDSForest command to actually come back up as a DC
    Install-ADDSForest -CreateDnsDelegation:$false -DomainName "CSA.local" -DomainNetbiosName "CSA" -InstallDns:$true -DatabasePath "C:\Windows\NTDS" -DomainMode "7" -ForestMode "7" -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SysvolPath "C:\Windows\SYSVOL" -Force:$true -SafeModeAdministratorPassword $SecPassword
}
else {
    #Step 3
    #Waiting for AD services to start up after server restart. If AD services are not up, Get-ADUser should error out
    Write-Host "[i] Waiting for AD services to start"
    $AD_enabled = $false;
    while (-not ($AD_enabled)) {
        try {
            Get-ADUser Administrator;
            $AD_enabled = $true;
            Write-Host "[+] AD Services started, proceeding"
        } catch {
            Write-Host "[i] Still waiting..."
            Start-Sleep -Seconds 5;
        }
    }
    
    $connectionProfile = Get-NetConnectionProfile
    $profileName = $connectionProfile.Name
    Set-NetConnectionProfile -Name $profileName -NetworkCategory Private
    Write-Host "[+] Network set to private"
    
    #We need to add the new domain user and configure things under their account, so we start by checking if that account exists
    $userobj = $(try {Get-ADUser "csaAdmin"} catch {$Null});
    if ($userobj -eq $Null) {
        #Add domain entities (computer accounts, organizational units, and user accounts)
        Add-WindowsFeature RSAT-AD-PowerShell
        Import-Module ActiveDirectory
        Write-Host "[i] Adding workstations (computer accounts) to domain"
        New-ADComputer -Name "WKST01" -AccountPassword (ConvertTo-SecureString 'wk1Passw0rd!' -AsPlainText -Force)
        New-ADComputer -Name "WKST02" -AccountPassword (ConvertTo-SecureString 'wk2Passw0rd!' -AsPlainText -Force)
        New-ADComputer -Name "WKST03" -AccountPassword (ConvertTo-SecureString 'wk3Passw0rd!' -AsPlainText -Force)
        New-ADComputer -Name "WEBSERVER01" -AccountPassword (ConvertTo-SecureString 'ws1Passw0rd!' -AsPlainText -Force)
        Write-Host "[+] WKST01, WKST02, WKST03 and WEBSERVER01 computer accounts added to CSA.local"

        #Creating Organizational Units
        Write-Host "[i] Adding Organizational Units to domain"
        New-ADOrganizationalUnit -Name "Managers" -Path "DC=CSA,DC=local"
        New-ADOrganizationalUnit -Name "HR" -Path "DC=CSA,DC=local"
        New-ADOrganizationalUnit -Name "Engineers" -Path "DC=CSA,DC=local"
        New-ADOrganizationalUnit -Name "UserAccounts" -Path "DC=CSA,DC=local"
        Write-Host "[+] Managers, HR, Engineers and UserAccounts Organizational Units added to CSA.local"

        #Creating Users
        Write-Host "[i] Adding regular users to domain"
        New-ADUser -Name "Jeniffer Tan" -GivenName "Jennifer" -Surname "Tan" -SamAccountName "jtan" -UserPrincipalName "jtan@CSA.local" -Path "OU=Managers,DC=CSA,DC=local" -AccountPassword (ConvertTo-SecureString "jtPassw0rd!" -AsPlainText -Force) -Enabled $true
        New-ADUser -Name "Donald Lim" -GivenName "Donald" -Surname "Lim" -SamAccountName "dlim" -UserPrincipalName "dlim@CSA.local" -Path "OU=HR,DC=CSA,DC=local" -AccountPassword (ConvertTo-SecureString "dlPassw0rd!" -AsPlainText -Force) -Enabled $true
        New-ADUser -Name "Evelyn Chew" -GivenName "Evelyn" -Surname "Chew" -SamAccountName "echew" -UserPrincipalName "echew@CSA.local" -Path "OU=UserAccounts,DC=CSA,DC=local" -AccountPassword (ConvertTo-SecureString "ecPassw0rd!" -AsPlainText -Force) -Enabled $true
        New-ADUser -Name "Shanon Wee" -GivenName "Shanon" -Surname "Wee" -SamAccountName "swee" -UserPrincipalName "swee@CSA.local" -Path "OU=UserAccounts,DC=CSA,DC=local" -AccountPassword (ConvertTo-SecureString "swPassw0rd!" -AsPlainText -Force) -Enabled $true
        
        Write-Host "[+] jtan, dlim, echew, and swee user accounts added to CSA.local"

        #Easing password policy requirements
        Set-ADDefaultDomainPasswordPolicy -Identity CSA.local -ComplexityEnabled $false -MinPasswordLength 1 -PasswordHistoryCount 1

        #Adding new Domain Admin account
        Write-Host "[i] Adding csaAdmin Domain Admin account"
        New-ADUser -Name "csaAdmin" -AccountPassword (ConvertTo-SecureString 'P@ssw0rd123' -AsPlainText -Force) -Enabled $true
        Add-ADGroupMember -Identity "Domain Admins" -Members "csaAdmin"
        net localgroup Administrators csaAdmin /add
        Write-Host "[i] csaAdmin Domain Admin account added"

        #Modify scheduled task to complete as csaAdmin user in elevated context
        $trigger = New-ScheduledTaskTrigger -AtLogon -User 'csaAdmin';
        Set-ScheduledTask -TaskName 'SetupDC' -User 'csaAdmin' -Trigger $trigger;
        Write-Host "[i] Modified SetupDC scheduled task to complete as csaAdmin";

        #Changing autologon credentials to new user
        Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name 'DefaultUserName' -Type String -Value "csaAdmin";
        Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name 'DefaultPassword' -Type String -Value "P@ssw0rd123";
        Write-Host "[i] Changed autologon creds to CSA\csaAdmin";

        Start-Sleep -Seconds 3;
        Restart-Computer -Force;
    }
    #Step 4
    else {
        Unregister-ScheduledTask -TaskName 'SetupDC' -Confirm:$false;
        Write-Host "[i] Deleted SetupDC scheduled task";

        #Remove Autologon creds
        # Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name 'DefaultUserName' -Type String -Value "";
        # Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name 'DefaultPassword' -Type String -Value "";
        # Remove-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name 'AutoAdminLogon';
        # Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name 'DefaultDomainName' -Type String -Value "";
        # Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoLogonSID"
        # Write-Host "[i] Removed autologon credentials.";
    }
}
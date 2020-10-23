#In this example my WSUS server uses a proxy to get to the internet

#Add the WSUS role and install the required roles/features
Install-WindowsFeature -Name UpdateServices -IncludeManagementTools

#I recommend that you update the server from the internet to eliminate any possible feature bug

#Configure WSUS post install
#Create a directory for WSUS
New-Item 'C:\WSUS' -ItemType Directory
& 'C:\Program Files\Update Services\Tools\WsusUtil.exe' postinstall CONTENT_DIR=C:\WSUS

#Get a list of commands for WSUS
Get-Command -Module UpdateServices

#Change different WSUS config items
$wsus = Get-WSUSServer
$wsusConfig = $wsus.GetConfiguration()
Set-WsusServerSynchronization –SyncFromMU
$wsusConfig.UseProxy=$true
$wsusConfig.ProxyName='192.168.10.254'
$wsusConfig.Save()
$wsusConfig.AllUpdateLanguagesEnabled = $false
$wsusConfig.SetEnabledUpdateLanguages(“en”)
$wsusConfig.Save()
$wsusConfig.TargetingMode='Client'
$wsusConfig.Save()
#Get WSUS Subscription and perform initial synchronization to get latest categories
$subscription = $wsus.GetSubscription()
$subscription.StartSynchronizationForCategoryOnly()
# $subscription.GetSynchronizationStatus() should not be Running to be done
# $subscription.GetSynchronizationProgress() shows you the actual progress in case status is running

$wsusConfig.OobeInitialized = $true
$wsusConfig.Save()

#Get only 2016 updates
Get-WsusProduct | Where-Object {$_.Product.Title -ne "Windows Server 2016"} | Set-WsusProduct -Disable
Get-WsusProduct | Where-Object {$_.Product.Title -eq "Windows Server 2016"} | Set-WsusProduct
#Get only specific classifications
Get-WsusClassification | Where-Object { $_.Classification.Title -notin 'Update Rollups','Security Updates','Critical Updates','Updates','Service Packs'  } | Set-WsusClassification -Disable
Get-WsusClassification | Where-Object { $_.Classification.Title -in 'Update Rollups','Security Updates','Critical Updates','Updates','Service Packs'  } | Set-WsusClassification

#Start a sync
$subscription.StartSynchronization()
$subscription.GetSynchronizationProgress()
$subscription.GetSynchronizationStatus()

#Other things that should be done are configure auto approval rules and sync times

#Create wsus target groups
$wsus.CreateComputerTargetGroup('Servers')
$group = $wsus.GetComputerTargetGroups() | ? {$_.Name -eq "Servers"}
$wsus.CreateComputerTargetGroup("General",$group)

#Approve some updates for the Servers target group
Get-WsusUpdate | Select-Object -Skip 30 -First 1 | Approve-WsusUpdate -Action Install -TargetGroupName 'Servers'

#Fix WSUS AppPool stopping constantly
Import-Module WebAdministration
Set-ItemProperty IIS:\AppPools\WsusPool -Name recycling.periodicrestart.privateMemory -Value 2100000
$time=New-TimeSpan -Hours 4
Set-ItemProperty IIS:\AppPools\WsusPool -Name recycling.periodicrestart.time -Value $Time
Restart-WebAppPool -Name WsusPool

#Create a GPO and set client side targeting and intranet wsus server
#Intranet address: http://wsus01.testcorp.local:8530

#Test the updates on one of the servers that the GPO applies to
#Do not forget to issue a gpudate /force before

#Enable reports
#Install .NET 3.5 using the installation iso mounted in the virtual DVD drive (in this case)
Install-WindowsFeature NET-Framework-Core -Source D:\sources\sxs
#Install Microsoft CLR Types for SQL Server 2012
#Get it from: http://go.microsoft.com/fwlink/?LinkID=239644&clcid=0x409
Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i C:\2012.msi','/qn','/norestart' -Wait
#Install Microsoft report viewer redistributable 2012
#Get it from: https://www.microsoft.com/en-us/download/confirmation.aspx?id=35747
Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i "C:\ReportViewer 2012.msi"','/qn','/norestart','ALLUSERS=2' -Wait

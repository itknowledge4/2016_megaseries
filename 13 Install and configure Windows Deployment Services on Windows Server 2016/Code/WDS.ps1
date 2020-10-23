#Install the role
Install-WindowsFeature WDS -IncludeAllSubFeature -IncludeManagementTools

#See list of Powershell commands for WDS
Get-Command -Module WDS

#Initialize server
wdsutil /initialize-server /RemInst:"C:\REMINST"

#Create a new install image group
New-WdsInstallImageGroup -Name WS
#Import an install image
Import-WdsInstallImage -ImageGroup WS -Path D:\sources\install.wim -ImageName 'Windows Server 2016 SERVERSTANDARDCORE'
Import-WdsInstallImage -ImageGroup WS -Path D:\sources\install.wim -ImageName 'Windows Server 2016 SERVERSTANDARD'
#import a boot image
Import-WdsBootImage -Path D:\sources\boot.wim

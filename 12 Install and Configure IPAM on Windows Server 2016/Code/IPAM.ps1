#Before beginning make sure you run this command on your DHCP servers
#It creates the DHCP Users and Administrators local groups which are not created by default
#IPAM needs these groups to grant access to the DHCP service
Invoke-Command -ScriptBlock {Add-DhcpServerSecurityGroup} -ComputerName DHCP01,DHCP02

#Install IPAM
Install-WindowsFeature IPAM -IncludeManagementTools

#IPAM server provisioning
Invoke-IpamServerProvisioning -ProvisioningMethod Automatic -GpoPrefix ipam -Force
#Select domain
Add-IpamDiscoveryDomain -Name testcorp.local -Confirm:$false -DiscoverDc $true -DiscoverDns $true -DiscoverDhcp $true
#IPAM GPO provisioning
Invoke-IpamGpoProvisioning -Domain testcorp.local -GpoPrefixName ipam -IpamServerFqdn IPAM01.testcorp.local -Force

#After this command you can scan for servers, add them to be managed and you have to either wait for GPOs to apply or force them to apply
Start-ScheduledTask -TaskPath '\Microsoft\Windows\IPAM\' -TaskName 'ServerDiscovery'
Get-ScheduledTask -TaskPath '\Microsoft\Windows\IPAM\' -TaskName 'ServerDiscovery'

#Get a list of servers that have been discovered by IPAM
Get-IpamServerInventory
#Get only the servers that have not been configured yet to be managed
Get-IpamServerInventory | Where-Object {$_.ManageabilityStatus -eq 'Unspecified'}
#Set all unmanaged servers as managed
Get-IpamServerInventory | Where-Object {$_.ManageabilityStatus -eq 'Unspecified'} | Set-IpamServerInventory -ManageabilityStatus Managed
#Get a list of DHCP servers in IPAM
Get-IpamServerInventory | where {'DHCP' -in $_.ServerType} | Select-Object -ExpandProperty Name

#For the DHCP servers, after gpupdate you have to also restart the server
Invoke-Command -ScriptBlock {gpupdate /force} -ComputerName DC01,DC02
Invoke-Command -ScriptBlock {Restart-Computer -Force} -ComputerName DHCP01,DHCP02

#Update server availability
Start-ScheduledTask -TaskPath '\Microsoft\Windows\IPAM\' -TaskName 'ServerDiscovery'
Get-ScheduledTask -TaskPath '\Microsoft\Windows\IPAM\' -TaskName 'ServerDiscovery'

#See a list of commands that are in the IPAM module
Get-Command -Module IpamServer


#Create an address block
Add-IpamBlock -NetworkId 192.168.10.0/24 -StartIPAddress 192.168.10.0 -EndIPAddress 192.168.10.255 -LastAssignedDate (Get-Date)

#Create an address range
Add-IpamRange -NetworkId 192.168.10.0/24 -StartIPAddress 192.168.10.151 -EndIPAddress 192.168.10.254 -ManagedByService 'IPAM' -ServiceInstance 'localhost' -AssignmentType Static -AssignmentDate (Get-Date)

#Create an IP address
Add-IpamAddress -IpAddress 192.168.10.1 -ManagedByService 'IPAM' -ServiceInstance 'Localhost' -DeviceType 'Microsoft Servers' -IpAddressState 'In-Use' -AssignmentType Static -AssignmentDate (Get-Date) -DeviceName 'DC01'

#Import IP addresses into IPAM
Import-IpamAddress -AddressFamily IPv4 -Path "C:\import.csv" -Force
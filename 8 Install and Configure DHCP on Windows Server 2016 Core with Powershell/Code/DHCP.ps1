#Install the DHCP Role
Install-WindowsFeature DHCP
#Create scope and set options
Add-DhcpServerv4Scope -StartRange 192.168.10.100 -EndRange 192.168.10.150 -SubnetMask 255.255.255.0 -Name 192.168.10.X -LeaseDuration 0.02:00:00
Set-DhcpServerv4OptionValue -ScopeId 192.168.10.0 -DnsServer 192.168.10.1,192.168.10.2 -Router 192.168.10.254 -DnsDomain 'testcorp.local'
#Get a list of scopes
Get-DhcpServerv4Scope

#Run directly on the DHCP server or another server (no remoting)
#Authorize the DHCP server
Add-DhcpServerInDC -DnsName DHCP01.testcorp.local
#if you run it from the dhcp server -DnsName is not needed

#If you manage this server with server manager a warning might appear regarding authorizing the DHCP server. Since we did it already let's make the message disappear
Set-ItemProperty –Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2


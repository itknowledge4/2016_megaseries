#Add the new DC to the group for clonable DCs
Add-ADGroupMember 'Cloneable Domain Controllers' -Members 'CN=DC02,OU=Domain Controllers,DC=testcorp,DC=local'
#Make sure that you do not have anything that does not support DC cloning
Get-ADDCCloningExcludedApplicationList
#In case you get anything then it means that item is not supported for cloning
#You can generate an exclusion list to keep them of uninstall/delete them
Get-ADDCCloningExcludedApplicationList -GenerateXml
#Generate a config file for cloning
New-ADDCCloneConfigFile -Static -IPv4Address 192.168.10.253 -IPv4DefaultGateway 192.168.10.254 -IPv4DNSResolver 192.168.10.1 -IPv4SubnetMask 255.255.255.0 -CloneComputerName DC03
#Now we stop the DC02 VM and export it then import it or just copy the HDD and create a new VM using it
#Start the 2 domain controllers; after 2-3 minutes DC03 should appear as a DC in AD

#Remove the 2 DCs from the clonable group for security
Remove-ADGroupMember -Identity 'Cloneable Domain Controllers' -Members 'CN=DC02,OU=Domain Controllers,DC=testcorp,DC=local' -Confirm:$false
Remove-ADGroupMember -Identity 'Cloneable Domain Controllers' -Members 'CN=DC03,OU=Domain Controllers,DC=testcorp,DC=local' -Confirm:$false
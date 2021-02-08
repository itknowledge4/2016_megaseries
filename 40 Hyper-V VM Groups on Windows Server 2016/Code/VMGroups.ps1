#create 2 collection vm group
New-VMGroup -Name 'VMGroup1' -GroupType VMCollectionType
New-VMGroup -Name 'VMGroup2' -GroupType VMCollectionType
#create a management VM group
New-VMGroup -Name 'MgmtGroup' -GroupType ManagementCollectionType

#Add VMs to the collection groups
Add-VMGroupMember -Name 'VMGroup1' -VM (Get-VM 'TestVM2')
Add-VMGroupMember -Name 'VMGroup2' -VM (Get-VM 'TestVM3')

#Add the collection groups to the management group
Add-VMGroupMember -Name 'MgmtGroup' -VMGroupMember (Get-VMGroup 'VMGroup1')
Add-VMGroupMember -Name 'MgmtGroup' -VMGroupMember (Get-VMGroup 'VMGroup2')

#Get the groups
Get-VMGroup -Name 'VMGroup1'
Get-VMGroup -Name 'VMGroup2'
Get-VMGroup -Name 'MgmtGroup'

#Get info about VMs related to groups
Get-VM | select Name,Groups

Start-VM -VM (Get-VMGroup 'MgmtGroup').VMGroupMembers.VMMembers
###Commands to run on the server hosting the iSCSI target
New-IscsiServerTarget -TargetName StorageForFS01
New-IscsiVirtualDisk -Path D:\iSCSI\Quorum.VHDX -Size 1GB
Add-IscsiVirtualDiskTargetMapping -TargetName 'StorageForFS01' -Path D:\iSCSI\Quorum.VHDX
New-IscsiVirtualDisk -Path D:\iSCSI\Data1.VHDX -Size 3GB
Add-IscsiVirtualDiskTargetMapping -TargetName 'StorageForFS01' -Path D:\iSCSI\Data1.VHDX
New-IscsiVirtualDisk -Path D:\iSCSI\Data2.VHDX -Size 40GB
Add-IscsiVirtualDiskTargetMapping -TargetName 'StorageForFS01' -Path D:\iSCSI\Data2.VHDX
#Permit the 2 servers to mount the LUNs from the target by their iscsi initiator addresses
set-IscsiServerTarget -TargetName 'StorageForFS01' -InitiatorIds 'IQN:iqn.1991-05.com.microsoft:fs01a.testcorp.local','IQN:iqn.1991-05.com.microsoft:fs01b.testcorp.local'
#Values that we can use for iniator ids are: DNSName, IPAddress, IPv6Address, IQN and MACAddress (DNSName:...)

###Commands to be run on both cluster nodes
Set-Service -Name MSiSCSI -StartupType Automatic
Start-Service MSiSCSI
Get-NetFirewallServiceFilter -Service msiscsi | Get-NetFirewallRule | Enable-NetFirewallRule
#use one of these commands to get the iscsi initiator address for the servers
iscsicli.exe
Get-InitiatorPort | select -ExpandProperty NodeAddress
#Start to connect the storage
New-IscsiTargetPortal -TargetPortalAddress WDS01
Get-IscsiTarget | Connect-IscsiTarget
#see if the disks have been mounted
Get-Disk
#To persist the disks across reboots use this command
Get-IscsiSession | Register-IscsiSession

#Or just use invoke-command on both at the same time
Invoke-Command -Scriptblock {Set-Service -Name MSiSCSI -StartupType Automatic;Start-Service MSiSCSI;Get-NetFirewallServiceFilter -Service msiscsi | Get-NetFirewallRule | Enable-NetFirewallRule;New-IscsiTargetPortal -TargetPortalAddress WDS01;Get-IscsiTarget | Connect-IscsiTarget;Get-IscsiSession | Register-IscsiSession} -ComputerName FS01A,FS01B

###Start installing and configuring cluster
#Run on both nodes to install feature
Invoke-Command -ScriptBlock{Install-WindowsFeature Failover-Clustering -IncludeManagementTools} -ComputerName FS01A,FS01B
#See all CmdLets
Get-Command -Module FailoverClusters

#Run the commands directly on one of the cluster nodes (not through ps remoting)
Test-Cluster -Node FS01A,FS01B
New-Cluster -Name FS01 -Node FS01A,FS01B -StaticAddress 192.168.10.11

#Set the cluster name to register a PTR record (recource has to be taken offline and online)
Get-ClusterResource -Name 'Cluster Name' | Set-ClusterParameter -Name PublishPTRRecords -Value 1
Stop-ClusterResource -Name 'Cluster Name'
Start-ClusterResource -Name 'Cluster Name'

#Run the commands on one of the cluster nodes
#Format the quorum disk
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter
Format-Volume -DriveLetter D -FileSystem NTFS -Confirm:$false
#add it to the cluster
Get-Disk -Number 1 | Add-ClusterDisk
Set-ClusterQuorum -NodeAndDiskMajority 'Cluster Disk 1'
#Initialize the other 2 disks
Initialize-Disk -Number 2 -PartitionStyle GPT
Initialize-Disk -Number 3 -PartitionStyle GPT
New-Partition -DiskNumber 2 -UseMaximumSize -AssignDriveLetter
New-Partition -DiskNumber 3 -UseMaximumSize -AssignDriveLetter
Format-Volume -DriveLetter E -FileSystem NTFS -Force -Confirm:$false
Format-Volume -DriveLetter F -FileSystem NTFS -Force -Confirm:$false
Get-Disk -Number 2 | Add-ClusterDisk
Get-Disk -Number 3 | Add-ClusterDisk
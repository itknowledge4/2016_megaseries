#Prepare the LUNs
New-IscsiServerTarget -TargetName 'HVS03Storage'
New-IscsiVirtualDisk -Path D:\iSCSI\HVS03Q.VHDX -Size 1GB
Add-IscsiVirtualDiskTargetMapping -TargetName 'HVS03Storage' -Path D:\iSCSI\HVS03Q.VHDX
New-IscsiVirtualDisk -Path D:\iSCSI\HVS03D.VHDX -Size 30GB
Add-IscsiVirtualDiskTargetMapping -TargetName 'HVS03Storage' -Path D:\iSCSI\HVS03D.VHDX
Set-IscsiServerTarget -TargetName 'HVS03Storage' -InitiatorIds 'IQN:iqn.1991-05.com.microsoft:hvs03a.testcorp.local','IQN:iqn.1991-05.com.microsoft:hvs03b.testcorp.local'

#Connect to the LUNs from both hosts
Set-Service -Name MSiSCSI -StartupType Automatic
Start-Service MSiSCSI
Get-NetFirewallServiceFilter -Service msiscsi | Get-NetFirewallRule | Enable-NetFirewallRule
New-IscsiTargetPortal -TargetPortalAddress bcm01
Get-IscsiTarget | Connect-IscsiTarget
Get-IscsiSession | Register-IscsiSession
#Or run all commands with invoke-command
Invoke-Command -Scriptblock {Set-Service -Name MSiSCSI -StartupType Automatic;Start-Service MSiSCSI;Get-NetFirewallServiceFilter -Service msiscsi | Get-NetFirewallRule | Enable-NetFirewallRule;New-IscsiTargetPortal -TargetPortalAddress wds01;Get-IscsiTarget | Connect-IscsiTarget;Get-IscsiSession | Register-IscsiSession} -Computername 'HVS03A','HVS03B'

#Install Failover Clustering on both nodes
Install-WindowsFeature Failover-Clustering -IncludeManagementTools
#Or
Invoke-Command -Scriptblock {Install-WindowsFeature Failover-Clustering -IncludeManagementTools} -Computername 'HVS03A','HVS03B'

#Run the commands directly on one of the nodes
Test-Cluster -Node HVS03A,HVS03B
New-Cluster -Name HVS03 -Node HVS03A,HVS03B -StaticAddress 192.168.10.13
Get-ClusterResource -Name 'Cluster Name' | Set-ClusterParameter -Name PublishPTRRecords -Value 1
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter
Format-Volume -DriveLetter D -FileSystem NTFS -Confirm:$false
Get-Disk -Number 1 | Add-ClusterDisk
Start-Sleep -Seconds 3
Set-ClusterQuorum -NodeAndDiskMajority 'Cluster Disk 1'
Initialize-Disk -Number 2 -PartitionStyle GPT
New-Partition -DiskNumber 2 -UseMaximumSize -AssignDriveLetter
Format-Volume -DriveLetter E -FileSystem NTFS -Force -Confirm:$false
Get-Disk -Number 2 | Add-ClusterDisk
Start-Sleep -Seconds 3
Add-ClusterSharedVolume -Name 'Cluster Disk 2'
####

#Run on both nodes
Set-VMHost -VirtualHardDiskPath 'C:\ClusterStorage\Volume1\VMs' -VirtualMachinePath 'C:\ClusterStorage\Volume1\VMs'
#or
Invoke-Command -Scriptblock {Set-VMHost -VirtualHardDiskPath 'C:\ClusterStorage\Volume1\VMs' -VirtualMachinePath 'C:\ClusterStorage\Volume1\VMs' -EnableEnhancedSessionMode $true} -Computername 'HVS03A','HVS03B'
###

#Run on one of the hosts
New-VM -BootDevice CD -MemoryStartupBytes 64MB -Name 'TestVMC' -NewVHDSizeBytes 30MB -NewVHDPath 'C:\ClusterStorage\Volume1\VMs\Virtual Machines\TestVMC.vhdx'
Add-ClusterVirtualMachineRole -VMName TestVMC #Run this command directly on the server - no remoting
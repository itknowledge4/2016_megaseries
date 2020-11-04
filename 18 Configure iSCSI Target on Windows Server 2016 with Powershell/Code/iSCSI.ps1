Install-WindowsFeature FS-iSCSITarget-Server

#Create a target, a disk and assign the disk to the target
New-IscsiServerTarget -TargetName TestStorage
New-IscsiVirtualDisk -Path D:\iSCSI\disk1.VHDX -Size 1GB
Add-IscsiVirtualDiskTargetMapping -TargetName 'TestStorage' -Path D:\iSCSI\disk1.VHDX

#Permit only a specific server to mount the disk from the newly created target
Set-IscsiServerTarget -TargetName 'TestStorage' -InitiatorIds 'IQN:iqn.1991-05.com.microsoft:ipam01.testcorp.local'
#To get the IQN just use the command: iscsicli

#####Run the following commands on the iSCSI initiator host
#Prepare the initiator
Set-Service -Name MSiSCSI -StartupType Automatic
Start-Service MSiSCSI
Get-NetFirewallServiceFilter -Service msiscsi | Get-NetFirewallRule | Enable-NetFirewallRule

#Connect to the target and mount the disks
New-IscsiTargetPortal -TargetPortalAddress wds01
Get-IscsiTarget | Connect-IscsiTarget
#see if the disk has been mounted
Get-Disk
#To persiste the disks accross reboots run also this command
Get-IscsiSession | Register-IscsiSession
#Create a partition
Get-Disk -Number 1 | Initialize-Disk -PartitionStyle GPT –Passthru | New-Partition –AssignDriveLetter –UseMaximumSize | Format-Volume -FileSystem NTFS -Confirm:$false

####Resize an iSCSI disk (on iSCSI target server)
Resize-IscsiVirtualDisk -Path D:\iSCSI\disk1.VHDX -Size 2GB

####Refrash the disks on the iSCSI client
Update-HostStorageCache
Resize-Partition -DriveLetter E -Size (Get-PartitionSupportedSize -DriveLetter E).SizeMax
### On the host server create a couple of VHDX files for the test machine
1..4 | ForEach-Object { New-VHD -Path "D:\HDD\WDS01_$_.vhdx" -SizeBytes 20GB  }
5..20 | ForEach-Object { New-VHD -Path "D:\HDD\WDS01_$_.vhdx" -SizeBytes 40GB  }
1..20 | ForEach-Object {Add-VMHardDiskDrive -VMName 'WDS01' -ControllerType SCSI -Path "D:\HDD\WDS01_$_.vhdx"}

### On the VM
#Get a list of disks that can be used in a storage pool
Get-PhysicalDisk -CanPool $true
#Get all storage pools
Get-StoragePool

#Create a storage pool with the first 10 disks
New-StoragePool –FriendlyName StoragePool1 –PhysicalDisks (Get-PhysicalDisk -CanPool $true | sort size | select -first 10) -StorageSubSystemFriendlyName "Windows Storage*"
#Add the remaining disks as hot spares to the pool
Add-PhysicalDisk -StoragePoolFriendlyName 'StoragePool1' -PhysicalDisks (Get-PhysicalDisk -CanPool $true | sort size | select -first 10) -Usage HotSpare
#In case you want to change the usage type for a disk it is possible while it is in the pool
Get-PhysicalDisk -Usage HotSpare | Set-PhysicalDisk -Usage AutoSelect
#To get only the disks in this storage pool
Get-PhysicalDisk -StoragePool (Get-StoragePool StoragePool1)

#get the mediatype of the disks
Get-PhysicalDisk -StoragePool (Get-StoragePool StoragePool1) | Select-Object FriendlyName,mediatype,size | Sort-Object size
#You can change the mediatype property for disks (in production you should not have to do ti and should not; this is only so we can test further)
Get-PhysicalDisk -StoragePool (Get-StoragePool StoragePool1) | Sort-Object size | Select-Object -First 4 | Set-PhysicalDisk -MediaType SSD
Get-PhysicalDisk -StoragePool (Get-StoragePool StoragePool1) | Sort-Object size | Select-Object -Last 16 | Set-PhysicalDisk -MediaType HDD

#Create the 2 tiers
New-StorageTier -StoragePoolFriendlyName 'StoragePool1' -FriendlyName 'Fast' -MediaType SSD
New-StorageTier -StoragePoolFriendlyName 'StoragePool1' -FriendlyName 'Slow' -MediaType HDD
#Get a list of tiers in a storage pool
Get-StorageTier -StoragePool (Get-StoragePool StoragePool1)
#Get the supported size of a space in a tier
Get-StorageTierSupportedSize Slow -ResiliencySettingName 'Simple'
Get-StorageTierSupportedSize Fast -ResiliencySettingName 'Mirror'

#after you create a pool make sure that this is set otherwise set it (if you do not use hot spare)
Set-StoragePool -FriendlyName 'StoragePool1' -RetireMissingPhysicalDisks Always
#Restart server to apply this setting

#Create a dual parity disk (for a single parity just do not use -PhysicalDiskRedundancy 2)
New-VirtualDisk -StoragePoolFriendlyName "StoragePool1" -FriendlyName "VirtualDisk1" -Size 2GB -ProvisioningType Thin -ResiliencySettingName "Parity" -PhysicalDiskRedundancy 2
#Create a volume
Get-VirtualDisk –FriendlyName VirtualDisk1 | Get-Disk | Initialize-Disk -PartitionStyle GPT –Passthru | New-Partition –AssignDriveLetter –UseMaximumSize | Format-Volume -FileSystem NTFS -Confirm:$false

#create a simple thin provisioned disk
New-VirtualDisk -StoragePoolFriendlyName 'StoragePool1' -FriendlyName 'VirtualDisk2' -ResiliencySettingName 'Simple' -Size 2GB -ProvisioningType Thin
#Create a volume
Get-VirtualDisk –FriendlyName VirtualDisk2 | Get-Disk | Initialize-Disk -PartitionStyle GPT –Passthru | New-Partition –AssignDriveLetter –UseMaximumSize | Format-Volume -FileSystem NTFS -Confirm:$false

#Create a 3 way mirror disk with tiering (if you want a normal mirror disk do not use -NumberOfDataCopies 3)
$Fast=Get-StorageTier Fast
$Slow=Get-StorageTier Slow
New-VirtualDisk -StoragePoolFriendlyName 'StoragePool1' -FriendlyName 'VirtualDisk3' -ResiliencySettingName 'Mirror' -NumberOfDataCopies 3 -StorageTiers $Fast,$Slow -StorageTierSizes 2GB,4GB
#Create a volume
Get-VirtualDisk –FriendlyName VirtualDisk3 | Get-Disk | Initialize-Disk -PartitionStyle GPT –Passthru | New-Partition –AssignDriveLetter –UseMaximumSize | Format-Volume -FileSystem NTFS -Confirm:$false
#Create a file on the new mirror volume (test.txt)
#Configure the file to be moved on the Fast tier
Set-FileStorageTier -FilePath G:\test.txt -DesiredStorageTierFriendlyName 'VirtualDisk3_Fast'

#Get a list of the scheduled tasks that control storage tiering
Get-ScheduledTask -TaskName *Tier* 
#The initialization task does the analysis of the hot and cold blocks of data
#The optimization task moves the blocks to or from a tier
#To run the optimization task on demand
Start-ScheduledTask -TaskName 'Storage Tiers Optimization' -TaskPath '\Microsoft\Windows\Storage Tiers Management\'

#Get a list of the virtual disks on the server
Get-VirtualDisk
#Remove a disk from the VM and run this command again

#Add a new disk to the VM, add it to the pool and set the media type
Add-PhysicalDisk -StoragePoolFriendlyName 'StoragePool1' -PhysicalDisks (Get-PhysicalDisk -CanPool $true) -Usage AutoSelect
Get-PhysicalDisk -StoragePool (Get-StoragePool StoragePool1) | Where-Object {$_.mediatype -eq 'UnSpecified'} | Set-PhysicalDisk -MediaType HDD

#To remove the Failed disk we have to remove also the failed remaining virtual disk
#Remove-VirtualDisk -FriendlyName VirtualDisk2 -Confirm:$false
Remove-PhysicalDisk -StoragePoolFriendlyName StoragePool1 -PhysicalDisks (Get-PhysicalDisk | Where-Object {$_.OperationalStatus -ne 'OK'}) -Confirm:$false

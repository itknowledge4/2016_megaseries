#Create test VMs
New-VM -BootDevice CD -MemoryStartupBytes 64MB -Name 'TestVM5' -Generation 2
New-VM -BootDevice CD -MemoryStartupBytes 64MB -Name 'TestVM6' -Generation 2

New-VHD -Path C:\ClusterStorage\Volume1\new.vhds -SizeBytes 10MB -Dynamic
Add-VMHardDiskDrive -VMName 'TestVM6' -Path 'C:\ClusterStorage\Volume1\new.vhds' -SupportPersistentReservations
Add-VMHardDiskDrive -VMName 'TestVM5' -Path 'C:\ClusterStorage\Volume1\new.vhds' -SupportPersistentReservations
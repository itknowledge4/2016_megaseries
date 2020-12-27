#Create a test VM
New-VMSwitch -Name 'Ext' -NetAdapterName (Get-NetAdapter).Name
New-VM -Name 'TestVM1' -NewVHDSizeBytes 30GB -NewVHDPath 'C:\VMs\Virtual Machines\TestVM1.vhdx' -Generation 2 -SwitchName 'Ext' -MemoryStartupBytes 2048MB

#Checkpoint operations
Set-VM -CheckpointType ProductionOnly -Name 'TestVM1'
Checkpoint-VM -Name 'TestVM1' -SnapshotName 'Snap 1'
Get-VMSnapshot -VMName 'TestVM1'
Checkpoint-VM -Name 'TestVM1' -SnapshotName 'Snap 2'
Restore-VMSnapshot -VMName 'TestVM1' -Name 'Snap 1' -Confirm:$false
Remove-VMSnapshot -VMName 'TestVM1' -Name 'Snap 2'
Remove-VMSnapshot -VMName 'TestVM1' -Name 'Snap 1' -IncludeAllChildSnapshots

#Set checkpoint type to standard
Set-VM -CheckpointType Standard -Name 'TestVM1'
#Disable checkpoints
Set-VM -CheckpointType Disabled -Name 'TestVM1'

#VM export and import
#Create a folder for exporting VMs
mkdir C:\Export
mkdir C:\Import
#Export VM to a path that will be created at export time
Export-VM -Path 'C:\Export' -Name 'TestVM1'
#On the other server create a folder to copy the exported machines
mkdir C:\Import
mkdir C:\Export
#Import VM and keep the files exactly where they are
Import-VM -Path 'C:\Import\TestVM1\Virtual Machines\{id}.VMCX'
#Import VM and copy the files to the default locations (VHDs may be put directly in the configured location)
Import-VM -Path 'C:\Import\TestVM1\Virtual Machines\{id}.VMCX' -Copy
#Import VM and copy the files to the default locations (specify a location for the disk files)
Import-VM -Path 'C:\Import\TestVM1\Virtual Machines\{id}.VMCX' -Copy -VhdDestinationPath 'C:\VMs\Virtual Machines'

#Export and import a VM snapshot (new in Windows Server 2012 R2)
#Get the VM snapshot first
Checkpoint-VM -Name 'TestVM1' -SnapshotName 'Snap 1'
$snap=Get-VMSnapshot -VMName 'TestVM1' -Name 'Snap 1'
Export-VMSnapshot -VMSnapshot $snap -Path C:\Export
#Import the snapshot as a VM (the snapshot name will be the VM name)
Import-VM -Path 'C:\Import\TestVM1\Virtual Machines\{id}.VMCX' -Copy

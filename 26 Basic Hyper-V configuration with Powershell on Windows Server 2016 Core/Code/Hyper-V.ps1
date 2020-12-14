#Install Hyper-V and management tools
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart

Get-Command -Module Hyper-V

#Set some general hyper-v settings
Set-VMHost -VirtualHardDiskPath 'C:\VMs' -VirtualMachinePath 'C:\VMs' -EnableEnhancedSessionMode $true
Get-VMHost
Get-VMHost | fl *

#Create a new private switch
New-VMSwitch -Name 'TestSW' -SwitchType Private

#Creating VMs and VHD files
#Create a simple VM that boots from the CD and has a 128MB startup RAM value
New-VM -BootDevice CD -MemoryStartupBytes 128MB -Name 'TestVM1'
#Create the VM and assign it a switch; also make it generation 2
New-VM -BootDevice CD -MemoryStartupBytes 512MB -Name 'TestVM2' -SwitchName 'TestSW' -Generation 2
#Create the VM also with a VHDX that is dynamically expanding to max 300MB
New-VM -BootDevice CD -MemoryStartupBytes 64MB -Name 'TestVM3' -NewVHDSizeBytes 300MB -NewVHDPath 'C:\VMs\Virtual Machines\TestVM3.vhdx'
#Delete a VM; does not delete any HDDs that the VM uses
Remove-VM -Name 'TestVM3' -Confirm:$false -Force
#Create the VM and give it an existing VHDX file
New-VM -BootDevice CD -MemoryStartupBytes 128MB -Name 'TestVM3' -VHDPath 'C:\VMs\Virtual Machines\TestVM3.vhdx'

#Set some VM parameters
Set-VM -ProcessorCount 2 -DynamicMemory -Name 'TestVM1' -MemoryMinimumBytes 128MB -MemoryMaximumBytes 512MB -AutomaticStartAction Nothing -AutomaticStopAction ShutDown -AutomaticStartDelay 60 -Notes 'Just a test VM'
#Change a VM's startup order for Gen1 machines
Get-VMBios -VMName 'TestVM1'
$NewOrder='IDE','CD','Floppy','LegacyNetworkAdapter'
Set-VMBios -VMName 'TestVM1' -StartupOrder $NewOrder
#Change a VM's startup order for Gen2 machines
Get-VMFirmware -VMName 'TestVM2'
$nic=Get-VMNetworkAdapter -VMName 'TestVM2'
$dvd=Get-VMDvdDrive -VMName 'TestVM2'
$NewOrder=$nic,$dvd
Set-VMFirmware -VMName 'TestVM2' -BootOrder $NewOrder
#Configure SecureBoot
Set-VMFirmware -VMName 'TestVM2' -EnableSecureBoot Off
Set-VMFirmware -VMName 'TestVM2' -EnableSecureBoot On
#Set advanced memory settings like weight and priority (startupbytes and so on can be also modified)
Set-VMMemory -Buffer 10 -Priority 30 -VMName 'TestVM1'
#Configure VM integration service checkboxes
Get-VMIntegrationService -VMName TestVM1
Disable-VMIntegrationService -Name 'Time Synchronization' -VMName 'TestVM1'
Enable-VMIntegrationService -Name 'Guest Service Interface' -VMName 'TestVM2'

#Work with disks
#Create a new VHDX that is fixed
New-VHD -LogicalSectorSizeBytes 4096 -Path 'C:\VMs\Virtual Machines\TestVM3_D.VHDX' -SizeBytes 120MB -Fixed
Add-VMHardDiskDrive -ControllerType SCSI -Path 'C:\VMs\Virtual Machines\TestVM3_D.VHDX' -VMName 'TestVM3'
Get-VMHardDiskDrive -VMName 'TestVM3'
Remove-VMHardDiskDrive -VMName 'TestVM3' -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0

#Clean up
Remove-VM -Name 'TestVM1' -Confirm:$false -Force
Remove-VM -Name 'TestVM2' -Confirm:$false -Force
Remove-VM -Name 'TestVM3' -Confirm:$false -Force
Remove-Item 'C:\VMs\Virtual Machines\TestVM3.vhdx'
Remove-Item 'C:\VMs\Virtual Machines\TestVM3_D.VHDX'
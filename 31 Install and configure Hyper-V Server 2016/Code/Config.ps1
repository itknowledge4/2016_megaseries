Set-VMHost -VirtualHardDiskPath 'C:\VMs' -VirtualMachinePath 'C:\VMs' -EnableEnhancedSessionMode $true
#Create a new private switch
New-VMSwitch -Name 'TestSW' -SwitchType Private
New-VMSwitch -Name 'Ext' -NetAdapterName (Get-NetAdapter).Name
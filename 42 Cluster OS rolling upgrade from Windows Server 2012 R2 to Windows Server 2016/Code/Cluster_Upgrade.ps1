#Run on the 2016 node directly (no ps remoting)
Add-ClusterNode -Name HVS04C -Cluster HVS04
Add-ClusterNode -Name HVS04D -Cluster HVS04
#Run on a 2016 node to see the cluster functional level
Get-Cluster | Select ClusterFunctionalLevel

#Pause the first node
Suspend-ClusterNode -Name HVS04A -Confirm:$false -Drain
#Remove node from the cluster
Remove-ClusterNode -Name HVS04A -Force
#Pause the second node
Suspend-ClusterNode -Name HVS04B -Confirm:$false -Drain
#Remove node from the cluster
Remove-ClusterNode -Name HVS04B -Force

Update-ClusterFunctionalLevel -Force
Get-Cluster | Select ClusterFunctionalLevel

Invoke-Command -Scriptblock {Set-VMHost -VirtualHardDiskPath 'C:\ClusterStorage\Volume1\VMs' -VirtualMachinePath 'C:\ClusterStorage\Volume1\VMs' -EnableEnhancedSessionMode $true} -Computername 'HVS04C','HVS04D'
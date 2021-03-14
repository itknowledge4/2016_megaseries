#After you install a Failover Cluster and configure CSV, the Storage QoS Resource is shown as a cluster core resource
Get-ClusterResource -Name "Storage Qos Resource"

#Get flows
Get-StorageQosFlow
Get-StorageQoSflow | Sort-Object InitiatorName | ft InitiatorName, Status, MinimumIOPs, MaximumIOPs, StorageNodeIOPs, Status, @{Expression={$_.FilePath.Substring($_.FilePath.LastIndexOf('\')+1)};Label="File"}, @{Expression={$_.InitiatorNodeName.Substring(0,$_.InitiatorNodeName.IndexOf('.'))};Label="InitiatorNodeName"} -AutoSize

#Get info about volume
Get-StorageQosVolume

#Create and assign a policy
$Policy1 = New-StorageQosPolicy -Name Test1 -PolicyType Dedicated -MinimumIops 20 -MaximumIops 70
Get-StorageQosPolicy
Get-VM -Name TestVM20 | Get-VMHardDiskDrive | Set-VMHardDiskDrive -QoSPolicyID $policy1.PolicyID
Get-StorageQosPolicy -Name Test1 | Set-StorageQosPolicy -MaximumIops 600

#Delete a policy and remove it from the VM
Get-StorageQosPolicy -Name Test1 | Remove-StorageQosPolicy -Confirm:$false
Get-StorageQoSflow | Sort-Object InitiatorName | ft InitiatorName, Status, MinimumIOPs, MaximumIOPs, StorageNodeIOPs, Status, @{Expression={$_.FilePath.Substring($_.FilePath.LastIndexOf('\')+1)};Label="File"} -AutoSize
Get-VM -Name TestVM20 | Get-VMHardDiskDrive | Set-VMHardDiskDrive -QoSPolicyID $null

#Get and modify normalization settings
Get-StorageQosPolicyStore
Set-StorageQosPolicyStore -IOPSNormalizationSize 1MB
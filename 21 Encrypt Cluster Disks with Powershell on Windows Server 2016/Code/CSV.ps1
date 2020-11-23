#Create a GPO and enable Choose how bitlocker-protected fixed drivers can be recovered
#Update the policy on both nodes (or just install bitlocker and then restart)

#Install the bitlocker feature
Invoke-Command -ScriptBlock {Add-WindowsFeature BitLocker -Restart} -ComputerName FS01A
Invoke-Command -ScriptBlock {Add-WindowsFeature BitLocker -Restart} -ComputerName FS01B

#If the disk that you want to encrypt is already used in the cluser it must be placed in maintenance mode
Get-ClusterSharedVolume "Cluster Disk 3" | Suspend-ClusterResource -Force
Get-ClusterResource "Cluster Disk 2" | Suspend-ClusterResource -Force

#Enable Bitlocker and backup the protector to AD
Enable-BitLocker 'C:\ClusterStorage\Volume1' -RecoveryPasswordProtector
Enable-BitLocker 'E:\' -RecoveryPasswordProtector
$protectorId1 = (Get-BitLockerVolume 'C:\ClusterStorage\Volume1').Keyprotector | Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"}
$protectorId2 = (Get-BitLockerVolume 'E:\').Keyprotector | Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"}
Backup-BitLockerKeyProtector 'C:\ClusterStorage\Volume1' -KeyProtectorId $protectorId1.KeyProtectorId
Backup-BitLockerKeyProtector 'E:\' -KeyProtectorId $protectorId2.KeyProtectorId

#Run these commands directly on a node of the cluster
#Get the cluster name object
$cno = (Get-Cluster).name + '$'
#Add the cno to the disk as a protector so that the cluster can manage encryption and decryption
Add-BitLockerKeyProtector 'C:\ClusterStorage\Volume1' -ADAccountOrGroupProtector –ADAccountOrGroup $cno
Add-BitLockerKeyProtector 'E:\' -ADAccountOrGroupProtector –ADAccountOrGroup $cno
######

#Resume using the volume
Get-ClusterSharedVolume 'Cluster Disk 3' | Resume-ClusterResource
Get-ClusterResource "Cluster Disk 2" | Resume-ClusterResource

#If you want to see the recovery info install this feature on a server with ADUC
Install-WindowsFeature RSAT-Feature-Tools-BitLocker-BdeAducExt
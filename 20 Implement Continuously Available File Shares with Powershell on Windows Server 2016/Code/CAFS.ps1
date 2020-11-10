#Install the fs role on both nodes
Invoke-Command -ScriptBlock {Add-WindowsFeature File-Services} -ComputerName FS01A,FS01B

#Make sure that FS01$ has Create computer objects permissions on the OU where we will put our FS01G object
#By default this is in the same OU where the cluster object is located

###General file server (HA shares)
#Run directly on a cluster node (no remoting) to create a clustered general purpose file server
Add-ClusterFileServerRole -StaticAddress <ip> -Name 'FS01G' -Storage 'Cluster Disk 2'

Get-ClusterResource -Name 'FS01G' | Set-ClusterParameter -Name PublishPTRRecords -Value 1
Stop-ClusterResource -Name 'FS01G'
Start-ClusterResource -Name 'FS01G'
Start-ClusterResource 'File Server (\\FS01G)'

#Create a highly available general purpose share
New-Item E:\TestShare -ItemType Directory
New-SmbShare -Name 'TestShare$' -Path E:\TestShare -ScopeName FS01G

###SOFS (CA shares)
#Add the disk 3 of the cluster to a CSV
Add-ClusterSharedVolume -Name 'Cluster Disk 3'
#Run this command directly on a cluster node with no remoting
Add-ClusterScaleOutFileServerRole -Name FS01SOFS
#Create a folder for the new share in the csv
New-Item C:\ClusterStorage\Volume1\TestSOFSShare -ItemType Directory
#create a continuously available share
New-SmbShare -Path C:\ClusterStorage\Volume1\TestSOFSShare -Name 'TestSOFSShare$' -ScopeName FS01SOFS

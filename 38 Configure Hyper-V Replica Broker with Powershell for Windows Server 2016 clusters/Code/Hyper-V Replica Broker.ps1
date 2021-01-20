#Enable the firewall rule for replication on port 80
#Run on all Hyper-V nodes
Enable-NetFirewallRule VIRT-HVRHTTPL-In-TCP-NoScope
#Or
Invoke-Command -Scriptblock {Enable-NetFirewallRule VIRT-HVRHTTPL-In-TCP-NoScope} -Computername 'HVS03A','HVS03B'

#Before you go on, make sure your cluster has Create computer objects permission on the OU where the cluster objects will be created

#Configure Broker on cluster
#Run these commands diretly on a cluster node
$Broker="HVS03-Broker"
Add-ClusterServerRole -Name $Broker -StaticAddress 192.168.10.22
#Can be run remotely from here
Add-ClusterResource -Name "Virtual Machine Replication Broker" -Type "Virtual Machine Replication Broker" -Group $Broker
Add-ClusterResourceDependency "Virtual Machine Replication Broker" $Broker
Start-ClusterGroup $Broker
Set-VMReplicationServer -ReplicationEnabled $true -AllowedAuthenticationType Kerberos

#Configure both the cluster and the other server to accept replication from the other
New-VMReplicationAuthorizationEntry -AllowedPrimaryServer 'HVS01.testcorp.local' -ReplicaStorageLocation 'C:\ClusterStorage\Volume1\Replicas' -TrustGroup 'ReplicaGroup'

Set-VMReplicationServer -ReplicationAllowedFromAnyServer $false
New-VMReplicationAuthorizationEntry -AllowedPrimaryServer 'HVS03-Broker.testcorp.local' -ReplicaStorageLocation 'C:\VMs\Replicas' -TrustGroup 'ReplicaGroup'

#Create a new machine
New-VM -BootDevice CD -MemoryStartupBytes 64MB -Name 'TestVM4' -NewVHDSizeBytes 300MB -NewVHDPath 'C:\VMs\Virtual Machines\TestVM4.vhdx'
#Run this on the host where the machine should apply the network settings specified
Set-VMNetworkAdapterFailoverConfiguration 'TestVM2' -IPv4Address 192.168.11.8 -IPv4SubnetMask 255.255.255.0 -IPv4DefaultGateway 192.168.11.254

#To change also the switch to which the machine will connect on the replica server when doing a Test Failover
#Run on the replica server
Set-VMNetworkAdapter 'TestVM2' -TestReplicaSwitchName 'TestSW'
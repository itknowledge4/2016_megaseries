#Install needed roles and features
Invoke-Command -ScriptBlock{Install-WindowsFeature -Name Storage-Replica -IncludeManagementTools -Restart} -ComputerName FS02,FS03
##### Run directly (not using remoting)
Test-SRTopology -SourceComputerName FS02 -SourceVolumeName D: -SourceLogVolumeName E: -DestinationComputerName FS03 -DestinationVolumeName D: -DestinationLogVolumeName E: -IgnorePerfTests -DurationInMinutes 2 -ResultPath C:\
New-SRPartnership -SourceComputerName FS02 -SourceRGName rg01 -SourceVolumeName D: -SourceLogVolumeName E: -DestinationComputerName FS03 -DestinationRGName rg01 -DestinationVolumeName D: -DestinationLogVolumeName E: -ReplicationMode Synchronous
####

Get-SRGroup
Get-SRPartnership
(Get-SRGroup).replicas

#Run on source to get replica related events
Get-WinEvent -ProviderName Microsoft-Windows-StorageReplica -max 20 | where {$_.Id -in '5015','5002','5004','1237','5001','2200'} | fl
#Run on destination to get replica related partnership creation events
Get-WinEvent -ProviderName Microsoft-Windows-StorageReplica | Where-Object {$_.ID -eq "1215"} | fl
#Run on destination to see how much data is left to be replicated
(Get-SRGroup).Replicas | Select-Object numofbytesremaining
#Run on destination to see replica related events
Get-WinEvent -ProviderName Microsoft-Windows-StorageReplica | where {$_.Id -in '5009','1237','5001','5015','5005','2200','1215'} | FL

#### Change replication duration (run directly on the server - no remoting)
Set-SRPartnership -NewSourceComputerName FS03 -SourceRGName rg01 -DestinationComputerName FS02 -DestinationRGName rg01 -Force

#### Remove replication (run directly on the server - no remoting)
Get-SRPartnership | Remove-SRPartnership -Force
Get-SRGroup | Remove-SRGroup -Force

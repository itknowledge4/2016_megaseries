#Install dedup
Install-WindowsFeature FS-Data-Deduplication

#Get list of commands
Get-Command -Module Deduplication

#Evaluate saving for a volume
ddpeval D:

#Enable deduplication
Enable-DedupVolume D: -UsageType Default

#Deduplicate files no matter how old they are (mostly for test environments)
Set-DedupVolume -Volume D: -MinimumFileAgeDays 0

#Start a dedup job
Start-DedupJob -Type Optimization -Volume D:

#Get the currently running jobs
Get-DedupJob

#Get status of deduplication
Get-DedupStatus

#Disable Deduplication on a volume
Disable-DedupVolume -Volume D:

#Unoptimize files on that volume
Start-DedupJob -Type Unoptimization -Volume D:
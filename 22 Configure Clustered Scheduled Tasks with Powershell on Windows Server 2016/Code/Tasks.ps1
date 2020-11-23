#Create 3 actions for 3 task types
$action1 = New-ScheduledTaskAction -Execute C:\script1.bat
$action2 = New-ScheduledTaskAction -Execute C:\ClusterStorage\Volume1\script2.bat
$action3 = New-ScheduledTaskAction -Execute C:\script3.bat

#Create a trigger
$trigger = New-ScheduledTaskTrigger -At 14:00 -Once

$trigger = New-ScheduledTaskTrigger -AtLogOn
$trigger.Delay='PT1M'

$trigger = New-ScheduledTaskTrigger -At 15:00 -DaysOfWeek Monday,Friday -Weekly

$trigger = New-ScheduledTaskTrigger -Daily -At 14:30 -DaysInterval 4

$trigger = New-ScheduledTaskTrigger -At 11:00 -Weekly -WeeksInterval 4 -DaysOfWeek Sunday

#Create the 3 tasks
Register-ClusteredScheduledTask -Cluster FS01 -TaskName Task_AnyNode -TaskType AnyNode -Action $action1 -Trigger $trigger
Register-ClusteredScheduledTask -Cluster FS01 -TaskName Task_Resource -TaskType ResourceSpecific -Action $action2 -Trigger $trigger -Resource FS01SOFS
Register-ClusteredScheduledTask -Cluster FS01 -TaskName Task_Cluster -TaskType ClusterWide -Action $action3 -Trigger $trigger

#Get a list of schedul;ed tasks in the cluster
Get-ClusteredScheduledTask
#You can also see them in the scheduled tasks console or with the normal CmdLets
Get-ScheduledTask -TaskPath '\Microsoft\Windows\Failover Clustering\'

#You can start a task manually to check if it works
Start-ScheduledTask Task_AnyNode -TaskPath '\Microsoft\Windows\Failover Clustering\'

#When a resource is moved, the resource specific tasks gets disabled/enabled automatically
Move-ClusterGroup -Name FS01SOFS -Node FS01B
Get-ScheduledTask -TaskPath '\Microsoft\Windows\Failover Clustering\'

#To remove tasks
Unregister-ClusteredScheduledTask -Cluster FS01 -TaskName Task_AnyNode
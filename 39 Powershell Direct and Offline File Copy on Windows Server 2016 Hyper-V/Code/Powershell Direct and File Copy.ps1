#Get credentials for an authorized user
$cred=Get-Credential

#Use powershell direct to run commands on a VM
Enter-PSSession -VMName 'TestVM1' -Credential $cred
	hostname
	ipconfig
	Get-NetAdapter
	Exit
Invoke-Command -ScriptBlock {hostname} -VMName 'TestVM1' -Credential $cred

#Copy files from the host to guest VMs
#First make sure that Guest Services is enabled for the machine
Get-VMIntegrationService -VMName 'TestVM1'
Enable-VMIntegrationService -Name 'Guest Service Interface' -VMName 'TestVM1'
#Create file
Get-Process | Out-File -FilePath C:\Test.txt
Copy-VMFile -FileSource Host -SourcePath 'C:\Test.txt' -DestinationPath 'C:\' -Name TestVM1 -Force

#Use Powershell direct to check if the file is present
Invoke-Command -ScriptBlock {dir C:\} -VMName 'TestVM1' -Credential $cred

#Alternative to Copy-VMFile using Powershell Direct which does not need Guest Services
#Create file
Get-Process | Out-File -FilePath C:\Test1.txt
$session=New-PSSession -VMName 'TestVM1' -Credential $cred
Copy-Item -ToSession $session -Path 'C:\Test1.txt' -Destination 'C:\'
Invoke-Command -ScriptBlock {dir C:\} -VMName 'TestVM1' -Credential $cred
Remove-PSSession $session
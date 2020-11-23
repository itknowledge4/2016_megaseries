#Create the share structure for CAU on the file server
New-Item E:\CAU -ItemType Directory
New-SmbShare -Path E:\CAU -Name CAU$ -EncryptData $true
New-Item E:\CAU\CAUHotFix_All -ItemType Directory
New-Item E:\CAU\FS01B -ItemType Directory

#Copy the CAU xml file from a server with the CAU PS module to the root of the share
Copy-Item '\\FS01A\C$\Windows\System32\WindowsPowerShell\v1.0\Modules\ClusterAwareUpdating\DefaultHotfixConfig.xml' 'E:\CAU'

#Place at least one update in the CAUHotfix_All folder or the FS01B folder
#Updates in the FS01B folder will be installed only on FS01B

#A GPO has to be created to point the cluster nodes to the WSUS server or what updates location you use
#This is if you want to use also the Windows Update Plugin
#Specify the WSUS server if it is the case: http://wsus01.testcorp.local:8530
#Do not configure automatic updating
#You can also configure client side targetting if you want to control the updates that will be applied
#Do not forget to run gpupdate on the cluster nodes

###Using CAU with a separate coordinator
##Run on the coordinator node
Install-WindowsFeature RSAT-Clustering
Get-Command -Module ClusterAwareUpdating

#Enable automatic restarts
Invoke-Command -ScriptBlock{Set-NetFirewallRule -Group "@firewallapi.dll,-36751" -Profile Domain -Enabled true} -ComputerName FS01A,FS01B

##Run on the coordinator
#Check if cluster is ready for CAU; some bullet points are ok to fail if not using
#Updates from the internet or self updating mode
Test-CauSetup -ClusterName FS01

#Make sure that a GPO is configured to point the cluster nodes to
#a WSUS server if you want to use this option
#Only the Specify intranet Microsoft update service location setting is needed
#Scan for applicable updates
#The DisableAclChecks is used here in the test environment but in production 
#you should remove it and restrict the permissions on the CAU folder
Invoke-CauScan -ClusterName FS01 -CauPluginName Microsoft.WindowsUpdatePlugin, Microsoft.HotfixPlugin -CauPluginArguments @{'QueryString'="IsInstalled=0 and IsHidden=0"},@{'HotfixRootFolderPath' = '\\ipam01\CAU$';'DisableAclChecks' = 'True'}
#Prod: Invoke-CauScan -ClusterName FS01 -CauPluginName Microsoft.WindowsUpdatePlugin, Microsoft.HotfixPlugin -CauPluginArguments @{'QueryString'="IsInstalled=0 and IsHidden=0"},@{'HotfixRootFolderPath' = '\\ipam01\CAU$'}
#It is possible that the scan will have some problems if you are also using the WindowsUpdatePlugin
#This is the same problem you face when you scan for updates normally with Windows Update
#You may have to run the command 2 or 3 times the first time if you want to see the full results

#Start an update session
#The DisableAclChecks is used here in the test environment but in production 
#you should remove it and restrict the permissions on the CAU folder
Invoke-CauRun -ClusterName FS01 -CauPluginName Microsoft.WindowsUpdatePlugin, Microsoft.HotfixPlugin -CauPluginArguments @{'QueryString'="IsInstalled=0 and IsHidden=0"},@{'HotfixRootFolderPath' = '\\ipam01\CAU$';'DisableAclChecks' = 'True'} -Force
#Prod: Invoke-CauRun -ClusterName FS01 -CauPluginName Microsoft.WindowsUpdatePlugin, Microsoft.HotfixPlugin -CauPluginArguments @{'QueryString'="IsInstalled=0 and IsHidden=0"},@{'HotfixRootFolderPath' = '\\ipam01\CAU$'} -Force

#Get info about the updte process
Get-CauRun
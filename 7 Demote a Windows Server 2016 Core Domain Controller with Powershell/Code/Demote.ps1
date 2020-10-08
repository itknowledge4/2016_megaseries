Uninstall-ADDSDomainController -DemoteOperationMasterRole -Force

#Run this command directly on the demoted DC with an account that can remove computers from the domain
Remove-Computer -Restart -Force

Get-ADComputer DC03 | Remove-ADObject -Recursive -Confirm:$false

#Remove the object from the site
Set-Location AD:
Remove-Item -Path 'AD:\CN=DC03,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=testcorp,DC=local' -Force

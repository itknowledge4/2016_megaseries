
$computer=Get-ADComputer hv1
Set-ADObject -Identity $Computer -Add @{'msDS-AllowedToDelegateTo' = ('cifs/HVS01.testcorp.local')}
Set-ADObject -Identity $Computer -Add @{'msDS-AllowedToDelegateTo' = ('Microsoft Virtual System Migration Service/HVS01')}
Set-ADAccountControl -Identity $Computer -TrustedForDelegation $true

$computer=Get-ADComputer hvs01
Set-ADObject -Identity $Computer -Add @{'msDS-AllowedToDelegateTo' = ('cifs/HV1.testcorp.local')}
Set-ADObject -Identity $Computer -Add @{'msDS-AllowedToDelegateTo' = ('Microsoft Virtual System Migration Service/HV1')}
Set-ADAccountControl -Identity $Computer -TrustedForDelegation $true

#Restart the 2 servers
Invoke-Command -ScriptBlock {Restart-Computer -Force} -ComputerName HV1,HVS01
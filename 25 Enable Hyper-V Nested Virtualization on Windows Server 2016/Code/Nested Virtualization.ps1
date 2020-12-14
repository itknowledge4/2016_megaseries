#Run on host
Set-VMProcessor -VMName HV1 -ExposeVirtualizationExtensions $true
Get-VMNetworkAdapter -VMName HV1 | Set-VMNetworkAdapter -MacAddressSpoofing On
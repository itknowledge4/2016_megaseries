#Resource metering
Enable-VMResourceMetering -VMName 'TestVM1'
Measure-VM -Name 'TestVM1'
Reset-VMResourceMetering -VMName 'TestVM1'
Disable-VMResourceMetering -VMName 'TestVM1'
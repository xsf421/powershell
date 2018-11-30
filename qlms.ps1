Import-Module WebAdministration

$servers = 'beta1midware1','beta2midware1'

Invoke-Command -ComputerName $servers -ScriptBlock {
    Get-WebAppPoolState 'counsel*'

    } -Credential Get-Credential
$server = Read-Host "What server do you need the owner of?"

invoke-command -ComputerName $server -ScriptBlock { Get-ItemPropertyValue -path 'HKLM:\SOFTWARE\QL' 'Managed By' } 

Pause
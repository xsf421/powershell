$server = Read-Host 'Erase Health Service State folder on what server?'

Get-Service -ComputerName $server -name 'healthservice' | Stop-Service
Remove-Item -Recurse "\\$server\C$\Program Files\Microsoft Monitoring Agent\Agent\Health Service State\Health Service Store"
Get-Service -ComputerName $server -name 'healthservice' | Start-Service
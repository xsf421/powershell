<# BFSRVC app pool cycles /#>

          Write-Host "`n`n`nThis will recycle LOS, LOSWS, and EPICAPI app pools, and the Servicing Sonic Listener Windows service.`n`n`n`n"

$server = Read-Host "What Server do you need to restart these app pools on?"

write-host "$server"

Invoke-Command -scriptblock{

restart-webapppool 'LOS'
restart-webapppool 'LOS WS'
restart-webapppool 'EPICAPI'

} -computername $server

get-service -ComputerName $server -Name ServicingSonicListener | Restart-Service

Pause
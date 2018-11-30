$server = 'ql1obimportap1b','ql2obimportap1b'

Invoke-Command -scriptblock {

Restart-WebAppPool 'appserver'
#restart-webapppool 'LOS'
#restart-webapppool 'LOS WS'
#restart-webapppool 'EPICAPI'
#Restart-WebAppPool 'servicehub'
#Restart-WebAppPool 'servicelistener'
#Restart-WebAppPool 'servicingwebapi'

} -computername $server

#get-service -ComputerName $server -Name ServicingSonicListener | Restart-Service
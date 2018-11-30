$creds = Get-Credential
$servernames = 'test1midware1'

$service = "ARA*"

Invoke-Command -ComputerName $servernames -ScriptBlock {

get-service $using:service | Restart-Service

} -Credential $creds
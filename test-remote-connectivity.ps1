#Get-Credential

$servernames = "\\mi\dfs\shared\NOC Team\pmills\Scripts\testservers.txt"

 ForEach ($server in Get-Content $servernames ) {
    gsv -ComputerName $server -name "HealthService" | Restart-Service
    Write-Host "Restarted on $server"
 }

 Write-Host "Restarts Complete";
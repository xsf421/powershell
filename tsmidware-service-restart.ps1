#Get-Credential

$servernames = Read-Host "Enter Server Name"
$service = "HealthService"

ForEach ($server in $servernames ) {
    try { Get-Service -ComputerName $server -name $service | Restart-Service -erroraction Stop
    Write-Host "Restarted on $($server)" 
    }
    catch { Write-Host "Restart unsuccessful on $($server)" -BackgroundColor Red
    }         
}

Write-Host "Restarts Complete"
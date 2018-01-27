#Get-Credential

$limit = 1
$service = "HealthService"

while ( $limit -le 5 ) {

    try { Get-Service -ComputerName localhost -name $service | Restart-Service -erroraction Stop 
    Write-Host "Restarted $($limit) times" 
    Start-Sleep 60
    $limit++ 
    }
    
    catch { Write-Host "Restart unsuccessful on $($server)" -BackgroundColor Red
    }         
    
}

Write-Host "Restarts Complete"
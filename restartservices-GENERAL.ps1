﻿Get-Credential

$servernames = Get-Content "\\mi\dfs\shared\NOC Team\pmills\Scripts\testservers.txt"
$service = "*healthservice*"

ForEach ($server in $servernames ) {
    try { Get-Service -ComputerName $server -name $service | Restart-Service -erroraction Stop
    Write-Host "Restarted on $($server)" 
    }
    catch { Write-Host "Restart unsuccessful on $($server)" -BackgroundColor Red
    }         
}

Write-Host "Restarts Complete"
#Get-Credential

$servernames = Get-Content "\\mi\dfs\shared\NOC Team\pmills\Scripts\testservers.txt"
$pool = "DefaultApppool"

ForEach ($server in $servernames ) {
    try { Restart-WebAppPool -Name $pool
    Write-Host "Recycled $pool on $($server)" 
    }
    catch { Write-Host "Recycle unsuccessful on $($server)" -BackgroundColor Red
    }         
}

Write-Host "Restarts Complete"
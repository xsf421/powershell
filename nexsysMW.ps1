#Get-Credential
Import-Module WebAdministration

$servernames = Get-Content "\\mi\dfs\shared\NOC Team\pmills\Scripts\nexsysMW.txt"
$service = "HealthService"

ForEach ($server in $servernames ) {
        try { Invoke-Command -ComputerName $server -ScriptBlock { Restart-WebAppPool -Name $service } -ErrorAction Stop
        Write-Host "Recycled on $Server"
        }
        catch { Write-Host "Recycle unsuccessful on $($server)" -BackgroundColor Red
        }
        
}

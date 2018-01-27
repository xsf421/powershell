$server = Read-Host "Enter Server Name"
$service = "HealthService"

if ( $server -match 'QL[1-2]DEXAPP0[1-3]') {
    try { Get-Service -ComputerName $server -name $service | Restart-Service -erroraction Stop
    Write-Host "Restarted on $($server)" 
    }
    catch { Write-Host "Restart unsuccessful on $($server)" -BackgroundColor Red
    }         
}
elseif ( $server -match 'QL[1-2]DEXAPP0[4-7]' ) {
        $PRODacctrun = start-job -ScriptBlock {
        try { Get-Service -ComputerName $server -name $service  | Restart-Service -erroraction Stop
        Write-Host "Restarted on $($server)" 
        }
        catch { Write-Host "Restart unsuccessful on $($server)" -BackgroundColor Red
        }
             
    } -Credential Get-Credential -name DexRestart
    while ( Get-Job -state Running ) {
            get-job -name DexRestart
            }
get-job            
Pause    
Remove-Job -Name "*"       
}

#Write-Host "Restarts Complete"
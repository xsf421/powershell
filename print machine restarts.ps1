$server = 'QL1PMACHINEDB2'


cls
Write-Host ""
Write-Host "     ## ################################### ##"
Write-Host "     ## ----------------------------------- ##"
Write-Host "     ##                                     ##"
Write-Host "     ##         Print Machine Manager       ##"
Write-Host "     ##                                     ##"
Write-Host "     ## ----------------------------------- ##"
Write-host "     ## ################################### ##"
Write-Host ""

               $Choice = Read-Host 'Which instance do you need to restart? (1, 2, 3, or exit)'
 
                                                   
               switch ($Choice) {
                                  1{(Pmachine1)}
                                  2{(Pmachine2)}
                                  3{(Pmachine3)}
                                  'exit'{EXIT}  
                                 } 
              


Function Pmachine1 {
    try { Get-Service -ComputerName $server -name 'PrintMachine_QL1' | Restart-Service -erroraction Stop
        Write-Host "Restarted on $($server)" 
        }
    catch { Write-Host "Restart unsuccessful on $($server)" -BackgroundColor Red
        }     
        Pause
    }


Function Pmachine2 {
    try { Get-Service -ComputerName $server -name 'PrintMachine_QL2' | Restart-Service -erroraction Stop
        Write-Host "Restarted on $($server)" 
        }
    catch { Write-Host "Restart unsuccessful on $($server)" -BackgroundColor Red
        }     
        Pause
    }

Function Pmachine3 {
    try { Get-Service -ComputerName $server -name 'PrintMachine_QL3'| Restart-Service -erroraction Stop
        Write-Host "Restarted on $($server)" 
        }
    catch { Write-Host "Restart unsuccessful on $($server)" -BackgroundColor Red
        }     
        Pause
    }
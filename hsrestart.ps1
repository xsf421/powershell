$server = Read-Host "Enter Server Name"
$service = "HealthService"

$os = (Get-ADComputer -Filter 'Name -like $server' -Properties *).operatingsystem 
$ou = (Get-ADComputer -Filter 'Name -like $server').distinguishedname

if (!$os) {
            Write-Host "$Server does not exist in AD"
            BREAK
            }

if ($os -notlike "*Server 2016*" -and $ou -imatch "OU=Prod") {
    
    try {
        Invoke-Command -ComputerName $server -scriptblock {
        get-service 'healthservice' -computername $using:server
        #Remove-Item -Recurse "C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State\Health Service Store"
        #Start-Service $service
            }
    }
    catch { Write-Host "Restart unsuccessful on $($server)" -BackgroundColor Red
    }   
}

elseif ($os -like "*Server 2016*" -and $ou -imatch "OU=Prod") {

    Write-Host "Sign in with your -prod account."
    $prodcred = Get-Credential -UserName $(([Security.Principal.WindowsIdentity]::GetCurrent().name)) -Message "Enter your -prod Credentials"
    try {
        Invoke-Command -ComputerName $server -scriptblock {
        get-service 'healthservice' -computername $using:server
        #Remove-Item -Recurse "C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State\Health Service Store"
        #Start-Service $service
            } -Credential {$prodcred + "prod"}
    }
    catch { Write-Host "Restart unsuccessful on $($server)" -BackgroundColor Red
    }   
}

elseif ($ou -imatch "OU=Non-Prod") {

    Write-Host "Sign in with your -np account."
    $npcred = Get-Credential -UserName $(([Security.Principal.WindowsIdentity]::GetCurrent().name)) -Message "Enter your -np Credentials"
    try {
        Invoke-Command -ComputerName $server -scriptblock {
        get-service 'healthservice' -computername $using:server
        #Remove-Item -Recurse "C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State\Health Service Store"
        #Start-Service $service
            } -Credential $npcred 
    }
    catch { Write-Host "Restart unsuccessful on $($server)" -BackgroundColor Red
    }   
}

Write-Host "Restart Complete"

Pause 
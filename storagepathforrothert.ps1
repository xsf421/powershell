$servers = get-content 'C:\users\pmills-\Desktop\storageservers.txt'
$output = @()

foreach ($line in $servers) {

    $output += Invoke-Command -computername $line -ScriptBlock { Get-InitiatorPort | Select-Object -Property PSComputerName,PortAddress }
    
}


$output | select-object -property pscomputername,portaddress | Format-Table | Out-File storageserversworking.txt
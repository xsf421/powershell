$servers = Get-Content 'failedrescans.txt'
$filename = 'pingtestfailedrescansfail.txt'

New-Item -Path "C:\Users\$env:username\Desktop\$filename" -ItemType file
foreach($server in $Servers)
{
    $Ping = Test-Connection -ComputerName $Server -Count 1
    if (!($Ping))
    {
       Add-Content -Path "C:\Users\$env:username\Desktop\$filename.txt" -Value $Server
    }
}

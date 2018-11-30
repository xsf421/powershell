$servers = Get-Content "C:\users\$env:username\Desktop\storageservers.txt"
New-Item "C:\users\$env:username\Desktop\storage1.txt"

foreach ($line in $servers) {

    Add-Content -Path 'c:\users\pmills-\desktop\storage1.txt' -value $line
    Add-Content -path 'c:\users\pmills-\desktop\storage1.txt' -value ( invoke-command -computername $line -scriptblock { 
        Get-WmiObject -class MSFC_FCAdapterHBAAttributes -namespace “root\WMI” | 
            ForEach-Object {(($_.NodeWWN) | 
            ForEach-Object {“{0:x}” -f $_}) -join “:”} 
    } ) 
    Add-Content -path 'c:\users\pmills-\desktop\storage1.txt' -value ("="*21)
}


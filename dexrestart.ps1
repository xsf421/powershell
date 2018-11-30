$servers = Get-ADComputer -Filter { name -like "ql*dexapp*"} | select name -ExpandProperty name
$creds = Get-Credential

Invoke-Command $servers { gsv *dexex* } -Credential $creds
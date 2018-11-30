$servers = Get-Content "\\mi\dfs\shared\noc team\pmills\scripts\tsservers.txt"

foreach ($server in $servers) {
    Invoke-Command -computername $server { 
        Get-WmiObject win32_SystemEnclosure | select pscomputername,serialnumber
        }
}
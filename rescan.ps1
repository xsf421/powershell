$servers = get-content '//mi/dfs/shared/noc team/pmills/mpioservers.txt'

foreach ($server in $servers ) {

    Invoke-Command -computername $server { "rescan" | diskpart.exe } -AsJob

}
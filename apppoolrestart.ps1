<# AVM app pool cycler /#>

          Write-Host "`n`n`nThis will recycle AVM.`n`n`n`n"

$server = get-content '\\mi\dfs\shared\NOC Team\pmills\Scripts\testservers.txt'

foreach ($line in $server) {

Invoke-Command -scriptblock{

restart-webapppool 'AVM'

} -computername $line

}

Pause
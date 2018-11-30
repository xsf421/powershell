Import-Module webadministration
$creditservers = get-content '\\mi\dfs\shared\noc team\pmills\creditservers.txt'


foreach ($line in $creditservers) {

    invoke-command -computername $line -scriptblock {
       get-service -name 'creditorchestrator'
       Get-WebAppPoolState -name 'creditv2'
        }

}

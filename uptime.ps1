$servers = 'test1dc4'

foreach ( $server in $servers ) {

invoke-command -computername $server -scriptblock {

    Get-CimInstance -ClassName win32_operatingsystem | select csname, lastbootuptime

    }
}
$servers = 'QL1RULESMW1','QL1RULESMW2','QL2RULESMW1','QL2RULESMW2P'

foreach ($server in $servers) {

Invoke-Command -scriptblock {

restart-webapppool 'aiorchestration'

} -computername $server -AsJob

}
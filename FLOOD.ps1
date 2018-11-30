$server = Read-Host "What server do you need to recycle flood on?"

Invoke-Command -scriptblock { Restart-webapppool 'Flood' } -computername $server 
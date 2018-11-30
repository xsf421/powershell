$servers = 'ql2graciefe1','ql2graciefe2','ql1graciefe1','ql1graciefe2'

Invoke-Command $servers {

 Get-ChildItem Cert:\LocalMachine\My | Where-Object { $_.Subject -cmatch [regex]::Escape("CN=gracie.rockfin.com") } 
 
 }
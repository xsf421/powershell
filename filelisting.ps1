$Dir = '\\mi\dfs\TSI-Docs\Production1709\Nexus\INTEGRATIONS\CLIENTREQUESTERR'
$Output = '\\mi\dfs\shared\noc team\pmills\nexsysERR.txt'

Get-ChildItem -Name $Dir -filter "*.txt" | ft fullname | Out-File $Output
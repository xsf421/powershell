$server = 'ql1nocdev1' #Read-Host "Enter Server Name"
$service = "HealthService"
$servicecount = 0

invoke-command -computername $server -ScriptBlock {$USING:servicecount
    $servicecount = get-service | select name,StartType} -AsJob

Write-Host $servicecount
Pause    

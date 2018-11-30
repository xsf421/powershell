Import-Module OperationsManager
New-SCOMManagementGroupConnection -ComputerName 'OpsMgr'

$teamNocGroup = Get-SCOMGroup -DisplayName "IT Team Noc View"
$healthAgentClass = Get-SCOMClass -DisplayName "Microsoft.Windows.Server.2008.LogicalDisk"
$depth = [Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive

$teamNocCriteria = "
Severity==2 AND
Priority!=0 AND
ResolutionState!=255
"

[System.Collections.ArrayList]$heartBeatFailures=@()
$heartBeatFailures = ($teamNocGroup.GetMonitoringAlerts($teamNocCriteria, $healthAgentClass, $depth))

$hbf = $heartBeatFailures.monitoringobjectdisplayname

Write-Host $hbf
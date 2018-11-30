Import-Module OperationsManager
New-SCOMManagementGroupConnection -ComputerName 'OpsMgr'

$teamNocGroup = Get-SCOMGroup -DisplayName "IT Team Noc View"
$healthAgentClass = Get-SCOMClass -DisplayName "Health Service Watcher Group (agent)"
$depth = [Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive

$teamNocCriteria = "
Severity==2 AND
Priority!=0 AND
ResolutionState!=255 AND
ResolutionState!=245
"
[System.Collections.ArrayList]$heartBeatFailures=@()
$heartBeatFailures = ($teamNocGroup.GetMonitoringAlerts($teamNocCriteria, $healthAgentClass, $depth))

$hbf = $heartBeatFailures.monitoringobjectdisplayname
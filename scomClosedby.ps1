Import-Module OperationsManager
New-SCOMManagementGroupConnection -ComputerName 'OpsMgr'

$teamNocGroup = Get-SCOMGroup -DisplayName "IT Team Noc View"
$nonProdteamNocGroup = Get-SCOMGroup -DisplayName "dev and test"
$class = Get-SCOMClass -DisplayName "IT Team NOC View - Engineer Level"
$depth = [Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive

$teamNocCriteria = "
Severity==2 AND
Priority!=0 AND
Priority!=1 AND
ResolutionState==255
"

$mainAlerts=($teamNocGroup.GetMonitoringAlerts($teamNocCriteria, $Class, $depth))

$mainAlerts | 
    ?{$_.lastmodifiedby -notlike "*system*" } |
    ?{$_.lastmodifiedby -notlike "*auto-resolve*" } | 
    ?{$_.MonitoringObjectHealthState -ne "success"} | 
    ?{$_.IsMonitorAlert -eq 'True' } |
    select Name, monitoringobjectpath, monitoringobjectdisplayname, resolvedby
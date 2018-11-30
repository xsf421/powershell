Import-Module OperationsManager
New-SCOMManagementGroupConnection -ComputerName 'OpsMgr'

$teamNocGroup = Get-SCOMGroup -DisplayName "IT Team Noc View"
$nonProdteamNocGroup = Get-SCOMGroup -DisplayName "dev and test"
$class = Get-SCOMClass -DisplayName "IT Team NOC View - Engineer Level"
$depth = [Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive
$teamNocCriteria = "
Severity==2 AND
Priority!=0 AND
ResolutionState!=255
"

$mainAlerts=($teamNocGroup.GetMonitoringAlerts($teamNocCriteria, $Class, $depth)) 

$servers = ($mainAlerts | where { $_.name -like '*witness*' } | select -ExpandProperty monitoringobjectpath ) #-ireplace "\..+").trim("")


$creds = Get-Credential

foreach ($server in $servers) {
    Invoke-Command -ComputerName $server -Credential $creds -ScriptBlock {

        Get-ClusterResource -Name file* | start-clusterresource

    } -asjob
}

Get-Job | Wait-Job | Remove-Job

Get-SCOMAlert -ResolutionState 249 | ?{$_.MonitoringObjectHealthState -eq "success"} | Set-SCOMAlert -ResolutionState 255


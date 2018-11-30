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

$servers = ($mainAlerts | where { $_.name -like '*unloaded*' } | select -ExpandProperty monitoringobjectdisplayname) 
# -ireplace "\..+").trim()

foreach ($line in $servers) {

    invoke-command -ComputerName $line -scriptblock {

        Get-Service -name 'healthservice' | Stop-Service
        Remove-Item -Recurse "C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State\Health Service Store"
        Get-Service -name 'healthservice' | Start-Service
        } -AsJob
}
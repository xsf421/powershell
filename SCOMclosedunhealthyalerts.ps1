Import-Module OperationsManager
New-SCOMManagementGroupConnection -ComputerName 'OpsMgr'

Function Pause ($Message = "Press any key to continue . . . ") {
    if ((Test-Path variable:psISE) -and $psISE) {
        $Shell = New-Object -ComObject "WScript.Shell"
        $Button = $Shell.Popup("The closed healthy alerts have been placed on your desktop.", 0, "Check Complete!", 0)
    }
    else {     
        Write-Host -NoNewline $Message
        [void][System.Console]::ReadKey($true)
        Write-Host
    }
}

$teamNocGroup = Get-SCOMGroup -DisplayName "IT Team Noc View"
$nonProdteamNocGroup = Get-SCOMGroup -DisplayName "dev and test"
$class = Get-SCOMClass -DisplayName "IT Team NOC View - Engineer Level"
$depth = [Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive

$teamNocCriteria = "
Severity==2 AND
Priority!=0 AND
ResolutionState==255
"

$mainAlerts=($teamNocGroup.GetMonitoringAlerts($teamNocCriteria, $Class, $depth))

$workingset = $mainAlerts | 
    ?{$_.lastmodifiedby -notlike "*system*" } |
    ?{$_.lastmodifiedby -notlike "*auto-resolve*" } | 
    ?{$_.MonitoringObjectHealthState -ne "success"} | 
    ?{$_.IsMonitorAlert -eq 'True' } |
    select Name, monitoringobjectpath, monitoringobjectdisplayname, resolvedby

$workingset | Out-File C:\Users\$env:username\Desktop\ClosedUnhealthyAlerts.txt

Pause
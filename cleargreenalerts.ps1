Import-Module OperationsManager
New-SCOMManagementGroupConnection -ComputerName 'ql1opsmgrms4'
Get-SCOMAlert -ResolutionState 249 | where {$_.MonitoringObjectHealthState -eq "success"} | Set-SCOMAlert -ResolutionState 255
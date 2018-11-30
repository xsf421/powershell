Invoke-Command -ComputerName 'qldnjobcl1' -scriptblock {

    Import-Module FailoverClusters

    Start-ClusterResource emailscrapperwinservicelp

}

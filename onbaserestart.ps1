#region Test Environment

Invoke-Command -ComputerName QL1OBTEST1 -ScriptBlock {
    Import-Module WebAdministration
    Get-Item IIS:\AppPools\Appserver | Restart-WebItem
}

Invoke-Command -ComputerName QL1OBTEST2 -ScriptBlock {
    Get-Service docimportunity* | Restart-Service -PassThru
}

Invoke-Command -ComputerName QL2OBIMPORT1T -ScriptBlock {
    Get-Service ControlDocCreateService, Docimportservice* | Restart-Service -PassThru
}

#endregion

#region Beta Environment

Invoke-Command -ComputerName QL1OBTBETA1,QL2OBIMPORTAP1B,QL1OBIMPORTAP1B -ScriptBlock {
    Import-Module WebAdministration
    Get-Item IIS:\AppPools\Appserver | Restart-WebItem
}

Invoke-Command -ComputerName QL1WFIMPORT1B -ScriptBlock {
    Get-Service docimportunity* | Restart-Service -passthru
}

Invoke-Command -ComputerName QL1OBIMPORT1B,QL2OBIMPORT1B -ScriptBlock {
    Get-Service ControlDocCreateService, Docimportservice* | Restart-Service -PassThru
}

#endregion 

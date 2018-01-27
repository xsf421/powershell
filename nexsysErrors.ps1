$ClientErr = Get-Content '\\mi\dfs\TSI-Docs\Production1709\Nexus\INTEGRATIONS\CLIENTREQUESTERR'
$VendorErr = Get-Content '\\mi\dfs\TSI-Docs\Production1709\Nexus\INTEGRATIONS\VENDORREQUESTERR'
$ClientErrFile = '\\mi\dfs\shared\noc team\pmills\nexsysCLIENTERR.txt'
$VendorErrFile = '\\mi\dfs\shared\noc team\pmills\nexsysVENDORERR.txt'

cls
Write-Host ""
Write-Host "     ## ################################### ##"
Write-Host "     ## ----------------------------------- ##"
Write-Host "     ##                                     ##"
Write-Host "     ##         Nexsys File Manager         ##"
Write-Host "     ##                                     ##"
Write-Host "     ## ----------------------------------- ##"
Write-host "     ## ################################### ##"
Write-Host ""

               $Choice = Read-Host 'What Would you like to do?
 
                        1 = Clear Client Request ERR
                        2 = Clear Vendor Request ERR
                        3 = Exit'
                             
               switch ($Choice) {
                                  1{(ClientReqErr)}
                                  2{(VendorReqErr)}
                                  3{EXIT}  
                                 } 
              }


Function ClientReqErr {
    Get-ChildItem -Name $ClientErr -filter "*.txt" | ft fullname | Out-File $ClientErrFile
        for-each ( $line in $ClientErr ) {
        Move-Item -Path $line -destination '\\mi\dfs\TSI-Docs\Production1709\Nexus\INTEGRATIONS\CLIENTREQUESTERR\Need Info'
        }
    }

Function VendorReqEerr {
    Get-ChildItem -Name $VendorErr -filter "*.txt" | ft fullname | Out-File $VendorErrFile
        for-each ( $Vendline in $VendorErr ) {
        Move-Item -Path $line -destination '\\mi\dfs\TSI-Docs\Production1709\Nexus\INTEGRATIONS\VENDORREQUESTERR\Need Info\'
        }
    }
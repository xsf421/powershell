##############################################################################################################################################################

#This will clear the TSi File Alerts in SCOM. Script will move the file to the Need Info Folder and email the proper team depending on the time of day.

#<Folder \\mi\dfs\TSI-Docs\Production1709\Nexus\INTEGRATIONS\CLIENTREQUESTERR File Count = There are 2 files in 
#\\mi\dfs\TSI-Docs\Production1709\Nexus\INTEGRATIONS\CLIENTREQUESTERR. <br />This over the file threshold of 1<br />List of Files:<br />
#LAKEWOOD-IN-QTWEET-PaymentChangedEvent-b094c3f7-b64b-4ba5-8407-0db77612ec5e-01.xml<br />Lakewood Requeue Shortcuts.lnk<br />NOC - 
#Contact Flight Crew during business hours and itoncall@titlesource.com after hours

##############################################################################################################################################################
#region AMROCK Script

    

    #region for the moving process and set up for email
    $AMROCKFilePath = @()
    $AMROCKFilePath += "\\mi\dfs\TSI-Docs\Production1709\Nexus\INTEGRATIONS\CLIENTREQUESTERR"
    $AMROCKFilePath += "\\mi\dfs\TSI-Docs\Production1709\Nexus\INTEGRATIONS\VENDORRESPONSEERR"
    $AMROCKFilePath += "\\mi\dfs\TSI-Docs\Production1709\Nexus\INTEGRATIONS\VENDORRESPONSEERR\Need Info\Charles Jones"
    $AMROCKMailClientSubject = $AMROCKFilePath -imatch "CLIENTREQUESTERR"
    $AMROCKMailVendorSubject = $AMROCKFilePath -imatch "VENDORRESPONSEERR" -notmatch "Charles Jones"
    $AMROCKMailCharlesJonesSubject = $AMROCKFilePath -imatch "Charles Jones"
    $AMROCKNeedInfo = "Need Info"
    $AMROCKNewScoms = "New Scoms"
    $PSEmailServer = "mailgw1.rockfin.com"
    $ToDayTime = "ITSupportAnalysts@amrock.com","itteamnoconcall@quickenloans.com","3134074802@vtext.com"
    $ToNightTime = "ITSupportAnalysts@amrock.com","itteamnoconcall@quickenloans.com"
    $From = "itteamnoconcall@quickenloans.com"
    $AMROCKEmail = $true
    $AMROCKFilePathsHash = @{}
    $ClientEmailHash = @{}
    $VendorEmailHash = @{}
    $CharlesJonesEmailHash = @{}
    
    $AMROCKFilePath | ForEach-Object {$AMROCKFilePathsHash[$($_)] = Test-Path -Path "$_\*.txt", "$_\*.xml"} 
    if ((Get-Date).Hour -ge "9" -and (Get-Date).Hour -lt "12" -and (Get-date).DayOfWeek -ne "Saturday" -and "Sunday") 
    {
        $TimeOfDay = "Good Morning AMROCK Support"
    }
    elseif ((Get-Date).Hour -ge "12" -and (Get-Date).Hour -lt "16" -and (Get-date).DayOfWeek -ne "Saturday" -and "Sunday")
    {
        $TimeOfDay = "Good Afternoon AMROCK Support"    
    }
    elseif ((Get-Date).Hour -ge "16" -and (Get-Date).Hour -lt "21" -and (Get-date).DayOfWeek -ne "Saturday" -and "Sunday")
    {
        $TimeOfDay = "Good Evening AMROCK Support" 
    }
    else {
        $TimeOfDay = "AMROCK Support Oncall"
    }
    
    foreach ($Key in $AMROCKFilePathsHash.Keys)
    {
        if (!$AMROCKFilePathsHash.$Key)
            {
                Write-Host "There are no New Files to Move from Path $($Key)`n"
            }
        else
            {
                Write-Host "Checking Directory $($Key)`n" -ForegroundColor Cyan
                [array]$FileNames = Get-ChildItem -Path  $Key -Filter *.txt
                $FileNames += Get-ChildItem -Path  $Key -Filter *.xml
                  foreach ($FileName in $FileNames)
                {
                   if ($FileName.LastWriteTime -lt (Get-Date).AddMinutes(-5)) 
                   {
                       if ($Filename.directory.name -imatch "CLIENTREQUESTERR" ) 
                       {
                        $FileName | ForEach-Object {$ClientEmailHash[$($_)] = $($FileName.directory) }
                        Move-Item -Path "$($Key)\$($FileName.Name)" -Destination "$($Key)\$($AMROCKNeedInfo)"
                        Write-Host "File "$($FileName.Name) has been moved to the $AMROCKNeedInfo Directory"`n" -ForegroundColor Green 
                       }
                       if ($Filename.directory.name -imatch "VENDORRESPONSEERR" )
                       {
                        $FileName | ForEach-Object {$VendorEmailHash[$($_)] = $($FileName.directory) }
                        Move-Item -Path "$($Key)\$($FileName.Name)" -Destination "$($Key)\$($AMROCKNeedInfo)"
                        Write-Host "File "$($FileName.Name) has been moved to the $AMROCKNeedInfo Directory"`n" -ForegroundColor Green
                       }
                       if ($Filename.directory.name -imatch "Charles Jones" )
                       {
                        $FileName | ForEach-Object {$CharlesJonesEmailHash[$($_)] = $($FileName.directory) }
                        Move-Item -Path "$($Key)\$($FileName.Name)" -Destination "$($Key)\$($AMROCKNewScoms)"
                        Write-Host "File "$($FileName.Name) has been moved to the $AMROCKNewScoms Directory"`n" -ForegroundColor Green
                       }
                      $AMROCKEmail = $false
                    }
                }   
             }
    }
    #endregion
    
    ##############################################################################################################################################################
    
    #region Sending Email
    if (!$AMROCKEmail)
    {
        $BodyClient ="
        Hello, $TimeOfDay,`n
        The following file(s) have been moved to the $AMROCKNeedInfo directory.`n
    $($ClientEmailHash.keys.name -join "`n")`n`n`n It Team NOC Oncall | PH: (313)373-4770
        "

        $BodyVendor ="
        Hello, $TimeOfDay ,`n
        The following file(s) have been moved to the $AMROCKNeedInfo directory.`n
    $($VendorEmailHash.keys.name -join "`n")`n`n`n It Team NOC Oncall | PH: (313)373-4770
        "

        $BodyCharlesJones ="
        Hello, $TimeOfDay,`n
        The following file(s) have been moved to the $($AMROCKNewScoms) directory.`n
    $($CharlesJonesEmailHash.keys.name -join "`n")`n`n`n It Team NOC Oncall | Ext (313)373-4770
    "
    #region Sending Vendor Email    
        if ($VendorEmailHash.Values -imatch "VENDORRESPONSEERR") 
        {
            
        
         if ((Get-Date).Hour -lt "9" -or (Get-Date).Hour -ge "21" -or (Get-Date).DayOfWeek -eq "Saturday","Sunday" )
         {
             Write-Host "This will be sent After hours Email"
             Send-MailMessage -To $ToNightTime -From $From -Subject "Folder $AMROCKMailVendorSubject File Count = $($VendorEmailHash.Values.count)" -Body  $BodyVendor -SmtpServer $PSEmailServer
             
         }
         else
         {  
             Write-Host "This will Email During Business Hours"
             Send-MailMessage -To $ToDayTime -From $From -Subject "Folder $AMROCKMailVendorSubject File Count = $($VendorEmailHash.Values.count)" -Body $BodyVendor -SmtpServer $PSEmailServer
         }
          Remove-Variable -Name VendorEmailHash
        }
    #endregion     
    #region Sending Client Email     
         if ($ClientEmailHash.Values -imatch "CLIENTREQUESTERR")
         {
         if ((Get-Date).Hour -lt "9" -or (Get-Date).Hour -ge "21" -or (Get-Date).DayOfWeek -eq "Saturday","Sunday" ) #Change $ChangeTime to Get-Date
         {
            Write-Host "This will be sent After hours Email"
            Send-MailMessage -To $ToNightTime -From $From -Subject "Folder $AMROCKMailClientSubject Count = $($ClientEmailHash.Values.count)" -Body  $BodyClient -SmtpServer $PSEmailServer
            
         }
         else
         {  
             Write-Host "This will Email During Business Hours"
             Send-MailMessage -To $ToDayTime -From $From -Subject "Folder $AMROCKMailClientSubject File Count = $($ClientEmailHash.Values.count)" -Body $BodyClient -SmtpServer $PSEmailServer
         }
          Remove-Variable -Name ClientEmailHash
        }
    #endregion
    
    #region Sending Charles Jones Email     
     if ($CharlesJonesEmailHash.Values -imatch "Charles Jones")
     {
     if ((Get-Date).Hour -lt "8" -or (Get-Date).Hour -ge "17" -or (Get-Date).DayOfWeek -eq "Saturday","Sunday" ) #Change $ChangeTime to Get-Date
     {
         Write-Host "This will be sent After hours Email"
         Send-MailMessage -To $To -From $From -Subject "Folder $($AMROCKMailCharlesJonesSubject) File Count = $($CharlesJonesEmailHash.Values.count)" -Body  $BodyCharlesJones -SmtpServer $PSEmailServer
    
     }
    else
     {  
        Write-Host "This will Email During Business Hours"
        Send-MailMessage -To $To -From $From -Subject "Folder $($AMROCKMailCharlesJonesSubject) File Count = $($CharlesJonesEmailHash.Values.count)" -Body $BodyCharlesJones -SmtpServer $PSEmailServer
     }
 Remove-Variable -Name CharlesJonesEmailHash
}
#endregion       
        }
    #endregion
    #endregion
        Write-Host "This Task Is Complete. This Page Will Automatically Close" -ForegroundColor Yellow
    Start-Sleep -Seconds 5

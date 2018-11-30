#######################################################################
# Created by: Kenny Edgerton                                          #
# Date 01/30/2018                                                     #
# SCOM Alert Tool Box                                                 #
# restarting the health service                                       #
#######################################################################
#######################################################################################################################################################################################
#region Reset GrayAgents Agent HealthService
#region Collecting GrayAgents Agents
Import-Module '\\mi\dfs\applications\SCOM2012\Powershell\OperationsManager\OperationsManager.psd1'
function Reset-Health 
{
    Clear-Host
    $DisplayWindowLabel.text = "Installing the Operations Manager Module..."
    #Import-Module OperationsManager
    #Import-Module '\\mi\dfs\applications\SCOM2012\Powershell\OperationsManager\OperationsManager.psd1'
    New-SCOMManagementGroupConnection -ComputerName 'OpsMgr'
    Write-Host " Done"
    
    $GrayAgents= @()
    $DisplayWindowLabel.text = "Creating a Collection of All Gray Agents that Appear in SCOM..."
    $DisplayWindowLabel.Refresh()
    $agent = Get-SCClass -name "Microsoft.SystemCenter.Agent"
    [array]$GrayAgents += Get-SCOMMonitoringObject -class:$agent | where-Object {!$_.IsAvailable} | ForEach-Object {$_.DisplayName}
    Get-SCOMManagementGroupConnection |Where-Object{$_.IsActive } | Remove-SCOMManagementGroupConnection
     $Servers= @()
     $DisplayWindowLabel.text = "Testing Connection to Gray Agents"
$DisplayWindowLabel.Refresh()
     foreach ($GrayAgentsAgent in $GrayAgents) 
    {
        $Ping = Test-Connection -ComputerName $GrayAgentsAgent -Count 1 -Quiet -ErrorAction SilentlyContinue
    
        if (!$Ping)
        {
            Write-Host "Ping Failed: $GrayAgentsAgent" -foregroundColor Red
        }
        else
        {
            Write-Host "Ping Succeeded: $GrayAgentsAgent" -foregroundColor Green ; [array]$Servers += $GrayAgentsAgent
        }
           
    }

#endregion  
#region Restarting the Heath Service on the Servers That Pinged  
$Health= @()
$HealthResults= @()

foreach ($Server in $Servers)
{
    [array]$Health += Invoke-Command -ComputerName $Server {Get-Service -Name healthservice | Restart-Service}-AsJob -JobName $Server
}
foreach ($Server in $Servers)
{
    $DisplayWindowLabel.text = "Attempting to Restart Health Service on Server $Server";Start-Sleep -Seconds 1
    $DisplayWindowLabel.Refresh()
}
$DisplayWindowLabel.text = "Finishing Restart Service Jobs"
$DisplayWindowLabel.Refresh()
Get-Job | Wait-Job -Timeout 15



if (get-job -State Failed)
{
    foreach ($RestartFail in $(get-job -State Failed).Name -ireplace "(\..+)","")
    {
        Write-Host "Server $RestartFail has failed to restart the health service" -ForegroundColor Red
    }
}
if(get-job -State Completed)
{
    foreach ($RestartComplete in $(get-job -State Completed).Name -ireplace "(\..+)","")
    {
      Write-Host "Server $RestartComplete has restarted the health service" -ForegroundColor Green
      $HealthResults += $RestartComplete
    }
}
Write-Host "`n`n`nThis Task Has Been Completed." -ForegroundColor Green
$DisplayWindowLabel.text = "Restarted $($HealthResults.count) Server(s) SCOM Agent"
get-job | Remove-Job
}
#endregion

#endregion

#######################################################################################################################################################################################
#region Restart-Kiwi Function
#######################################################################################################################################################################################
function Restart-Kiwi
{   
    Clear-Host
    $kiwiServer = "ql2ksyslog1"
    $kiwiLogDirectory = "\\$($KiwiServer)\D$\syslog\Cisco Switches & Routers"
    $kiwiService = "Kiwi Syslog Server"
    $DisplayWindowLabel.text = "Restarting Kiwi System Service"
    $DisplayWindowLabel.Refresh()
    if ($Counter -eq $null){$Counter = 0}
    do
    {
        $now = Get-Date
    $Counter++
        try
        {
            Write-Host "`nRestarting the $($KiwiService) window service..." -ForegroundColor Yellow -NoNewline
            $KiwiTargetService = Invoke-Command -ComputerName $KiwiServer {Get-Service  -Name $using:KiwiService}

            if ($KiwiTargetService  | Where-Object {$_.Status -eq "Stopped"})
            {
                Invoke-Command -ComputerName $KiwiServer {Get-Service  -Name $using:KiwiService | Start-Service <#-WhatIf#>}
            }
            elseif ($KiwiTargetService | Where-Object {$_.Status -eq "Running"})
            {
                Invoke-Command -ComputerName $KiwiServer {Get-Service  -Name $using:KiwiService | Restart-Service -Force <#-WhatIf#>}
            }
            Write-Host " Done`n" -ForegroundColor Yellow
        }
        catch
        {
            Write-Host " Error!"
            Write-Host $_.Exception
            Break                            
        } 
        Try
        {
                $DisplayWindowLabel.text = "Monitoring for new log entries..."
                $DisplayWindowLabel.Refresh()
                Write-Host "Monitoring the Logs for new entries..." -ForegroundColor Yellow -NoNewline
            do
            {
                $kiwiLogs = Get-ChildItem $kiwiLogDirectory | Sort-Object -Descending LastWriteTime | Select-Object -First 1
                Start-Sleep 1
                $updateTime = Get-Date
            }
            until ($kiwiLogs.LastWriteTime -gt "$now" -or $updateTime -gt $now.AddMinutes(1))

            if ($kiwiLogs.LastWriteTime -gt "$now") 
            {
                $Counter = 3
                Write-Host " Logging is Good`n" -ForegroundColor Green
                          Start-Sleep 1
            }

            Elseif ($updateTime -gt $now.AddMinutes(1))
            {
               if ($Counter -ne 3)
               {
                   Write-Host " Logging Was Not Successful...Restarting the $($KiwiService) Service" -ForegroundColor Red -BackgroundColor Yellow
                   Start-Sleep -Seconds 5
                   Clear-Host
                   Restart-Kiwi
                } 
            }
        }
        catch
        {
            Write-Host " Error!"
            Write-Host $_.Exception
            Break
        }
    }
    until ($Counter -eq 3)
While ($Counter -ne 3) {Restart-Kiwi}
if ($Counter -eq 3) {Remove-Variable -Name Counter; Write-Host "`nThis Task is Complete" -ForegroundColor Green;}
$DisplayWindowLabel.text = "Kiwi System Service Has Been Restarted Successfully"
$DisplayWindowLabel.Refresh()
}


#endregion

#######################################################################################################################################################################################
#region TSI Script
##############################################################################################################################################################
function Move-TSIFiles
{
Clear-Host
    #region for the moving process and set up for email
    $TSIFilePath = @()
    $TSIFilePath += "\\mi\dfs\TSI-Docs\Production1709\Nexus\INTEGRATIONS\CLIENTREQUESTERR"
    $TSIFilePath += "\\mi\dfs\TSI-Docs\Production1709\Nexus\INTEGRATIONS\VENDORRESPONSEERR"
    $TSIFilePath += "\\mi\dfs\TSI-Docs\Production1709\Nexus\INTEGRATIONS\VENDORRESPONSEERR\Need Info\Charles Jones"
    $TSIMailClientSubject = $TSIFilePath -imatch "CLIENTREQUESTERR"
    $TSIMailVendorSubject = $TSIFilePath -imatch "VENDORRESPONSEERR" -notmatch "Charles Jones"
    $TSIMailCharlesJonesSubject = $TSIFilePath -imatch "Charles Jones"
    $TSINeedInfo = "Need Info"
    $TSINewScoms = "New Scoms"
    $PSEmailServer = "mailgw1.rockfin.com"
    $ToDayTime = "ITSupportAnalysts@amrock.com","itteamnoconcall@quickenloans.com","3134074802@vtext.com"
    $ToNightTime = "ITSupportAnalysts@amrock.com","itteamnoconcall@quickenloans.com"
    $From = "itteamnoconcall@quickenloans.com"
    $TSIEmail = $true
    $TSIFilePathsHash = @{}
    $ClientEmailHash = @{}
    $VendorEmailHash = @{}
    $CharlesJonesEmailHash = @{}
    
    $TSIFilePath | ForEach-Object {$TSIFilePathsHash[$($_)] = Test-Path -Path "$_\*.txt", "$_\*.xml"} 
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
    
    foreach ($Key in $TSIFilePathsHash.Keys)
    {
        if ($TSIFilePathsHash.$Key -like "False","False")
            {
                Write-Host "There are no New Files to Move from Path $($Key)`n" -ForegroundColor Cyan
            }
        else
            {
                Write-Host "Checking Directory $($Key)`n" -ForegroundColor Cyan
                [array]$FileNames = Get-ChildItem -Path  $Key -Filter *.txt
                $FileNames += Get-ChildItem -Path  $Key -Filter *.xml
                  foreach ($FileName in $FileNames)
                {
                                   
                       if ($Filename.directory.name -imatch "CLIENTREQUESTERR" ) 
                       {
                        $FileName | ForEach-Object {$ClientEmailHash[$($_)] = $($FileName.directory) }
                        Move-Item -Path "$($Key)\$($FileName.Name)" -Destination "$($Key)\$($TSINeedInfo)" #-WhatIf
                        Write-Host "File "$($FileName.Name) has been moved to the $TSINeedInfo Directory"`n" -ForegroundColor Green 
                       }
                       if ($Filename.directory.name -imatch "VENDORRESPONSEERR" )
                       {
                        $FileName | ForEach-Object {$VendorEmailHash[$($_)] = $($FileName.directory) }
                        Move-Item -Path "$($Key)\$($FileName.Name)" -Destination "$($Key)\$($TSINeedInfo)" #-WhatIf
                        Write-Host "File "$($FileName.Name) has been moved to the $TSINeedInfo Directory"`n" -ForegroundColor Green
                       }
                       if ($Filename.directory.name -imatch "Charles Jones" )
                       {
                        $FileName | ForEach-Object {$CharlesJonesEmailHash[$($_)] = $($FileName.directory) }
                        Move-Item -Path "$($Key)\$($FileName.Name)" -Destination "$($Key)\$($TSINewScoms)" #-whatif
                        Write-Host "File "$($FileName.Name) has been moved to the $TSINewScoms Directory"`n" -ForegroundColor Green
                       }
                      $TSIEmail = $false
                    
                }   
             }
    }
    #endregion
    
    ##############################################################################################################################################################
    
   #region Sending Email
    if (!$TSIEmail)
    {
        $BodyClient ="
        Hello, $TimeOfDay,`n
        The following file(s) have been moved to the $TSINeedInfo directory.`n
    $($ClientEmailHash.keys.name -join "`n")`n`n`n It Team NOC Oncall | PH: (313)373-4770
        "

        $BodyVendor ="
        Hello, $TimeOfDay ,`n
        The following file(s) have been moved to the $TSINeedInfo directory.`n
    $($VendorEmailHash.keys.name -join "`n")`n`n`n It Team NOC Oncall | PH: (313)373-4770
        "

        $BodyCharlesJones ="
        Hello, $TimeOfDay,`n
        The following file(s) have been moved to the $($TSINewScoms) directory.`n
    $($CharlesJonesEmailHash.keys.name -join "`n")`n`n`n It Team NOC Oncall | Ext (313)373-4770
    "
    #region Sending Vendor Email    
        if ($VendorEmailHash.Values -imatch "VENDORRESPONSEERR") 
        {
            
        
         if ((Get-Date).Hour -lt "9" -or (Get-Date).Hour -ge "21" -or (Get-Date).DayOfWeek -eq "Saturday","Sunday" )
         {
             Write-Host "This will be sent After hours Email"
             Send-MailMessage -To $ToNightTime -From $From -Subject "Folder $TSIMailVendorSubject File Count = $($VendorEmailHash.Values.count)" -Body  $BodyVendor -SmtpServer $PSEmailServer
             
         }
         else
         {  
             Write-Host "This will Email During Business Hours"
             Send-MailMessage -To $ToDayTime -From $From -Subject "Folder $TSIMailVendorSubject File Count = $($VendorEmailHash.Values.count)" -Body $BodyVendor -SmtpServer $PSEmailServer
         }
       
        }
    #endregion     
    #region Sending Client Email     
         if ($ClientEmailHash.Values -imatch "CLIENTREQUESTERR")
         {
         if ((Get-Date).Hour -lt "9" -or (Get-Date).Hour -ge "21" -or (Get-Date).DayOfWeek -eq "Saturday","Sunday" ) #Change $ChangeTime to Get-Date
         {
            Write-Host "This will be sent After hours Email"
            Send-MailMessage -To $ToNightTime -From $From -Subject "Folder $TSIMailClientSubject Count = $($ClientEmailHash.Values.count)" -Body  $BodyClient -SmtpServer $PSEmailServer
            
         }
         else
         {  
             Write-Host "This will Email During Business Hours"
             Send-MailMessage -To $ToDayTime -From $From -Subject "Folder $TSIMailClientSubject File Count = $($ClientEmailHash.Values.count)" -Body $BodyClient -SmtpServer $PSEmailServer
         }
       
        }
    #endregion
    
    #region Sending Charles Jones Email     
     if ($CharlesJonesEmailHash.Values -imatch "Charles Jones")
     {
     if ((Get-Date).Hour -lt "8" -or (Get-Date).Hour -ge "17" -or (Get-Date).DayOfWeek -eq "Saturday","Sunday" ) #Change $ChangeTime to Get-Date
     {
         Write-Host "This will be sent After hours Email"
         Send-MailMessage -To $ToNightTime -From $From -Subject "Folder $($TSIMailCharlesJonesSubject) File Count = $($CharlesJonesEmailHash.Values.count)" -Body  $BodyCharlesJones -SmtpServer $PSEmailServer
    
     }
    else
     {  
        Write-Host "This will Email During Business Hours"
        Send-MailMessage -To $ToDayTime -From $From -Subject "Folder $($TSIMailCharlesJonesSubject) File Count = $($CharlesJonesEmailHash.Values.count)" -Body $BodyCharlesJones -SmtpServer $PSEmailServer
     }
     
     }
#endregion       
        } 
        $TotalFilesMoved = $($VendorEmailHash.Values.count) + $($ClientEmailHash.Values.count) + $($CharlesJonesEmailHash.Values.count)
    $DisplayWindowLabel.text = "A Total of $($TotalFilesMoved) File Have Been Moved"
    Write-Host "This Task Is Complete." -ForegroundColor Yellow
    #endregion
}
    #endregion

#######################################################################################################################################################################################
#region Scorboard Script

#region Set Variables
$Service1 = "CMSSocketListenerService"
$Service2 = "ScoreboardWindowsServiceV2"
#endregion

#region Functions

function Restart-Scoreboard{
function Pistons {Get-Service -ComputerName ql1teleweb3 -Name $Service1, $Service2}
function Caves {Get-Service -ComputerName ql2teleweb3 -Name $Service2}
                       Clear-Host;
                       $DisplayWindowLabel.text = "Logging Into Teleweb Servers. This Process May Take A Few Minutes..."
                       $TheATeam = Pistons ; $TheATeam += Caves
                       Start-Sleep -Seconds 1

                       #ScoreBoard Stopping Services
                       $DisplayWindowLabel.text = "Stopping Scoreboard Services..."
                       Pistons | Stop-Service -Force <#-WhatIf#>; Caves | Stop-Service -Force #-WhatIf
                       Start-Sleep -Seconds 1
 
                       #ScoreBoard Starting Service
                       $DisplayWindowLabel.text = "Starting Scoreboard Service..."
                       Caves | Start-Service; Pistons | Start-Service #-WhatIf
                       Start-Sleep -Seconds 1
#enregion

#region Status Check
                       
                       if((Pistons | Where-Object {$_.status -eq "Running"}) -and (Caves | Where-Object {$_.status -eq "Running"}))
                       {
                        $DisplayWindowLabel.text = "The Scoreboard Services have been Successfully Restarted"
                       }
                       Else
                       {
                        $DisplayWindowLabel.text = "Restarting the Scoreboard Service has Failed Please Look up Restarting Scorboard in Confuence for More information."
                       }
#endregion   

Write-Host "This Task is Completed." -ForegroundColor Yellow
}
#endregion
#endregion

#######################################################################################################################################################################################
#region SCOM Clean Up Tool
Add-Type -AssemblyName System.Windows.Forms
#Import-Module OperationsManager
#Import-Module '\\mi\dfs\applications\SCOM2012\Powershell\OperationsManager\OperationsManager.psd1'
New-SCOMManagementGroupConnection -ComputerName 'OpsMgr'
#region Main Functions
function Modify-Alert
{
Param
(
    [parameter(Mandatory=$true)]
    [Microsoft.EnterpriseManagement.Monitoring.MonitoringAlert[]]
    $Alerts,
    [parameter(Mandatory=$true)]
    [int]
    $ResolutionState,
    [parameter(Mandatory=$true)]
    [string]
    $Owner

)
BEGIN{}
PROCESS
{
    $Alerts.Refresh()
    foreach($Alert in $Alerts)
    {
        if(!$Alert.Owner -or $Alert.Owner -ilike "*NOC*")
        {
            Set-SCOMAlert -Alert $Alert -ResolutionState $ResolutionState -Owner $Owner
        }
        else
        {
            Set-SCOMAlert -Alert $Alert -ResolutionState $ResolutionState -Owner $($Alert.Owner)
        }
    }
}
END
{
    $DisplayWindowLabel.text = "Cleaned $totalAlertCount Alerts!"
}
}

function Clean-SCOMView
{
Param
(
    [parameter(Mandatory=$false)]
    [switch]
    $FirstRun
)
BEGIN
{
    
    
    $teamNocGroup = Get-SCOMGroup -DisplayName "IT Team Noc View"
    $nonProdteamNocGroup = Get-SCOMGroup -DisplayName "dev and test"
    $class = Get-SCOMClass -DisplayName "IT Team NOC View - Engineer Level"
    $depth = [Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive
    $NonProdRegex = "BETA|\w+\dB\b(?!-)|\w+B(?<!web)(?<!job)(?<!db)\d\b(?!-)|TEST|\w+\dT\b(?!-)|\w+T(?<!MOVEIT)\d\b(?!-)|DEV|\w+\dD\b(?!-)|POC|DEMO"
        
    [string]$alertOwner = "$($env:USERNAME) using Saria -General GUI-"

    [int]$closed = 255
    [int]$acknowledged = 249
    [int]$assignedToEngineering = 248
    [int]$uptimeAcknowledged = 245
    [int]$nonProdAcknowledged = 244
    [int]$new = 0


    $teamNocCriteria = "
    Severity==2 AND
    Priority!=0 AND 
    MonitoringObjectInMaintenanceMode==0 AND
    ResolutionState!=255 AND
    ResolutionState!=245 AND
    ResolutionState!=248 AND
    ResolutionState!=244
    "
    $mmCriteria = "
    Severity==2 AND
    Priority!=0 AND 
    MonitoringObjectInMaintenanceMode==1 AND
    ResolutionState!=255 AND
    ResolutionState!=245 AND
    ResolutionState!=248 AND
    ResolutionState!=244
    "
    $nonProdCriteria = "
    Severity==2 AND
    Priority!=0 AND 
    MonitoringObjectInMaintenanceMode==0 AND
    ResolutionState!=255 AND
    ResolutionState!=248 AND
    ResolutionState!=245 AND
    ResolutionState!=244
    "
    
    
    [int]$totalAlertCount = 0

    [System.Collections.ArrayList]$nonProdAlerts=@()
    [System.Collections.ArrayList]$mainAlerts=@()
    [System.Collections.ArrayList]$mmAlerts=@()
        
    $alertsForMM=($teamNocGroup.GetMonitoringAlerts($mmCriteria, $Class, $depth))
    $mainAlerts=($teamNocGroup.GetMonitoringAlerts($teamNocCriteria, $Class, $depth))
    $alertsForNonProd=($nonProdteamNocGroup.GetMonitoringAlerts($nonProdCriteria, $Class, $depth))

    
}
PROCESS
{

    $mainAlerts |
        where { $_.MonitoringObjectHealthState -eq "success" } | 
            %{
                Modify-Alert -Alerts $_ -ResolutionState $closed -Owner $alertOwner
                $totalAlertCount++
            }

    $alertsForMM |
        %{
            Modify-Alert -Alerts $_ -ResolutionState $closed -Owner $alertOwner
            $totalAlertCount++
        }

    $alertsForNonProd |
        %{
            Modify-Alert -Alerts $_ -ResolutionState $nonProdAcknowledged -Owner $alertOwner
            $totalAlertCount++
        }

    $mainAlerts=($teamNocGroup.GetMonitoringAlerts($teamNocCriteria, $Class, $depth))


    <#$mainAlerts | 
        where { $_.netbioscomputername -like "*exch*" } | 
            %{
                Modify-Alert -Alerts $_ -ResolutionState $assignedToEngineering -Owner $alertOwner
                $totalAlertCount++
            }#>

    <#$mainAlerts |
        Where { $_.Name -like "Total CPU Utilization*" } | 
            %{
                Modify-Alert -Alerts $_ -ResolutionState $assignedToEngineering -Owner $alertOwner
                $totalAlertCount++
            }#>

    $mainAlerts |
        Where { $_.Name -eq "Certificate lifespan alert" } | 
            %{
                Modify-Alert -Alerts $_ -ResolutionState $assignedToEngineering -Owner "Awaiting Ownership"
                $totalAlertCount++
            }

    $mainAlerts |
        where { $_.MonitoringObjectDisplayName -eq "SMS Agent Host" } | 
            %{
                Modify-Alert -Alerts $_ -ResolutionState $assignedToEngineering -Owner $alertOwner
                $totalAlertCount++
            }

    $mainAlerts |
        Where { $_.MonitoringObjectDisplayName -eq "DefaultAppPool" } | 
            %{
                Modify-Alert -Alerts $_ -ResolutionState $assignedToEngineering -Owner $alertOwner
                $totalAlertCount++
            }

    $mainAlerts |
        Where { $_.MonitoringObjectDisplayName -eq "Default Web Site" } | 
            %{
                Modify-Alert -Alerts $_ -ResolutionState $assignedToEngineering -Owner $alertOwner
                $totalAlertCount++
            }

    $mainAlerts |
        where { $_.Name -eq "Windows Remote Management Service Stopped" -or $_.Name -eq "Windows Workstation Service Stopped" } | 
            %{
                Modify-Alert -Alerts $_ -ResolutionState $assignedToEngineering -Owner "David Fallert"
                $totalAlertCount++
            }

    <#$mainAlerts |
        where { $_.Name -eq "Percentage of Committed Memory in Use is too high" -or $_.Name -eq "Available Megabytes of Memory is too low" } | 
            %{
                Modify-Alert -Alerts $_ -ResolutionState $assignedToEngineering -Owner $alertOwner
                $totalAlertCount++
            }#>
}
END
{
    $DisplayWindowLabel.text = "Cleaned $totalAlertCount Alerts!"
}
}
#endregion
#endregion

#######################################################################################################################################################################################
#region Rockframework Script
########################################################################################################################################################################
#
# Version 1.0 September 16, 2017
# Colin Steward (QL NOC)
# RockFrameworkLog Backup and Delete
# Script to resolve RockFramework SCOM alerts
# If a RockFrameworkLog folder has more than 75 logs, this script will make a backup of the 5 most recent then delete the rest
#
# REQUIRES: Run as Administrator from utility box
#           
# Please contact Colin Steward EXT:54076 before modifying
#
########################################################################################################################################################################
# Imports module for SCOM integration
<#
# Checks for Admin Rights
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        Pause
            Break
}
#>
# Ignores red text errors
$ErrorActionPreference = "silentlycontinue"
#
########################################################################################################################################################################



# Function to manually input servers. Change "manualSwitch" boolean to true in Get-RockLogs function to work


function Get-RockLogs
{
#Import-Module OperationsManager
#Import-Module '\\mi\dfs\applications\SCOM2012\Powershell\OperationsManager\OperationsManager.psd1'
New-SCOMManagementGroupConnection -ComputerName 'OpsMgr'
    $mainAlerts = $null
    $serverList = $null
    $rockFrameworkServerNames = @()
    $teamNocGroup = Get-SCOMGroup -DisplayName "IT Team Noc View"
    $class = Get-SCOMClass -DisplayName "IT Team NOC"
    $depth = [Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive
$teamNocCriteria = "
Severity==2 AND
Priority!=0 AND
ResolutionState==249
"
    $mainAlerts = ($teamNocGroup.GetMonitoringAlerts($teamNocCriteria, $Class, $depth))
    $rockFrameworkAlerts = $mainAlerts |  Where-Object {$_.Name -like "Rock Framework LOGGER File Count*"}
    if ($rockFrameworkAlerts -ne $null)
        {
            $rockFrameworkServerNames = $rockFrameworkAlerts.MonitoringObjectDisplayName -replace "\.[a-z]+", ""
            $serverList = $rockFrameworkServerNames
        }
    else{$DisplayWindowLabel.text = "There are No Framework LOGGER Alerts at This Time";$DisplayWindowLabel.Refresh()}



# Change "$manualSwitch" boolean to "$true" to enable manual input of the servers 


        [int]$fileCountBefore = 0
        [int]$fileCountAfter = 0
        [int]$fileCountDeleted = 0
        [array]$fileCountDeleted = $null

    

  
        if($serverList -ne $null)
        {
            foreach($server in $serverList)
            {
            $DisplayWindowLabel.text = "Checking User files on Server $($server)"
            $DisplayWindowLabel.Refresh()
            Start-Sleep -Milliseconds 500
                $path = "\\$($server)\C$\Users\"
                $users = Get-ChildItem -Path $path
                    foreach($user in $users)
                    {
                        $appFolders = "$($user.FullName)\AppData\Local\Temp\RockFramework\"
                        $appId = Get-ChildItem -Path $appFolders
                            foreach($app in $appId)
                            {
                                $loggerFolder = "$($app.FullName)\_LOGGER\"
                                $loggerFiles = Get-ChildItem -Path $loggerFolder
                                    if($loggerFiles.count -ge 75)
                                    {
                                     $DisplayWindowLabel.text = "Deleting Log Files From User $($user) App ID $($app)"
                                     $DisplayWindowLabel.Refresh()
                                        $fileCountBefore = $loggerFiles.count 
                                        $filesToDelete += (get-childitem -path $loggerFolder -Exclude *.dll -Recurse -Force) <# | 
                                        Where-Object {$_.lastwritetime -lt (get-date).AddDays(0)}  #>
                                            $filesDeleted = $filesToDelete.count
                                                if($filesDeleted -ge 1)
                                                {
                                                    New-Item "\\mi\dfs\shared\NOC Team\RockFrameworkBackup\$($server)\$($user)\$($app) $(Get-Date -f MM-dd-yyyy)\" -type Directory
                                                    $copyPath = "\\mi\dfs\shared\NOC Team\RockFrameworkBackup\$($server)\$($user)\$($app) $(Get-Date -f MM-dd-yyyy)\"   
                                                        $loggerFiles | 
                                                        Sort-Object CreationTime -Descending | 
                                                        Select-Object -First 5 | 
                                                        Copy-Item -Destination $copyPath
                                                }
                                                    ForEach-Object { Remove-Item $filesToDelete.FullName -recurse -force -verbose -ErrorAction "SilentlyContinue"}
                                                        if($filesDeleted -ge 1)
                                                        {
                                                            $fileCountDeleted += "$($server)`: $($user)`: $($app)`:" + " $($filesDeleted)"
                                                
                                                        }   
                                    }
                                                        if($filesDeleted.count -le 0)
                                                        {
                                                         $DisplayWindowLabel.text = "`No Files in the $($user) Directory to Delete " ;$DisplayWindowLabel.Refresh()
                                                         
                                                         Start-Sleep -Milliseconds 500
                                                        }
                            }
                    }
            }
                if(Test-Path "\\$($server)\C$\Windows\Temp\RockFramework\")
                {
                    foreach($server in $serverList)
                    {
                     $DisplayWindowLabel.text = "Checking files in Server $($server)"
                     $DisplayWindowLabel.Refresh()
                     Start-Sleep -Milliseconds 500
                        $path = "\\$($server)\C$\Windows\Temp\RockFramework\"
                        $appId = Get-ChildItem -Path $path
                            foreach($app in $appId)
                            {
                                $loggerFolder = "$($app.FullName)\_LOGGER\"
                                $loggerFiles = Get-ChildItem -Path $loggerFolder
                                    if($loggerfiles.count -ge 75)
                                    {
                                     $DisplayWindowLabel.text = "Deleting Log Files From $($Path) App ID $($app)"
                                     $DisplayWindowLabel.Refresh()
                                        $fileCountBefore = $loggerFiles.count
                                        $filesToDelete += get-childitem -path $loggerFolder -Exclude *.dll -Recurse -Force <# | 
                                        Where-Object {$_.lastwritetime -lt (get-date).AddDays(0)}  #>
                                            $filesDeleted = $filesToDelete.count
                                                if($filesDeleted -ge 1)
                                                {
                                                    New-Item "\\mi\dfs\shared\NOC Team\RockFrameworkBackup\$($server)\RockFrameworkLogs\$($app) $(Get-Date -f MM-dd-yyyy)\" -type Directory
                                                    $copyPath = "\\mi\dfs\shared\NOC Team\RockFrameworkBackup\$($server)\RockFrameworkLogs\$($app) $(Get-Date -f MM-dd-yyyy)\"
                                                        $loggerFiles | 
                                                        Sort-Object CreationTime -Descending | 
                                                        Select-Object -First 5 | 
                                                        Copy-Item -Destination $copyPath
                                                }
                                                    ForEach-Object { Remove-Item $filesToDelete.FullName -recurse -force -verbose -ErrorAction "SilentlyContinue"}
                                                        if($filesDeleted -ge 1)
                                                        {
                                                            $fileCountDeleted += "$($server)`: $($app)`:" + " $($filesDeleted)"
                                                            
                                                
                                                        }
                
                                               }
                                               
                                                         if($filesDeleted.count -eq 0)
                                                        {
                                                         $DisplayWindowLabel.text = "There are No Files Found in $($server) Directory to Delete"
                                                         $DisplayWindowLabel.Refresh()
                                                         Start-Sleep -Seconds 1
                                                        }
                                    }
                                    
                            }       
                    }
                if(!$filesToDelete){$DisplayWindowLabel.text = "You Were able to Delete 0 Log Files";$DisplayWindowLabel.Refresh()}
               Else{ $DisplayWindowLabel.text = "You Were able to Delete $($filesToDelete.count) Log Files";$DisplayWindowLabel.Refresh()}
        }
        
}

#endregion

#######################################################################################################################################################################################
#region POSHGUI Window

Add-Type -AssemblyName System.Windows.Forms

$SCOMALERTSFORM = New-Object system.Windows.Forms.Form
$SCOMALERTSFORM.Text = "SCOM Alert Tool"
$SCOMALERTSFORM.BackColor = "#002868"
$SCOMALERTSFORM.TopMost = $true
$SCOMALERTSFORM.Width = 498
$SCOMALERTSFORM.Height = 480
$SCOMALERTSFORM.TopMost = $false
$SCOMALERTSFORM.StartPosition = "CenterScreen"

$DisplayWindowLabel = New-Object system.windows.Forms.Label
$DisplayWindowLabel.BackColor = "#002868"
$DisplayWindowLabel.ForeColor = "#ffffff"
$DisplayWindowLabel.Width = 409
$DisplayWindowLabel.Height = 63
$DisplayWindowLabel.location = new-object system.drawing.point(34,16)
$DisplayWindowLabel.Font = "Microsoft Sans Serif,12"
$SCOMALERTSFORM.controls.Add($DisplayWindowLabel)

$HealthServiceButton = New-Object system.windows.Forms.Button
$HealthServiceButton.BackColor = "#1677e0"
$HealthServiceButton.Text = "Gray Agent Restart"
$HealthServiceButton.ForeColor = "#ffffff"
$HealthServiceButton.Width = 100
$HealthServiceButton.Height = 48
$HealthServiceButton.Add_Click({

$DisplayWindowLabel.text = "Resetting the Gray Agent’s SCOM Health Service..."
$DisplayWindowLabel.Refresh()
Start-sleep -Milliseconds 500
Reset-Health
})
$HealthServiceButton.location = new-object system.drawing.point(120,100)
$HealthServiceButton.Font = "Microsoft Sans Serif,10"
$SCOMALERTSFORM.controls.Add($HealthServiceButton)

$KiwiRestartButton = New-Object system.windows.Forms.Button
$KiwiRestartButton.BackColor = "#1677e0"
$KiwiRestartButton.Text = "Kiwi Restart"
$KiwiRestartButton.ForeColor = "#ffffff"
$KiwiRestartButton.Width = 100
$KiwiRestartButton.Height = 48
$KiwiRestartButton.Add_Click({

$DisplayWindowLabel.text = "Restarting the Kiwi System Service..."
$DisplayWindowLabel.Refresh()
Start-sleep -Milliseconds 500
Restart-Kiwi
})
$KiwiRestartButton.location = new-object system.drawing.point(120,167)
$KiwiRestartButton.Font = "Microsoft Sans Serif,10"
$SCOMALERTSFORM.controls.Add($KiwiRestartButton)

$TSIFileButton = New-Object system.windows.Forms.Button
$TSIFileButton.BackColor = "#1677e0"
$TSIFileButton.Text = "TSI File Move"
$TSIFileButton.ForeColor = "#ffffff"
$TSIFileButton.Width = 100
$TSIFileButton.Height = 48
$TSIFileButton.Add_Click({

$DisplayWindowLabel.text = "Moving the TSI Files That Have Alerted..."
$DisplayWindowLabel.Refresh()
Start-sleep -Milliseconds 500
Start-Sleep -Milliseconds 500
Move-TSIFiles
})
$TSIFileButton.location = new-object system.drawing.point(120,236)
$TSIFileButton.Font = "Microsoft Sans Serif,10"
$SCOMALERTSFORM.controls.Add($TSIFileButton)

$ScoreboardServiceButton = New-Object system.windows.Forms.Button
$ScoreboardServiceButton.BackColor = "#1677e0"
$ScoreboardServiceButton.Text = "Scoreboard Restart"
$ScoreboardServiceButton.ForeColor = "#ffffff"
$ScoreboardServiceButton.Width = 100
$ScoreboardServiceButton.Height = 48
$ScoreboardServiceButton.Add_Click({

$DisplayWindowLabel.text = "Resetting Scoreboard Services"
$DisplayWindowLabel.Refresh()
Start-sleep -Milliseconds 500
Restart-Scoreboard
})
$ScoreboardServiceButton.location = new-object system.drawing.point(120,305)
$CleanSCOMButton.Font = "Microsoft Sans Serif,10"
$SCOMALERTSFORM.controls.Add($ScoreboardServiceButton)

$CleanSCOMButton = New-Object system.windows.Forms.Button
$CleanSCOMButton.BackColor = "#1677e0"
$CleanSCOMButton.Text = "SCOM Cleanup Tool"
$CleanSCOMButton.ForeColor = "#ffffff"
$CleanSCOMButton.Width = 100
$CleanSCOMButton.Height = 48
$CleanSCOMButton.Add_Click({

$DisplayWindowLabel.text = "Cleaning..."
$DisplayWindowLabel.Refresh()
Start-sleep -Milliseconds 500
Clean-SCOMView
})
$CleanSCOMButton.location = new-object system.drawing.point(120,374)
$CleanSCOMButton.Font = "Microsoft Sans Serif,10"
$SCOMALERTSFORM.controls.Add($CleanSCOMButton)

$RockFrameworkButton = New-Object system.windows.Forms.Button
$RockFrameworkButton.BackColor = "#1677e0"
$RockFrameworkButton.Text = "Rock Framework"
$RockFrameworkButton.ForeColor = "#ffffff"
$RockFrameworkButton.Width = 100
$RockFrameworkButton.Height = 48
$RockFrameworkButton.Add_Click({

$DisplayWindowLabel.text = "Starting Rock Framework Task..."
$DisplayWindowLabel.Refresh()
Start-sleep -Milliseconds 500
Start-Sleep -Milliseconds 500
Get-RockLogs
})
$RockFrameworkButton.location = new-object system.drawing.point(260,100)
$RockFrameworkButton.Font = "Microsoft Sans Serif,10"
$SCOMALERTSFORM.controls.Add($RockFrameworkButton)

[void]$SCOMALERTSFORM.ShowDialog()
$SCOMALERTSFORM.Dispose()
#endregion
$IVRservers = 'QL1GENGVPTEST1','QL1GENGVPTEST2','QL1GENGVP1','QL1GENGVP2','QL2GENGVP1','QL2GENGVP2'
$CCservers = 'QL1CCRECORD1','QL1CCRECORD2','QL1CCRECORD3','QL1CCRECORD4','QL1CCRECORD5','QL1CCRECORD6','QL1CCRECORD7','QL1CCRECORD8','QL1CCRECORD9','QL1CCRECORD10','QL1CCRECORD13','QL1CCRECORD14','QL1CCRECORD15','QL1CCRECORD16','QL1CCRECORD17','QL1CCRECORD18','QL1CCTRANS1'
$DUDEservers = 'QL1BFSRVC1','QL1BFSRVC2','QL2BFSRVC1','QL2BFSRVC2'

foreach ($server in $IVRservers ) {

invoke-command -computername $server -scriptblock { 
    Stop-Service 'IVRRecordingManagerService' 
    }

}

foreach ($ccserver in $CCservers ) {

invoke-command -computername $ccserver -scriptblock { 
    Get-Service 'CC_Archiver*' # | stop-service -PassThru | Set-Service -StartupType Disabled
    }

}

<#foreach ($dudeserver in $DUDEservers ) {

invoke-command -computername $dudeserver -scriptblock { 
    Stop-WebAppPool 'DUDE' 
    }

}#>
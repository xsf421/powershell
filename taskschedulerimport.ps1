#$creds = Import-Clixml -Path 'C:\users\pmills-\desktop\creds.xml'
$username = 'VDI-Tasker'
$password = read-host "What's the VDI-Tasker password?"

$tasks = Get-ChildItem '\\mi\vdi\Software\Current\Scripts\Tasker Scripts\Tasks'

foreach ($task in $tasks) {

Register-ScheduledTask -Xml ( get-content "\\mi\vdi\software\current\scripts\tasker scripts\tasks\$task" | 
                                Out-String ) -taskpath '\VDI Tasks\' -TaskName $task.name.trimend(".xml")  -User $username -Password $password -Force

Disable-ScheduledTask -TaskPath '\VDI Tasks\' -TaskName $task.name.trimend(".xml")

}

Copy-Item -Recurse '\\mi\vdi\software\current\scripts\tasker scripts\' 'C:\Support\' 

# VDI-Tasker

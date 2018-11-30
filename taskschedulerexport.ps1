<#> $creds = Import-Clixml -Path '\\mi\dfs\shared\noc team\pmills\dashcred.xml'
$username = $creds.UserName
$password = $creds.password
</#>

$outpath = 'C:\users\pmills-\desktop\sched\'

$tasks = Invoke-Command -ComputerName 'ql1utilgeneral1' -ScriptBlock {

            Get-ScheduledTask -TaskPath '\Quicken Loans\'

            }

foreach ($task in $tasks) {

if ($task.author -notlike 'MI\sstruzik-' ) {

    $taskname = $task.TaskName 

    Invoke-Command -computername 'ql1utilgeneral1' -ScriptBlock {

        Export-ScheduledTask -TaskName $($using:task.TaskName) -TaskPath $($using:task.TaskPath) | Out-File (Join-Path $outpath "$($using:taskname).xml")
        }
    }
}





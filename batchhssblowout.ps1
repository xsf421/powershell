$servers = 'ql1vendor1'

#$creds = Get-Credential

    invoke-command -ComputerName $servers -scriptblock {

        Get-Service -name 'healthservice' | Stop-Service
        Remove-Item -Recurse "C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State\Health Service Store"
        Get-Service -name 'healthservice' | Start-Service
        } -AsJob #-Credential $creds


Get-Job | Wait-Job

get-job | Remove-Job
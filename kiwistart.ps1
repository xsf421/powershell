invoke-command -ComputerName 'ql2ksyslog1' -ScriptBlock {

Start-Service '*kiwi*'

}
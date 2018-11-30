$server = 'ql2wfdb1'

invoke-command -computername $server -scriptblock { 

    if ( test-path -path "C:\Support\$env:computername-mpio.txt" ) {

    remove-item "C:\Support\$env:computername-mpio.txt"

    }

    mpclaim -b "C:\Support\$env:computername-mpio.txt"

     

}
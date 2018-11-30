import-module WebAdministration

gsv -cn ql1obtest2,ql1wfimport1b -name 'docimport*' | Restart-Service

gsv -cn ql2obimport1t,ql2obimport1b -name 'docimport*' | Restart-Service

invoke-command -computername 'ql1obtest1' -scriptblock {

Restart-WebAppPool appserver

}
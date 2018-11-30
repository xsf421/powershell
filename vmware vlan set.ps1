$observers = Get-VM -Name '*t2-ob2*'

$obnic = Get-NetworkAdapter -vm $observers[0]

$nwname = $obnic.NetworkName

ForEach ($observer in $observers)
{
$nic = Get-NetworkAdapter -VM $observer
Set-NetworkAdapter -NetworkAdapter $nic -NetworkName $nwname -confirm:$false
}
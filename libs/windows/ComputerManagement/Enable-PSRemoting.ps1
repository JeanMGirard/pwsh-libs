$RemoteHost = "DIMGO\DESKTOP-JM"
$Username = "Jean.M.Girard@Dimgo.net"

#Sets all the networks to private
. \\DESKTOP-JM\Scripts\Scripts\Windows\Network\Set-Net-Privacy.ps1


Enable-PSRemoting -Force

# Trust all PCs
# Set-Item wsman:\localhost\client\trustedhosts *
# Trust only :
Set-Item wsman:\localhost\client\trustedhosts $RemoteHost

Restart-Service WinRM


# TEST CONNECTION
Test-WsMan $RemoteHost

#Invoke command
Invoke-Command -ComputerName $RemoteHost -ScriptBlock { Write-Output "test" } -credential $Username
Invoke-Command -ComputerName $RemoteHost -ScriptBlock { Get-ChildItem C:\ } -credential $Username
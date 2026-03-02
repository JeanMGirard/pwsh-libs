<#
													"SatNaam WaheGuru"

Date: 16-Feb-2012 ; 11:55AM
Author: Aman Dhally
Email:  amandhally@gmail.com
web:	www.amandhally.net/blog
blog:	http://newdelhipowershellusergroup.blogspot.com/
More Info : http://newdelhipowershellusergroup.blogspot.in/2012/02/set-computer-name-using-powershell.html 

Version : 

	/^(o.o)^\ 

#>



[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$name = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Desired Computer Name ")
$computerName = Get-WmiObject Win32_ComputerSystem
$computername.Rename($name)
write-Host "$([char]1) Computer Name is changed to `"$name`", I am Going to Reboot Laptop after 5 seconds."  -ForegroundColor Green
write-host $([char]7)
sleep 1
write-host $([char]7)
sleep 1 
write-host $([char]7)
sleep 1
write-host $([char]7)
sleep 1
write-host $([char]7)
sleep 1
Restart-Computer -Force 

### End of Script ## 



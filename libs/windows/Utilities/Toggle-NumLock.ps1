<# 
 .SYNOPSIS 
  PowerShell script to enable NumLock at logon. 
 .DESCRIPTION 
  The PS script detects the NumLock state to see whether it's enabled/disabled.   
  If disabled, it will enable it.  If enabled, the script will exit.   
  Add this PS script to your computer startup logon GPO.   
  Please remember to test this prior to introducing it into your production 		  environment.   
 .PARAMETER
  No parameters.
 .EXAMPLE
  No examples.
 .LINK
  No website link.
#> 
$kbObj = New-Object -ComObject WScript.Shell 
$nlStatus = [console]::NumberLock 
If ($nlStatus -eq $false) 
 {$kbObj.SendKeys('{NUMLOCK}')} 
Else  
 {exit}  
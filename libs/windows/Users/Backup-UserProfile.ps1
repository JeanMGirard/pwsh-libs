# Write-Log Function
Function Write-Log {
    Param ([String]$LOGSTRING)
    If (Test-Path $LOGFILE){
        If ((Get-Item $LOGFILE).Length -Gt 2mb){
            Rename-Item $LOGFILE ($LOGFILE + ".Bak") -Force
            New-Item -Itemtype File -Force -Path $LOGFILE
        }
    }
    (Get-Date -UFormat "%Y-%M-%D").Tostring() + " " + $LOGSTRING | Out-File -Filepath $LOGFILE -Append
}

# Change $LOGFILEPATH to a server location
$LOGFILEPATH = "\\<server>\C$\Logs"
$LOGFILENAME = "User_Profile_Backup"
$LOGFILE = "$LOGFILEPATH\$LOGFILENAME.log"

If (!(Test-Path $LOGFILEPATH)){
	New-Item -Itemtype Directory -Force -Path $LOGFILEPATH
}

# Begin Script
Write-Log "----  Begin Local Script Execution  ----"

# Identify Environment Variables
$COMPUTER = $env:computername # Or a list of computers $COMPUTER = @(Get-Content "C:\FolderPath\Filename.txt")
$COMPANDUSER = @(GWMI Win32_Computersystem -CN $COMPUTER | Select -Property Username,Name)
$CURRENTUSER = $COMPANDUSER.Username.Split("\")[1]

# Test connectivity to the computer
Write-Log "Testing Connection To $COMPUTER..."

If (Test-Connection -Computername $COMPUTER -Buffersize 16 -Count 1 -Ea 0 -Quiet)
{
	Write-Log "$COMPUTER - Online!"

	# Test if a user is currently logged on
	If (Test-Path "\\$COMPUTER\C$\Users\$CURRENTUSER")
	{
		Write-Log "$CURRENTUSER Is Currently Logged On $COMPUTER"

		[String]$CONTACTSSOURCE = "\\$COMPUTER\C$\Users\$CURRENTUSER\Contacts"
		[String]$CONTACTSDESTINATION = "\\$COMPUTER\C$\Users\$CURRENTUSER\User Profile Backup\Contacts"
		If (!(Test-Path $CONTACTSDESTINATION))
		{
			Copy-Item -Path $CONTACTSSOURCE -Destination $CONTACTSDESTINATION -Force -Verbose -Recurse
			Write-Log "Backup Of Contacts Was Successful!"
		}
		Else {Write-Log "WARNING!!! Backup Of Contacts Already Exists Or Failed!"}

		[String]$DESKTOPSOURCE = "\\$COMPUTER\C$\Users\$CURRENTUSER\Desktop"
		[String]$DESKTOPDESTINATION = "\\$COMPUTER\C$\Users\$CURRENTUSER\User Profile Backup\Desktop"
		If (!(Test-Path $DESKTOPDESTINATION))
		{
			Copy-Item -Path $DESKTOPSOURCE -Destination $DESKTOPDESTINATION -Force -Verbose -Recurse
			Write-Log "Backup Of Desktop Was Successful!"
		}
		Else {Write-Log "WARNING!!! Backup Of Desktop Already Exists Or Failed!"}
		
		[String]$DOCUMENTSSOURCE = "\\$COMPUTER\C$\Users\$CURRENTUSER\Documents"
		[String]$DOCUMENTSDESTINATION = "\\$COMPUTER\C$\Users\$CURRENTUSER\User Profile Backup\Documents"
		If (!(Test-Path $DOCUMENTSDESTINATION))
		{
			Copy-Item -Path $DOCUMENTSSOURCE -Destination $DOCUMENTSDESTINATION -Force -Verbose -Recurse
			Write-Log "Backup Of Documents Was Successful!"
		}
		Else {Write-Log "WARNING!!! Backup Of Documents Already Exists Or Failed!"}
		
		[String]$DOWNLOADSSOURCE = "\\$COMPUTER\C$\Users\$CURRENTUSER\Downloads"
		[String]$DOWNLOADSDESTINATION = "\\$COMPUTER\C$\Users\$CURRENTUSER\User Profile Backup\Downloads"
		If (!(Test-Path $DOWNLOADSDESTINATION))
		{
			Copy-Item -Path $DOWNLOADSSOURCE -Destination $DOWNLOADSDESTINATION -Force -Verbose -Recurse
			Write-Log "Backup Of Downloads Was Successful!"
		}
		Else {Write-Log "WARNING!!! Backup Of Downloads Already Exists Or Failed!"}
		
		[String]$FAVORITESSOURCE = "\\$COMPUTER\C$\Users\$CURRENTUSER\Favorites"
		[String]$FAVORITESDESTINATION = "\\$COMPUTER\C$\Users\$CURRENTUSER\User Profile Backup\Favorites"
		If (!(Test-Path $FAVORITESDESTINATION))
		{
			Copy-Item -Path $FAVORITESSOURCE -Destination $FAVORITESDESTINATION -Force -Verbose -Recurse
			Write-Log "Backup Of Favorites Was Successful!"
		}
		Else {Write-Log "WARNING!!! Backup Of Favorites Already Exists Or Failed!"}
		
		[String]$LINKSSOURCE = "\\$COMPUTER\C$\Users\$CURRENTUSER\Links"
		[String]$LINKSDESTINATION = "\\$COMPUTER\C$\Users\$CURRENTUSER\User Profile Backup\Links"
		If (!(Test-Path $LINKSDESTINATION))
		{
			Copy-Item -Path $LINKSSOURCE -Destination $LINKSDESTINATION -Force -Verbose -Recurse
			Write-Log "Backup Of Links Was Successful!"
		}
		Else {Write-Log "WARNING!!! Backup Of Links Already Exists Or Failed!"}
		
		[String]$MYDOCUMENTSSOURCE = "\\$COMPUTER\C$\Users\$CURRENTUSER\My Documents"
		[String]$MYDOCUMENTSDESTINATION = "\\$COMPUTER\C$\Users\$CURRENTUSER\User Profile Backup\My Documents"
		If (!(Test-Path $MYDOCUMENTSDESTINATION))
		{
			Copy-Item -Path $MYDOCUMENTSSOURCE -Destination $MYDOCUMENTSDESTINATION -Force -Verbose -Recurse
			Write-Log "Backup Of My Documents Was Successful!"
		}
		Else {Write-Log "WARNING!!! Backup Of My Documents Already Exists Or Failed!"}
	}
	Else {Write-Log "There Are Currently No Users Logged On Computer: $COMPUTER!"}
}
Else
{
	Write-Log "Unable To Connect To: $COMPUTER!"
}

Write-Log "----  END LOCAL SCRIPT  ----"

# End Script

. $PSScriptRoot/files/ini.ps1

# Download
# UINI.ZIP
# Navigate to the folder before foldername
# type: attrib -s -h foldername
# type: cd foldername
# Update the DESKTOP.INI file with UINI.EXE
# type UINI.EXE
# section key value
# type: attrib +s +h desktop.ini
# type: cd..
# type: attrib +r foldername
# Links


function Get-DesktopIni {
  Param (
    [Parameter(Mandatory=$false, Position = 0)]
    [string]$Folder=".",
    [Parameter(Position = 1)]
    [bool]$Create = $true,
    [switch]$Edit,
    [switch]$Close
  )
  $Folder = $Folder.TrimEnd("\")
  $desktopIni = "$Folder\desktop.ini"
  $ini = @{} 
  # $ini.".ShellClassInfo" = @{}

  if (-not (Test-Path $Folder)) {
    Write-Verbose "$Folder is not a valid folder."
    return $desktopIni, $ini
  }
  elseif (-not (Test-Path $desktopIni)) {
    if (($Close) -or (-not $Create)) {
      Write-Verbose "No desktop.ini in $Folder" 
      return $desktopIni, $ini
    }
    else {
      Write-Verbose "Creating desktop.ini in $Folder" 
      New-Item -Path $desktopIni -ItemType File
    }
  } else {
    $ini = Get-IniContent -FilePath $desktopIni
  }


  if ($Close){
    Write-Verbose "Applying desktop.ini attributes to $Folder" 
    attrib +s +h $desktopIni
    attrib +r $Folder
  }
  elseif ($Edit) {
    Write-Verbose "Removing desktop.ini attributes to $Folder"
    attrib -s -h $desktopIni
  }

  if (!($ini -is [Hashtable])) {  $ini = @{} }
  # if (!($ini[".ShellClassInfo"] -is [Hashtable])) {  $ini[".ShellClassInfo"] = @{} }

  return $desktopIni, $ini
}


function Close-DesktopIni {
  param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Folder
  )
  $desktopIni, $ini = Get-DesktopIni -Folder $desktopIni -Create $false -Close
}


function Open-DesktopIni {
  param(
    [Parameter(Mandatory=$false, Position = 0)]
    [string]$Folder="."
  )
  $desktopIni, $ini = Get-DesktopIni $Folder -Create $true -Edit

  Write-Verbose "Opening desktop.ini in Notepad" 
  notepad $desktopIni
}


function Set-DesktopIni {
  param(
    [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
    [string]$Folder,
    [Parameter(Position = 1)]
    [string]$Section=".ShellClassInfo",
    [Parameter(Position = 2)]
    [string]$Key,
    [Parameter(Position = 3)]
    [string]$Value,
    [ValidateSet("Documents", "MyDocuments", "Pictures", "MyPictures", "PhotoAlbum", "Music", "MyMusic", "MusicArtist", "MusicAlbum", "Videos", "MyVideos", "VideoAlbum", "UseLegacyHTT", "CommonDocuments", "Generic")]
    [string]$FolderType=$null,
    [string]$Icon=$null
  )
  $desktopIni, $ini = Get-DesktopIni $Folder -Edit
  attrib -s -h $desktopIni

  if (!($ini -is [Hashtable])) {  $ini = @{} }
  if (!($ini[$section] -is [Hashtable])) {  $ini[$section] = @{} }
  if (-not $ini[".ShellClassInfo"] -is [Hashtable]){  $ini[".ShellClassInfo"] = @{} }

  
  if (-not $null -eq $FolderType){  $ini[".ShellClassInfo"]["FolderType"]=$FolderType; }
  if (-not $null -eq $Icon){        $ini[".ShellClassInfo"]["Icon"]=$Icon; }

  if ((-not $null -eq $Value) -or (-not $null -eq $Key)){
    Set-IniValue -InputObject $ini -Section $Section -Key $Key -Value $Value -FilePath $desktopIni
  } 
  Out-IniFile -InputObject $ini -FilePath $desktopIni
  
  attrib +s +h $desktopIni
  attrib +r $Folder
}


Export-ModuleMember -Function Get-*,Set-*

$Shell  = New-Object -ComObject ("WScript.Shell")

$StrPath="E:"
$IconsPath="$home/.config/customization/icons"
$Links="$home/Links/Storage"


mkdir $Links






$LinksA = "Backups", "Clouds", "Enterprises", "Developments", "Libraries", "Medias", "Network"

user
Security

Foreach ($l in $LinksA){
  $Link = $Shell.CreateShortcut("$Links\$l.lnk")
  $Link.TargetPath="File://$StrPath\$l\";
  $Link.IconLocation="$IconsPath/$l.ico"
  $Link.Description = "$l"
  $Link.Save()
}









attrib +h +s $StrPath/Desktop.ini

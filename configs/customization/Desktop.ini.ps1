$Shell  = New-Object -ComObject ("WScript.Shell")

$StrPath="E:"
$DskName="Storage"
$DskDesc="Storage (Main)"
$IconsPath="$home/.config/customization/icons"
$Links="$home/Links/Storage"


ECHO [.ShellClassInfo] > $StrPath/DESKTOP.INI
ECHO IconFile=$IconsPath/$DskName.ico         >> $StrPath/DESKTOP.INI
ECHO InfoTip=$DskDesc                         >> $StrPath/DESKTOP.INI
ECHO Logo=file://$IconsPath/$DskName.bmp      >> $StrPath/DESKTOP.INI
ECHO WideLogo=file://$IconsPath/$DskName.bmp  >> $StrPath/DESKTOP.INI
ECHO FolderType=CommonDocuments               >> $StrPath/DESKTOP.INI
ECHO DefaultDropEffect=2                      >> $StrPath/DESKTOP.INI

ECHO [DeleteOnCopy]           >> $StrPath/DESKTOP.INI
ECHO Owner=                   >> $StrPath/DESKTOP.INI
ECHO Personalized=13          >> $StrPath/DESKTOP.INI
ECHO PersonalizedName=Files   >> $StrPath/DESKTOP.INI




ECHO [.ExtShellFolderViews]    >> $StrPath/DESKTOP.INI

ECHO [Channel]    >> $StrPath/DESKTOP.INI

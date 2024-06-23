



# ========================================
Install-Module PSCommander
Install-Commander

$Documents = [Environment]::GetFolderPath('MyDocuments')
$Commander = Join-Path $Documents 'PSCommander'
$commanderConfig = (Join-Path $Commander 'config.ps1')

New-Item $Commander -ItemType Directory
New-Item $commanderConfig


# New-CommanderSchedule -CronExpression "* * * * *" -Action {
#   Start-Process Notepad
# }
# New-CommanderCustomProtocol -Protocol myApp -Action {
#   if ($args[0] -eq 'notepad') { Start-Process notepad }
#   if ($args[0] -eq 'calc') { Start-Process calc }
#   if ($args[0] -eq 'wordpad') { Start-Process wordpad }
# }


Start-Commander
# ========================================




Write-Host "________________ Winget Apps _________________________________"
winget list -Source winget
#  %{new-object psobject -prop (ConvertFrom-StringData $_)} | Format-Table -AutoSize

Write-Host "_________________ Scoop Apps _________________________________"
scoop list | Select-Object Name, Version | Format-Table -AutoSize

Write-Host "_________________ Chocolatey Apps ____________________________"
choco list --local-only | Select-Object Name, Version | Format-Table -AutoSize

Write-Host "__________________ Modules ___________________________________"
Get-Module | Select-Object Name, ExportedCommands | Format-Table -AutoSize
# Get-Module -ListAvailable | Select-Object Name | Format-Table -AutoSize



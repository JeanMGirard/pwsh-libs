$ExpFolder = $browser.SelectedPath

Get-AdDomain | Export-Csv "$ExpFolder/AD-Domain.csv"
Get-ADUser | Export-CSV "$ExpFolder/AD-Users.csv"
Get-ADGroup | Export-CSV "$ExpFolder/AD-Groups.csv"



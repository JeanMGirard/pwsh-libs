


function Search-Verbs {  Get-Verb | Select-Object -ExpandProperty Verb | Sort-Object; }

Set-Alias -Name verbs -Value Search-Verbs


Export-ModuleMember -Function Search-*
Export-ModuleMember -Alias verbs

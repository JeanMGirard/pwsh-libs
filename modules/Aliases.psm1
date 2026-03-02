
# -----------------
#    POWERSHELL
# -----------------
function Find-Aliases{
    [CmdletBinding()]
    param(
        [Parameter()][switch]$Pretty=$false,
        [Parameter()][switch]$Definitions=$false
    )
    $ALIASES=(Get-Alias | Where-Object { $_.HelpUri -notmatch 'microsoft' } | Sort-Object -Property Name)

    if ($Pretty){
      foreach ($let in ($ALIASES | Group-Object -Property { $_.Name.Substring(0, 1) })) { 
        $concat = "";
        foreach ($als in $let.Group){ $concat = "$concat $als,"; }
        Write-Host "    $($let.Name.ToUpper())      $concat"
      }
    } elseif ($Definitions){
      $ALIASES | Format-Table -AutoSize
    } else {
      $ALIASES `
        | Group-Object -Property { $_.Name.Substring(0, 1) } `
        | Format-Table -AutoSize
    }
}

Set-Alias -Name list-aliases -Value Find-Aliases


Export-ModuleMember -Function Find-Aliases
Export-ModuleMember -Alias    list-aliases

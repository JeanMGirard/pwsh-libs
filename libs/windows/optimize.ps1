


<#
.SYNOPSIS
.DESCRIPTION
Write processes to a file.

.PARAMETER Path
Path to output file.

.EXAMPLE
Export-Processes -Path ./processes.csv
#>
function Export-Processes(){
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position=0)][string] $Path
  )
  process {
    $processes = Get-Process
    $processes | Group-Object -Property ProcessName | `
      Format-Table Name, @{n='Mem (KB)';e={'{0:N0}' -f (($_.Group|Measure-Object WorkingSet -Sum).Sum / 1KB)};a='right'} `
      | Export-Csv -Path $Path
  }
}

function Show-SystemStatus(){
  [CmdletBinding()]
  param()
  process {
    $processes = Get-Process
    $processes | Get-Member


  }
}








function Delete-SubDirectoryByName {
  param (
    [Parameter(Mandatory=$true, Position=0)][string]$Match,
    [Parameter()][string]$Path="."
  )
  Get-ChildItem -Path $Path -Recurse -Directory -Filter $Match | ForEach-Object {
    if (Test-Path $_.FullName) {
      Write-Host "Deleting '$_'..."
      Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue 6>&1 | Out-Null
    }
  }
}




function New-TemporaryFile {
  param (
    [Parameter(Mandatory=$false, Position=0)][String] $Name
  )
  $parent = [System.IO.Path]::GetTempPath()
  if (-not $Name) { $Name = [System.IO.Path]::GetRandomFileName(); }
  return New-Item -ItemType File -Path (Join-Path $parent $Name)
}

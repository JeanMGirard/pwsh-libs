




function New-TemporaryDirectory {
  param (
    [Parameter(Mandatory=$false, Position=0)][String] $Name
  )
  $parent = [System.IO.Path]::GetTempPath()
  if (-not $Name) { $Name = [System.IO.Path]::GetRandomFileName(); }
  return New-Item -ItemType Directory -Path (Join-Path $parent $Name)
}

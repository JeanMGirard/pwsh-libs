



function Test-FileLocked {
  param(
      [String] $path
  )

  $file = New-Object System.IO.FileInfo $path

  if (!(Test-Path $path)) {
      return $false
  }

  try {
      $stream = $file.Open(
          [System.IO.FileMode]::Open,
          [System.IO.FileAccess]::ReadWrite,
          [System.IO.FileShare]::None
      )
      if ($stream) {
          $stream.Close()
      }
      return $false
  } catch {
      # The file is locked by a process.
      return $true
  }
}


function New-TemporaryDirectory {
  param (
    [Parameter(Mandatory=$false, Position=0)][String] $Name
  )
  $parent = [System.IO.Path]::GetTempPath()
  if (-not $Name) { $Name = [System.IO.Path]::GetRandomFileName(); }
  return New-Item -ItemType Directory -Path (Join-Path $parent $Name)
}

function New-TemporaryFile {
  param (
    [Parameter(Mandatory=$false, Position=0)][String] $Name
  )
  $parent = [System.IO.Path]::GetTempPath()
  if (-not $Name) { $Name = [System.IO.Path]::GetRandomFileName(); }
  return New-Item -ItemType File -Path (Join-Path $parent $Name)
}


Export-ModuleMember -Function `
  'Test-FileLocked', `
  'New-TemporaryDirectory', 'New-TemporaryFile'





function Test-isFileLocked {
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

function Ensure-Directory {

}


function Export-SortedContent {
  param (
    [Parameter(Mandatory=$true, Position=0)][string]$InputFile,
    [Parameter(Mandatory=$true, Position=1)][string]$OutputFile,
    [Parameter(Mandatory=$false)][Switch]$Unique=$false
  )

  if (-not $InputFile -or -not $OutputFile) {
      Write-Error "InputFile and OutputFile parameters are required."
      exit 1
  }

  # Sort and remove duplicates using built-in Windows sort
  # Note: sort.exe handles large files via temporary disk files
  if ($Unique){
    sort.exe /unique $InputFile > $OutputFile
  } else {
    sort.exe $InputFile > $OutputFile
  }
}

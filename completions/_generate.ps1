
$outputDir=(Join-Path -Path $PSScriptRoot -ChildPath 'temp')

if (-not (Test-Path -Path $outputDir)){
  New-Item -Path $outputDir -ItemType Directory
}


foreach ($cli in @("kubectl", "docker")){
  Write-Host "Generation Completion for $cli"

  if (Get-Command $cli){
    Invoke-Expression -Command "$cli completion powershell > (Join-Path -Path $outputDir -ChildPath '${cli}.ps1')" `
      -ErrorAction SilentlyContinue | Out-Null
    if ($err){ Write-Error "Error generation completion for $cli" }
  } else {
    Write-Host "Command $cli not found"
  }
}



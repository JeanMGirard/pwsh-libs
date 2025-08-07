
$ALL_COMPLETIONS_FILE = "$PSScriptRoot/_all.ps1"


# Generates completion files -----------------------------------------------------------------
foreach ($cli in @("kubectl", "docker", "helm", "flux", "podman", "mongocli", "atlas")){
  Write-Host "Generation Completion for $cli"

  if (Get-Command $cli -ErrorAction SilentlyContinue){
    Invoke-Expression -Command "$cli completion powershell > (Join-Path -Path `"$PSScriptRoot`" -ChildPath '${cli}.ps1')" `
      -ErrorAction SilentlyContinue | Out-Null
    if ($err){ Write-Error "Error generation completion for $cli" }
  } else {
    Write-Host "Command $cli not found"
  }
}



# Generates _all.ps1 ------------------------------------------------------------------------
if (Test-Path $ALL_COMPLETIONS_FILE) {
  Remove-Item -Path $ALL_COMPLETIONS_FILE
}
Get-ChildItem -Path $PSScriptRoot -Filter "*.ps1" | Where-Object { -not $_.Name.startsWith('_') } | ForEach-Object {
  Add-Content -Path $ALL_COMPLETIONS_FILE -Value ([Environment]::NewLine)
  Add-Content -Path $ALL_COMPLETIONS_FILE -Value (Get-Content -Path $_.FullName)
}

# --------------------------------------------------------------------------------------------

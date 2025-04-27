


foreach ($cli in @("kubectl", "docker", "helm", "podman")){
  Write-Host "Generation Completion for $cli"

  if (Get-Command $cli){
    Invoke-Expression -Command "$cli completion powershell > (Join-Path -Path `"$PSScriptRoot`" -ChildPath '${cli}.ps1')" `
      -ErrorAction SilentlyContinue | Out-Null
    if ($err){ Write-Error "Error generation completion for $cli" }
  } else {
    Write-Host "Command $cli not found"
  }
}



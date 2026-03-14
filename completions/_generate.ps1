[CmdletBinding()]
param(
    [Parameter(HelpMessage="Skip regenerating completions files")]
    [switch]$SkipGenerate=$false
)

$ALL_COMPLETIONS_FILE = "$PSScriptRoot/_all.ps1"
$ALL_COMPLETIONS_FILE2 = "$PSScriptRoot/_all_pre7.ps1"


$CommandsWithCompletions = @(
  "kubectl",
  "docker",
  "helm",
  "helmfile",
  "flux",
  "podman",
  "mongocli",
  "atlas",
  "kops",
  "skaffold",
  "sops",
  "shfmt",
  "istio",
  "kind",
  "ngrok",
  "terrafile",
  "terraform",
  "terragrunt",
  "traefik",
  "vault",
  "ytt",
  "atlantis",
  "azcopy",
  "consul",
  "minikube",
  "k9s"
)

# Generates completion files -----------------------------------------------------------------
foreach ($cli in ($CommandsWithCompletions | Where-Object { -not $SkipGenerate } `
    | Sort-Object { (Test-Path (Join-Path -Path $PSScriptRoot -ChildPath "$_.ps1")) })  ){
  Write-Host "Generation Completion for $cli"

  if (Get-Command $cli -ErrorAction SilentlyContinue){
    Invoke-Expression -Command "$cli completion powershell > (Join-Path -Path `"$PSScriptRoot`" -ChildPath '${cli}.ps1')" `
      -ErrorAction SilentlyContinue | Out-Null
    if ($err){
      Write-Error "Error generation completion for $cli : $_"
    }
  } else {
    Write-Host "Command $cli not found"
  }
}



# Generates _all.ps1 ------------------------------------------------------------------------
Remove-Item -Path $ALL_COMPLETIONS_FILE -ErrorAction SilentlyContinue -Force
Remove-Item -Path $ALL_COMPLETIONS_FILE2 -ErrorAction SilentlyContinue -Force


Get-ChildItem -Path $PSScriptRoot -Filter "*.ps1" | Where-Object { -not $_.Name.startsWith('_') } | ForEach-Object {
  $scriptPath = $_.FullName
  $cliName = $_.BaseName
  try {
      . $scriptPath
      Write-Host "completion sourced successfully ($cliName)."
      Add-Content -Path $ALL_COMPLETIONS_FILE -Value ([Environment]::NewLine)
      Add-Content -Path $ALL_COMPLETIONS_FILE -Value (Get-Content -Path $scriptPath)
  }
  catch {
      Write-Host "Completion outdated ($cliName)."
      Add-Content -Path $ALL_COMPLETIONS_FILE2 -Value ([Environment]::NewLine)
      Add-Content -Path $ALL_COMPLETIONS_FILE2 -Value (Get-Content -Path $scriptPath)
  }
}

# --------------------------------------------------------------------------------------------

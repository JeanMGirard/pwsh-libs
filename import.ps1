


# =================================================================
# Imports
# =================================================================
# Write-Host "Importing"
$imports = @(
  "posh-git",
  "modules/1Password.psm1",
  "modules/Aliases.psm1",
  "modules/Aws.psm1",
  "modules/Docker.psm1",
  "modules/Git.psm1",
  "modules/History.psm1",
#  "libs/Jenkins.psm1",
  "modules/K8s.psm1",
  "modules/K8sHelm.psm1",
  "modules/Search.psm1",
  "modules/Vault.psm1",
  "modules/Wsl.psm1",
  "aliases.ps1"
)

foreach ($import in $imports) {
  if ((-not $import.EndsWith(".psm1")) -and (-not $import.EndsWith(".ps1"))) {
    Import-Module -Name $import
    continue
  }

  $modulePath = Join-Path -Path $PSScriptRoot -ChildPath $import
  if (-not (Test-Path -Path $modulePath)) {
    Write-Host "Module not found: $import"
  } elseif ($import.EndsWith(".psm1")){
    Import-Module -Name $modulePath
  } elseif ($import.EndsWith(".ps1")){
    . $modulePath
  }
}

# Write-Host "  modules..."
# Import-Module posh-git

# Write-Host "  theme..."
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/powerlevel10k_rainbow.omp.json" | Invoke-Expression
### emodipt-extend  kushal night-owl powerlevel10k_rainbow

# =================================================================
# Completions
# =================================================================
# Write-Host "  completions..."
if ((-not (Test-Path "$PSScriptRoot/completions/_all.ps1")) -and (Test-Path "$PSScriptRoot/completions/_generate.ps1")) {
  Write-Host "Generating completions..."
  . "$PSScriptRoot/completions/_generate.ps1"
}
if (Test-Path "$PSScriptRoot/completions/_all.ps1") {
  . "$PSScriptRoot/completions/_all.ps1"
}


# =================================================================
# Environment
# =================================================================
# Use-1PasswordEnvFile "$PSScriptRoot\.env" -TemplateFile "$PSScriptRoot\.env.example"

# =================================================================

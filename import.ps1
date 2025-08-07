


# =================================================================
# Imports
# =================================================================
# Write-Host "Importing"
$imports = @(
  "posh-git",
  "libs/1password.psm1", 
  "libs/aliases.psm1", 
  "libs/aws.psm1", 
  "libs/docker.psm1",
  "libs/fs.psm1",
  "libs/git.psm1",
  "libs/history.psm1",
  "libs/jenkins.psm1",
  "libs/k8s.psm1",
  "libs/k8s.helm.psm1",
  "libs/search.psm1",
  "libs/vault.psm1",
  "libs/wsl.psm1",
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

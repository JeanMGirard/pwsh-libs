


# =================================================================
# Imports
# =================================================================
# Write-Host "Importing"

# Write-Host "  modules..."
# Import-Module posh-git
Import-Module $PSScriptRoot/libs/aliases.psm1
Import-Module $PSScriptRoot/libs/aws.psm1
Import-Module $PSScriptRoot/libs/docker.psm1
Import-Module $PSScriptRoot/libs/fs.psm1
Import-Module $PSScriptRoot/libs/git.psm1
Import-Module $PSScriptRoot/libs/history.psm1
Import-Module $PSScriptRoot/libs/jenkins.psm1
Import-Module $PSScriptRoot/libs/search.psm1
Import-Module $PSScriptRoot/libs/vault.psm1
Import-Module $PSScriptRoot/libs/wsl.psm1

# Write-Host "  theme..."
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/powerlevel10k_rainbow.omp.json" | Invoke-Expression
### emodipt-extend  kushal night-owl powerlevel10k_rainbow

# Write-Host "  completions..."
# . $PSScriptRoot/completions/aws.ps1
# . $PSScriptRoot/completions/docker.ps1
# . $PSScriptRoot/completions/flux.ps1
# . $PSScriptRoot/completions/helm.ps1
# . $PSScriptRoot/completions/kubectl.ps1
# . $PSScriptRoot/completions/podman.ps1

# Write-Host "  aliases..."
. $PSScriptRoot/aliases.ps1

# =================================================================

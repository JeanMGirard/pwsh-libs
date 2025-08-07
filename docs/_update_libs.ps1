# Install-Module -Name PlatyPS -Scope CurrentUser
# Install-Module -Name MarkdownPS -Scope CurrentUser

Import-Module PlatyPS
Import-Module MarkdownPS

# New-MarkdownHelp -Module "1password"  -OutputFolder ".\docs\libs\1password" -Force
# Update-MarkdownHelp -Module "1password" -OutputFolder ".\docs\libs\1password" -Force

# =================================================================
# Configs
# =================================================================
$DELETE_PREVIOUS_ROOT = $true

$repoRoot = (Get-Item (Join-Path -Path $PSScriptRoot -ChildPath "..")).FullName
$docsRoot = "docs/libs"

# =================================================================
# Initialization
# =================================================================
$doNotEditAlert=New-MDAlert -Lines ("Do not edit directly. Please refer to the " + (New-MDLink -Text "CONTRIBUTING.md" -Link "../../CONTRIBUTING.md")) -Style Important
$markdownReadme = (New-MDHeader "PowerShell Libraries" -Level 1) + "`n" + $doNotEditAlert
$modules = (Get-ChildItem -Path "$repoRoot/libs" -File -Filter "*.psm1")

# =================================================================
# Clean up previous documentation
# =================================================================
if ($DELETE_PREVIOUS_ROOT -and (Test-Path -Path "$repoRoot/$docsRoot")) { 
  Write-Host "Removing previous documentation at: $docsRoot"
  Remove-Item -Path "$repoRoot/$docsRoot"-Recurse -Force 
}

# =================================================================
# Modules
# =================================================================
Write-Host "Generating documentation for $($modules.Count) modules..."
foreach ($module in $modules) {
    $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($module.Name)
    Write-Host "  * $moduleName"
    $docsPath = "$docsRoot/$moduleName"
    $docsFullPath = "$repoRoot/$docsPath"
    $markdownModule = (New-MDHeader "$moduleName" -Level 1) + "`n" + $doNotEditAlert

    try {
      Import-Module -Name $module.FullName -Force
    } catch {
      Write-Error "Failed to generate documentation for $moduleName. Import failed."
      continue
    }
    
    if (Test-Path -Path $docsFullPath) { Remove-Item -Path $docsFullPath -Recurse -Force }
    $docs = (New-MarkdownHelp -Module $moduleName -OutputFolder $docsFullPath -Force -WithModulePage -ModulePagePath "$docsFullPath/README.md" -ExcludeDontShow)
    # $markdownModule+=((New-MDHeader "Exports" -Level 2) + "`n")
    # $markdownModule+=New-MDList -Style Unordered -Lines ($docs | ForEach-Object {
    #   New-MDLink -Text ([System.IO.Path]::GetFileNameWithoutExtension($_.Name)) -Link "./$(($_.Name))"
    # }) -NoNewLine
    # New-Item -Path $docsFullPath -Name "README.md" -ItemType File -Value $markdownModule -Force | Out-Null
}

# =================================================================
# Overall README
# =================================================================
Write-Host "Generating docs/libs/README..."
$markdownReadme = (New-MDHeader "PowerShell Libraries" -Level 1) + "`n"
$markdownReadme += New-MDAlert -Lines ("Do not edit directly. Please refer to the " + (New-MDLink -Text "CONTRIBUTING.md" -Link "../CONTRIBUTING.md")) -Style Important
$markdownReadme += (New-MDHeader "Table of Contents" -Level 2) + "`n"
$markdownReadme += New-MDList -Style Unordered -Lines ($modules | ForEach-Object {
  $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
  $line = (New-MDLink -Text $moduleName -Link "#$moduleName")
  $line
})
$markdownReadme += "----------------------------------------------------------`n`n"

$markdownReadme += (New-MDHeader "Modules" -Level 2) + "`n"
foreach ($module in $modules) {
    $moduleName = [System.IO.Path]::GetFileNameWithoutExtension($module.Name)
    $docsFullPath = "$repoRoot/$docsRoot/$moduleName"
    $markdownReadme += (New-MDHeader $moduleName -Level 3) + "`n"
    $markdownReadme += (New-MDLink -Text "README" -Link "./$moduleName/README.md") + "`n`n"
    $markdownReadme += New-MDList -Style Unordered -NoNewLine -Lines (Get-ChildItem -Path $docsFullPath -File -Filter "*.md"  | Where-Object { $_.Name -ne "README.md" } | ForEach-Object {
        New-MDLink -Text ([System.IO.Path]::GetFileNameWithoutExtension($_.Name)) -Link "./$moduleName/$(($_.Name))"
    })
    $markdownReadme += "`n"
}
New-Item -Path "$repoRoot/docs/libs" -Name "README.md" -ItemType File -Value $markdownReadme -Force | Out-Null

# =================================================================

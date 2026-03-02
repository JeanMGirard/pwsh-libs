



# Function to download Oh My Posh theme locally
function Install-OhMyPoshTheme {
    param (
        [string]$ThemeName = "cobalt2",
        [string]$ThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/cobalt2.omp.json"
    )
    $profilePath = Get-ProfileDir
    if (!(Test-Path -Path $profilePath)) {
        New-Item -Path $profilePath -ItemType "directory"
    }
    $themeFilePath = Join-Path $profilePath "$ThemeName.omp.json"
    try {
        Invoke-RestMethod -Uri $ThemeUrl -OutFile $themeFilePath
        Write-Host "Oh My Posh theme '$ThemeName' has been downloaded to [$themeFilePath]"
        return $themeFilePath
    }
    catch {
        Write-Error "Failed to download Oh My Posh theme. Error: $_"
        return $null
    }
}

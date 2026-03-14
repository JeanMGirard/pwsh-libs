


function Select-AwsProfile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [string]$ProfileName=$null
    )
    if (-not $ProfileName) {
        $profiles = Find-AwsProfiles
        if ($profiles.Count -eq 0) {
            Write-Warning "No AWS profiles found."
            return
        }
        $ProfileName = $profiles | Out-GridView -Title "Select AWS Profile" -PassThru
    } 

    [Environment]::SetEnvironmentVariable("AWS_PROFILE", $ProfileName, "Process")
    $env:AWS_PROFILE = $ProfileName
    Write-Host "AWS_PROFILE set to $ProfileName"
    New-AwsSsoSession $ProfileName
}

function New-AwsSsoSession{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [string]$ProfileName=$env:AWS_PROFILE
    )
    Write-Host "Logging in the $ProfileName AWS Profile"
    aws sso login --profile $ProfileName
    [Environment]::SetEnvironmentVariable("AWS_PROFILE", $ProfileName, "User")
    $env:AWS_PROFILE = $ProfileName
}

function Find-AwsProfiles{
    [CmdletBinding()]
    param()
    $awsConfigPath = Join-Path -Path $env:USERPROFILE -ChildPath ".aws\config"
    if (Test-Path $awsConfigPath) {
        Get-Content $awsConfigPath | Where-Object { $_ -match '^\[profile\s+(.+)\]$' } | ForEach-Object { $matches[1] }
    } else {
        Write-Warning "AWS config file not found at $awsConfigPath"
    }
}

Set-Alias -Name aws-switch -Value Select-AwsProfile
Set-Alias -Name aws-profiles -Value Find-AwsProfiles
Set-Alias -Name aws-login -Value New-AwsSsoSession

Export-ModuleMember -Function New-AwsSsoSession, Find-AwsProfiles, Select-AwsProfile
Export-ModuleMember -Alias    aws-login, aws-profiles, aws-switch

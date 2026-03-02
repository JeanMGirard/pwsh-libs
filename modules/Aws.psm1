



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


Set-Alias -Name aws-login -Value New-AwsSsoSession

Export-ModuleMember -Function New-AwsSsoSession
Export-ModuleMember -Alias    aws-login

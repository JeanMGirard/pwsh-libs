

$env:psScriptDir = (Split-Path $script:MyInvocation.MyCommand.Path)
$env:psmodulePath = "C:\Users\JeanM\Documents\PowerShell\modules;" + $env:psmodulePath


$env:CmdDir = (get-location).Path
$env:profile  = (Join-Path -Path $env:psScriptDir -ChildPath "profile.ps1")
$env:DVS_PROFILE = $env:profile;

$profile = $env:profile

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}


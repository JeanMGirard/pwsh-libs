$env:psScriptDir = (Split-Path $script:MyInvocation.MyCommand.Path)

. (Join-Path -Path $env:psScriptDir -ChildPath "env.ps1")


Import-Module -Name Posh-Git
Import-Module -Name Posh-Docker
Import-Module -Name Posh-With
Import-Module -Name Terminal-Icons
# Import-Module -Name AWS.Tools.Common
Import-Module $env:psScriptDir/utils/Superpose


if (Test-Path -Path "$HOME/OneDrive"){
    $onedrive="$HOME/OneDrive"
} else {
    $onedrive="E:/Clouds/OneDrive"
}


# oh-my-posh init pwsh --config $env:POSH_THEMES_PATH/kushal.omp.json | Invoke-Expression
if ($null -eq $env:WT_SESSION){
    # Running conemu
    # oh-my-posh init pwsh --config ~/.config/oh-my-posh/conemu.theme.omp.json | Invoke-Expression
    oh-my-posh init pwsh --config $onedrive/Config/Apps/oh-my-posh/conemu.theme.omp.json | Invoke-Expression
} else {
    # Running windows terminal
    # oh-my-posh init pwsh --config ~/.config/oh-my-posh/terminal.theme.omp.json | Invoke-Expression
    oh-my-posh init pwsh --config $onedrive/Config/Apps/oh-my-posh/terminal.theme.omp.json | Invoke-Expression
}



. (Join-Path -Path $env:psScriptDir -ChildPath "libs/docker.ps1")
. (Join-Path -Path $env:psScriptDir -ChildPath "libs/git.ps1")
. (Join-Path -Path $env:psScriptDir -ChildPath "libs/kubernetes.ps1")
# . (Join-Path -Path $env:psScriptDir -ChildPath "libs/php.ps1")

. (Join-Path -Path $env:psScriptDir -ChildPath "tools/aliases.ps1")


. (Join-Path -Path $env:psScriptDir -ChildPath "aliases.ps1")


# . (Join-Path -Path $env:psScriptDir -ChildPath "..\Docker\docker-tools.ps1")
# . (Join-Path -Path $env:psScriptDir -ChildPath "..\Wikidata\wikidata-tools.ps1")

# echo 'plink -ssh -i C:\Users\JeanM\.ssh\Muirwood\mws.ppk ec2-user@ifm.mwstudio.ca -pw [pass]';
# list-my-alias-pretty

Set-PSReadLineOption -Colors @{
    Parameter  = 'Cyan'
    # String     = 'Cyan'
    # Command    = 'Green'
}

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

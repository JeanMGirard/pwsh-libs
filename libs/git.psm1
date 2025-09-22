



function Get-GitDefaultBranch {
    return git remote show origin | Select-String 'HEAD branch' | ForEach-Object { $_.ToString().Split(':')[1].Trim() }
}
function Invoke-ForEachRepo{
  $startDirectory = Get-Location
  $cmd = ""
  
  # if ($cmd.Length -eq 0){ 
  #   Write-Host "No command provided. Will list repositories only."
  # }

  foreach($arg in $args){
    $arg = $arg.ToString()
    if ($arg.Contains(" ")){ $arg = "`"$arg`""; }
    $cmd += $arg + " "
  }


  Get-ChildItem . -Directory -Recurse -FollowSymlink -Name '.git' -Force | ForEach-Object {
    $repo = (Get-Item -Force $_).Parent.FullName
    if ($cmd.Length -gt 0){ 
      Write-Host "Entering $repo"
      Set-Location $repo
      Invoke-Expression -Command $cmd -ErrorAction Continue 
      Set-Location $startDirectory
    } else {
      Write-Host $repo
    }
  }
}
function Reset-GitBranch {
    param (
        [string]$BranchName
    )
    if ($(git status --porcelain) -ne "") {
        Write-Host "You have uncommitted changes. Please commit or stash them before running this script."
        exit 1
        # git stash --include-untracked
    }

    git checkout $(Get-GitDefaultBranch)
    git pull
    if (git rev-parse -q --verify $BranchName) {
        Write-Host "Branch $BranchName exists. Deleting it."
        git branch -D $BranchName
    }
    git checkout -b $BranchName
}


Set-Alias -Name "git-recursive" -Value Invoke-ForEachRepo
Set-Alias -Name "git-main"      -Value Get-GitDefaultBranch


Export-ModuleMember -Function Get-*
Export-ModuleMember -Function Invoke-*
Export-ModuleMember -Function Reset-*

Export-ModuleMember -Alias git-*

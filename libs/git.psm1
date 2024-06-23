




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



Set-Alias -Name "git-recursive" -Value Invoke-ForEachRepo


Export-ModuleMember -Function Invoke-*
Export-ModuleMember -Alias git-recursive

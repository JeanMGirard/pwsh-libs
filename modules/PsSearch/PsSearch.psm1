function Search-PS{
  param(
    [parameter(position=0)][String]$word,
    [switch]$installedOnly
  )

  if($word) { $word="*"+$word+"*" }
  else      { $word="*" }
  $word= $word.replace("**", "*")
  $info = @{}

  if($installedOnly){
    $info['Scripts']  = (Get-InstalledScript $word)
    $info['Modules']  = (Get-InstalledModule $word)
    $info['Packages'] = (Get-Package $word)
  } else {
    $info['Scripts']  = (Find-Script $word)
    $info['Modules']  = (Find-Module $word)
    $info['Packages'] = (Find-Package $word)
  }
  $info['Commands']     = (Find-Command $word)
  $info['Repositories'] = (Get-PSRepository $word)
  $info['Variables']    = (Get-Variable $word)
  $info['Verbs']        = (Get-Verb $word)
  $info['Aliases']      = (Get-Alias $word)

  Write-Host "Found : " -ForegroundColor Gray
  # Out-Host -InputObject $info
  if($info.Scripts)     { Write-Host "   ---   Scripts   ---" -ForegroundColor Green ;
                          Out-Host -InputObject $info.Scripts }
  if($info.Modules)     { Write-Host "   ---   Modules   ---" -ForegroundColor Green ;
                          Out-Host -InputObject $info.Modules }
  if($info.Packages)    { Write-Host "   ---   Packages   ---" -ForegroundColor Green ;
                          Out-Host -InputObject $info.Packages }
  if($info.Repositories){ Write-Host "   ---   Repositories   ---" -ForegroundColor Green ;
                          Out-Host -InputObject $info.Repositories }
  if($info.Variables)   { Write-Host "   ---   Variables   ---" -ForegroundColor Green ;
                          Out-Host -InputObject $info.Variables }
  if($info.Verbs)       { Write-Host "   ---   Verbs   ---" -ForegroundColor Green ;
                          Out-Host -InputObject $info.Verbs }
  if($info.Aliases)     { Write-Host "   ---   Aliases   ---" -ForegroundColor Green ;
                          Out-Host -InputObject $info.Aliases }
  $info
}
Export-ModuleMember -Function 'Search-*'

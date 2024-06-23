

function Search-Term {
  [cmdletbinding()]
  param(
    [parameter(position=0)][String]$Word,
    [parameter()][switch]$Online,
    [parameter()][switch]$Silent,
    [parameter()][string]$Type
  )

  if(-not $Type) { $Type = "All" }
  if($Word) { $Word="*"+$Word+"*" }
  else      { $Word="*" }

  $Word= $Word.replace("**", "*")
  $info = @{}
  $psArgs = @{ 
    ErrorAction = "SilentlyContinue" 
    InformationAction = "SilentlyContinue"
    WarningAction = "SilentlyContinue"
  }

  function Set-Data {
    param([parameter(position=0)][string]$Title,[parameter(position=1)]$data)
    if(-not $data) { return }
    $info[$title] = $data
  }
  function Write-Data {
    param([parameter(position=0)][string]$Title,[parameter(position=1)]$data)
    if((-not $data) -or ($Silent)) { return }
    Write-Host "   ---   $Title   ---" -ForegroundColor Green ;
    Out-Host -InputObject $data
  }

  if($Online){
    (("All", "Scripts") -contains $Type) ? (Set-Data 'Scripts' (Find-Script $Word @psArgs)) : $null
    (("All", "Modules") -contains $Type) ? (Set-Data 'Modules' (Find-Module $Word @psArgs)) : $null
    (("All", "Packages") -contains $Type) ? (Set-Data 'Packages' (Find-Package $Word @psArgs)) : $null
  } else {
    (("All", "Scripts") -contains $Type) ? (Set-Data 'Scripts' (Get-InstalledScript $Word @psArgs)) : $null
    (("All", "Modules") -contains $Type) ? (Set-Data 'Modules' (Get-InstalledModule $Word @psArgs)) : $null
    (("All", "Packages") -contains $Type) ? (Set-Data 'Packages' (Get-Package $Word @psArgs)) : $null
  }
  (("All", "Commands") -contains $Type) ? (Set-Data 'Commands' (Find-Command $Word @psArgs)) : $null
  (("All", "Repositories") -contains $Type) ? (Set-Data 'Repositories' (Get-PSRepository $Word @psArgs)) : $null
  (("All", "Variables") -contains $Type) ? (Set-Data 'Variables' (Get-Variable $Word @psArgs)) : $null
  (("All", "Verbs") -contains $Type) ? (Set-Data 'Verbs' (Get-Verb $Word @psArgs)) : $null
  (("All", "Aliases") -contains $Type) ? (Set-Data 'Aliases' (Get-Alias $Word @psArgs)) : $null

  Write-Data "Scripts" $info.Scripts
  Write-Data "Modules" $info.Modules
  Write-Data "Packages" $info.Packages
  Write-Data "Commands" $info.Commands
  Write-Data "Repositories" $info.Repositories
  Write-Data "Variables" $info.Variables
  Write-Data "Verbs" $info.Verbs
  Write-Data "Aliases" $info.Aliases

  return $info
}

function Search-PSGallery {
  param(
    [parameter(position=0)][String] $name,
    [switch]$installedOnly
  )
  Find-Module -Name *$name*  -Repository PSGallery
}

Export-ModuleMember -Function 'Search-*'

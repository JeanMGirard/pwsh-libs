

function Run-Elevated ($scriptblock)
{
  # TODO: make -NoExit a parameter
  # TODO: just open PS (no -Command parameter) if $scriptblock -eq ''
  $sh = new-object -com 'Shell.Application'
  $sh.ShellExecute('powershell', "-NoExit -Command $scriptblock", '', 'runas')
}

function Confirm-AdminPrivileges {
  $current=New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  return $current.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}


function Clean-SystemPaths {

  process {
    $extraPaths = ''
    $MachineForUser = ([Environment]::GetEnvironmentVariable("Path", "Machine") -split ';' | Where-Object { $_.StartsWith('C:\Users') }) -join ';'
    $UserNoDupes = ([Environment]::GetEnvironmentVariable("Path", "User") + ";" + $MachineForUser) -split ';' `
      | Where-Object { $_.StartsWith('C:\Users')  -and (Test-Path -Path $_) } `
      | Sort-Object | ForEach-Object `
        -Begin   { $oht = [ordered] @{} } `
        -Process { $oht[$_] = $true } `
        -End     { $oht.Keys -join ';' }
      
    $extraPaths = ''
    $UserForMachine = ([Environment]::GetEnvironmentVariable("Path", "User") -split ';' | Where-Object { ! $_.StartsWith('C:\Users') }) -join ';'
    $MachineNoDupes = ([Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + $UserForMachine + ";" + $extraPaths) -split ';' `
      | Where-Object { ! $_.StartsWith('C:\Users') -and (Test-Path -Path $_) } `
      | Sort-Object | ForEach-Object `
        -Begin   { $oht = [ordered] @{} } `
        -Process { $oht[$_] = $true } `
        -End     { $oht.Keys -join ';' }

      
    [System.Environment]::SetEnvironmentVariable("Path", $UserNoDupes, "User")
    [System.Environment]::SetEnvironmentVariable("Path", $MachineNoDupes, "Machine")
    
    # [System.Environment]::SetEnvironmentVariable("Path", (
    #   [Environment]::GetEnvironmentVariable("Path", "Machine") + ';C:\Apps\Bin\pyenv\pyenv-win\bin;C:\Apps\Bin\pyenv\pyenv-win\shims'
    # ), "Machine")

    # ======================================================================
    # Remplaces long paths with system variables
    # %ProgramFiles% %SystemRoot%
    #
  }
}
function Add-SystemPath {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position=0)]
    [string] $path,
    [Parameter(Position = 1,HelpMessage = "Scope of the environment variable (Process, User, Machine). Default is Process.")]
    [string] $scope = "Process",
    [switch] $before = $false
  )
  process {
    $paths = [Environment]::GetEnvironmentVariable("Path", $scope)
    if(($paths -like "*$path;*") -or ($paths -like "*$path")){
      Write-Output "Path already exists in scope."
      return 
    }
  
    if($before){ $paths = "$path;$paths"; } else { $paths = "$paths;$path"; }
  
    [System.Environment]::SetEnvironmentVariable("Path", $paths, $scope)
  }
}

function Remove-SystemPath {
  [CmdletBinding()]
  param(
    [Parameter(Position=0, ValueFromPipeline=$true, Mandatory=$true)][string] $path,
    [Parameter(Position=1, Mandatory=$false)][string] $scope = "Process",
    [switch] $all = $false
  )
  process {
    if ($all) {
      Remove-SystemPath $path -Scope "Process"
      Remove-SystemPath $path -Scope "User"
      Remove-SystemPath $path -Scope "Machine"
      return
    }
    $syspaths = [Environment]::GetEnvironmentVariable("Path", $scope)
    if($syspaths -ne $syspaths.Replace("$path", "")){
      
      if ($scope -eq "machine") {
        $principal=New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        if(!$isAdmin){
          Write-Error "You need to run this command as Administrator to remove paths in the Machine scope.."
          return

          # $scriptblock = "[System.Environment]::SetEnvironmentVariable(`"Path`", ([Environment]::GetEnvironmentVariable(`"Path`", `"${scope}`")).Replace(`"${path};`", `"`"), `"${scope}`"); exit 0;"
          # $sh = new-object -com 'Shell.Application'
          # $sh.ShellExecute('powershell', "-Command '$scriptblock'", '', 'runas')
        }
      }
        
      [System.Environment]::SetEnvironmentVariable("Path", $syspaths.Replace("$path;", ""), $scope)
      Write-Host " * Removed $path from $scope variables."
    }
  }
}


function Search-SystemPath {
  [CmdletBinding()]
  param(
    [Parameter()][string] $scope = "process",
    [Parameter(ValueFromRemainingArguments = $true)][array] $paths = @()
  )
  process {
    $paths2 = @("")
    $paths2.CopyTo()
    if ($scope -and (@("process", "user", "machine") -notcontains $scope.ToLower())) {
      $paths.Add($scope.Clone())
      $scope = "process"
    }
    $current = [Environment]::GetEnvironmentVariable("Path", $scope).Split(';')

    foreach($p in $paths){
      foreach($c in $current){
        if ($c -like "*$p*"){ Write-Output $c }
      }
    }
  }
}




function Test-CommandAvailable {
  param (
      [Parameter(Mandatory = $True, Position = 0)]
      [String] $Command
  )
  return [Boolean](Get-Command $Command -ErrorAction Ignore)
}

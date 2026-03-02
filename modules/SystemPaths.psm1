





function Get-SystemPaths {
  [CmdletBinding()]
  param(
    [Parameter()]
    [switch] $Process = $false,
    [Parameter()]
    [switch] $User = $false,
    [Parameter()]
    [switch] $Machine = $false,
    [Parameter(HelpMessage="Filter paths that exists only", Mandatory=$false)]
    [System.Nullable[Boolean]] $Exists
  )
  process {
    $Scopes=@("Process", "User", "Machine")

    if (@($Process, $User, $Machine) -contains $true){
      if (-not $Process){ $Scopes = $Scopes -ne 'Process'; }
      if (-not $User)   { $Scopes = $Scopes -ne "User"; }
      if (-not $Machine){ $Scopes = $Scopes -ne "Machine"; }
    }

    $results = foreach ($Scope in $Scopes){
      # Write-Information $Scope
      [Environment]::GetEnvironmentVariable("Path", $Scope).Split(';') `
        | Where-Object {
          if ([string]::IsNullOrEmpty($_)){ return $false; }
          else { return (($null -eq $Exists) -or ((Test-Path $_) -eq $Exists)); }
        }
    }
    $results | Select-Object -Unique
  }
}

function Optimize-SystemPaths {

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
    [ValidateSet("Process", "User", "Machine")]
    [Parameter(Position = 1,HelpMessage = "Scope of the environment variable (Process, User, Machine). Default is Process.")]
    [string] $Scope = "Process",
    [switch] $before = $false
  )
  process {
    $paths = [Environment]::GetEnvironmentVariable("Path", $Scope)
    if(($paths -like "*$path;*") -or ($paths -like "*$path")){
      Write-Output "Path already exists in scope."
      return 
    }
  
    if($before){ $paths = "$path;$paths"; } else { $paths = "$paths;$path"; }
  
    [System.Environment]::SetEnvironmentVariable("Path", $paths, $Scope)
  }
}

function Remove-SystemPath {
  [CmdletBinding()]
  param(
    [Parameter(Position=0, ValueFromPipeline=$true, Mandatory=$true)]
    [string] $path,
    
    [ValidateSet("Process", "User", "Machine")]
    [Parameter(Position=1, Mandatory=$false)]
    [string] $Scope = "Process",

    [switch] $all = $false
  )
  process {
    if ($all) {
      Remove-SystemPath $path -Scope "Process"
      Remove-SystemPath $path -Scope "User"
      Remove-SystemPath $path -Scope "Machine"
      return
    }
    $syspaths = [Environment]::GetEnvironmentVariable("Path", $Scope)
    if($syspaths -ne $syspaths.Replace("$path", "")){
      
      if ($Scope -eq "machine") {
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
        
      [System.Environment]::SetEnvironmentVariable("Path", $syspaths.Replace("$path;", ""), $Scope)
      Write-Host " * Removed $path from $Scope variables."
    }
  }
}


function Search-SystemPath {
  [CmdletBinding()]
  param(
    [ValidateSet("Process", "User", "Machine")]
    [Parameter()]
    [string] $Scope = "process",

    [Parameter(ValueFromRemainingArguments = $true)][array] $paths = @()
  )
  process {
    $paths2 = @("")
    $paths2.CopyTo()
    if ($Scope -and (@("process", "user", "machine") -notcontains $Scope.ToLower())) {
      $paths.Add($Scope.Clone())
      $Scope = "process"
    }
    $current = [Environment]::GetEnvironmentVariable("Path", $Scope).Split(';')

    foreach($p in $paths){
      foreach($c in $current){
        if ($c -like "*$p*"){ Write-Output $c }
      }
    }
  }
}




Export-ModuleMember -Function *-SystemPaths
Export-ModuleMember -Function *-SystemPath

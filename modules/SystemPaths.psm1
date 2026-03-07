


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
      if (-not $Process){ $Scopes = $Scopes -ne "Process"; }
      if (-not $User)   { $Scopes = $Scopes -ne "User"; }
      if (-not $Machine){ $Scopes = $Scopes -ne "Machine"; }
    }

    $results = foreach ($Scope in $Scopes){
      # Write-Information $Scope
      [Environment]::GetEnvironmentVariable("Path", $Scope).Split(";") `
        | Where-Object {
          if ([string]::IsNullOrEmpty($_)){ return $false; }
          else { return (($null -eq $Exists) -or ((Test-Path $_) -eq $Exists)); }
        }
    }
    $results | Select-Object -Unique
  }
}


function Optimize-SystemPaths {
  [CmdletBinding()]
  param(
    [Parameter(HelpMessage="Dry run. Show the changes that would be applied without actually applying them.")]
    [switch] $DryRun = $false,
    [Parameter(HelpMessage="Apply changes to User scope")]
    [switch] $User = $false,
    [Parameter(HelpMessage="Apply changes to Machine scope")]
    [switch] $Machine = $false
  )
  begin {
    $SystemPathShortcuts = @{
        "LOCALAPPDATA" = "${HOME}\AppData\Local"
        "CHOCOLATEYINSTALL" = "${env:ProgramData}\Chocolatey"
        "LOCALWINGET"  = "${HOME}\AppData\Local\Microsoft\WinGet\Packages"
        "ProgramData" = $env:ProgramData
        "ProgramFiles" = $env:ProgramFiles
        "GOPATH" = $env:GOPATH
        "OneDrive" = $env:OneDrive
        "SYS32" = "C:\WINDOWS\System32"
    }
    foreach ($shortcut in $SystemPathShortcuts.GetEnumerator()) {
      $oldValue = [System.Environment]::GetEnvironmentVariable($shortcut.Key)

      # If the variable already exists and has a different value, we skip it to avoid overwriting existing shortcuts.
      # This allows users to maintain their own custom shortcuts without interference.
      if ($null -ne $oldValue -and $oldValue -ne $shortcut.Value) {
        $SystemPathShortcuts[$shortcut.Key] = $oldValue
        $shortcut.Value = $oldValue
      }

      # Remove Bad entries that do not exist on the system to avoid creating shortcuts for non-existent paths.
      if ($null -eq $shortcut.Value -or -not (Test-Path $shortcut.Value)){
        $SystemPathShortcuts.Remove($shortcut.Key)
      }
    }
  }
  process {
    # Write-Host $SystemPathShortcuts
    if (-not $User -and -not $Machine){
      Write-Warning "No scope specified. Use -User and/or -Machine to specify the scope of the optimization."
      return
    }

    Write-Host "-------------------------------------------------------------"
    Write-Host "Adding environment variable shortcuts for the following paths:" -ForegroundColor Green

    $shortcuts = @()
    foreach ($shortcut in $SystemPathShortcuts.GetEnumerator()){
      if ($null -eq $shortcut.Value -or -not (Test-Path $shortcut.Value)){
        continue;
      }

      $sKey = $shortcut.Key
      $userPath = $shortcut.Value.ToString()
      $machinePath = $userPath.Replace("${HOME}", "%USERPROFILE%")

      if ($userPath -eq $machinePath){ $userPath = $null; }
      $shortcuts += [PSCustomObject] @{
        Name = $sKey
        UserValue = $userPath
        MachineValue = $machinePath
      }
      if ($DryRun){ continue; }
      if ($User -and $null -ne $userPath){
        Write-Host "(User)    ${sKey}: $userPath" -ForegroundColor Green
        [System.Environment]::SetEnvironmentVariable($sKey, $userPath, "User");
      }
      if ($Machine -and $null -ne $machinePath){
        Write-Host "(Machine) ${sKey}: $machinePath" -ForegroundColor Green
        [System.Environment]::SetEnvironmentVariable($sKey, $machinePath, "Machine");
      }
    }
    $shortcuts | Format-Table -AutoSize -Property *
    Write-Host "-------------------------------------------------------------"
    Write-Host "Rewriting PATH environment variables" -ForegroundColor Green

    $userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $machinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
    foreach ($shortcut in ($SystemPathShortcuts.GetEnumerator() | Sort-Object -Descending { $_.Value.Length } )) {
      if ($null -eq $shortcut.Value -or -not (Test-Path $shortcut.Value)){
        continue;
      }
      $sKey = $shortcut.Key
      $sVal = $shortcut.Value

      $userPath = $userPath.Replace($sVal, "%${sKey}%")
      $userPath = $userPath.Replace($sVal.Replace("${HOME}", "%USERPROFILE%"), "%${sKey}%")
      $machinePath = $machinePath.Replace($sVal, "%${sKey}%")
      $machinePath = $machinePath.Replace($sVal.Replace("${HOME}", "%USERPROFILE%"), "%${sKey}%")
    }
    $machinePaths = $machinePath.Replace("${HOME}", "%USERPROFILE%").Split(";") `
      | Where-Object { -not ([string]::IsNullOrEmpty($_)) } `
      | ForEach-Object { $_.TrimEnd('/').TrimEnd('\') }
    $userPaths = $userPath.Replace("${HOME}", "%USERPROFILE%").Split(";") `
      | Where-Object { -not ([string]::IsNullOrEmpty($_)) -and -not $machinePaths.Contains($_) } `
      | ForEach-Object { $_.TrimEnd('/').TrimEnd('\') }

    $userPath = $userPaths -join ";"
    $machinePath = $machinePaths -join ";"

    if ($DryRun){
      ($userPaths | ForEach-Object { [PSCustomObject] @{ Scope = "User"; Path = $_ } }) `
       + ($machinePaths | ForEach-Object { [PSCustomObject] @{ Scope = "Machine"; Path = $_ } }) `
       | Format-Table -AutoSize
      return
    }

    if ($User){
      Write-Host "___ Updating PATH variable (User) _____________________________" -ForegroundColor Green
      Write-Host ([System.Environment]::GetEnvironmentVariable("PATH", "User")) -ForegroundColor Yellow
      Write-Host $userPath -ForegroundColor Green

      [System.Environment]::SetEnvironmentVariable("PATH", $userPath, "User")
      Write-Host ""
      Write-Host ""
    }
    if ($Machine){
      Write-Host "___ Updating PATH variable (Machine) _____________________________" -ForegroundColor Green
      Write-Host ([System.Environment]::GetEnvironmentVariable("PATH", "Machine")) -ForegroundColor Yellow
      Write-Host $machinePath -ForegroundColor Green

      [System.Environment]::SetEnvironmentVariable("PATH", $machinePath, "Machine")
      Write-Host ""
      Write-Host ""
    }
  }
}

function Add-SystemPath {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position=0)]
    [string] $Path,
    [ValidateSet("Process", "User", "Machine")]
    [Parameter(Position = 1,HelpMessage = "Scope of the environment variable (Process, User, Machine). Default is Process.")]
    [string] $Scope = "Process",
    [switch] $Before = $false
  )
  process {
    $paths = [Environment]::GetEnvironmentVariable("PATH", $Scope)
    if(($paths -like "*$Path;*") -or ($paths -like "*$Path")){
      Write-Output "Path already exists in scope."
      return 
    }
  
    if($Before){ $paths = "$Path;$paths"; } else { $paths = "$paths;$Path"; }
  
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
          # $sh = new-object -com "Shell.Application"
          # $sh.ShellExecute("powershell", "-Command "$scriptblock"", "", "runas")
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
    $current = [Environment]::GetEnvironmentVariable("Path", $Scope).Split(";")

    foreach($p in $paths){
      foreach($c in $current){
        if ($c -like "*$p*"){ Write-Output $c }
      }
    }
  }
}


Export-ModuleMember -Function *-SystemPaths
Export-ModuleMember -Function *-SystemPath

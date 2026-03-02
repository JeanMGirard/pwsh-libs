

function Invoke-Elevated ($scriptblock)
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

function Get-SystemArchitecture {
    $os = Get-CimInstance Win32_OperatingSystem
    $arch = $os.OSArchitecture

    if (-not $arch) {
        throw "Unable to determine system architecture."
    }

    if ($arch -eq '64-bit') {
        return 'x64'
    } elseif ($arch -eq 'ARM64') {
        return 'arm64'
    } else {
        return 'x86'
    }
}

function Test-CommandAvailable {
  param (
      [Parameter(Mandatory = $True, Position = 0)]
      [String] $Command
  )
  return [Boolean](Get-Command $Command -ErrorAction Ignore)
}


Export-ModuleMember -Function Get-SystemArchitecture
Export-ModuleMember -Function Test-CommandAvailable

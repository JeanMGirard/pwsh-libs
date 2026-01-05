

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

function Test-CommandAvailable {
  param (
      [Parameter(Mandatory = $True, Position = 0)]
      [String] $Command
  )
  return [Boolean](Get-Command $Command -ErrorAction Ignore)
}

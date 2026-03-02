

# Ensure the script can run with elevated privileges
function Assert-IsElevated {
    $windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $windowsPrincipal = New-Object -TypeName 'System.Security.Principal.WindowsPrincipal' -ArgumentList @( $windowsIdentity )

    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

    if (-not $windowsPrincipal.IsInRole($adminRole)) {
        New-InvalidOperationException -Message "This resource must run as an Administrator."
    }
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
      Write-Warning "Please run this script as an Administrator!"
      break
    }
}

Set-Alias -Name Assert-IsAdministrator -Value Assert-IsElevated

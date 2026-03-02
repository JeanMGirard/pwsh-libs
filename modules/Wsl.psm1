



function Assert-WslReady{
  # Check if WSL is installed
  if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    Write-Host "WSL is not installed. Please install WSL first."
    return $false
  }
  return $true
}


function Install-WslVpnkit {
  param(
    [Parameter(Mandatory=$false, Position=0)][String] $Version,
    [Switch] $Update=$false
  )
  
  begin {
    if (-not (Assert-WslReady)) {
      Write-Error "WSL is not ready. Please install WSL first."
      return
    }
  }
  process {
    $VpnKitDir = "$env:USERPROFILE\wsl-vpnkit"
    $prevVPN = (wsl --list --quiet  | Where-Object { $_.StartsWith("wsl-vpnkit") } )

    if ((-not $Update) -and $prevVPN) {
      Write-Host "WSL VPNKit is already installed."
      return
    }

    Write-Host "Installing WSL VPNKit..."
    if ($prevVPN) {
      Write-Host "Removing existing WSL VPNKit ($prevVPN)..."
      wsl --unregister "$prevVPN"
    }
    if (Test-Path $VpnKitDir) { Remove-Item -Path $VpnKitDir -Recurse -Force; }

    if (-not $Version) { $Version = ((Invoke-WebRequest -Uri "https://api.github.com/repos/sakai135/wsl-vpnkit/releases/latest" -UseBasicParsing).Content | ConvertFrom-Json).tag_name; }
    if (-not $Version.StartsWith("v")) { $Version = "v$Version"; }

    $url = "https://github.com/sakai135/wsl-vpnkit/releases/download/v0.4.1/wsl-vpnkit.tar.gz"
    $output = "$([System.IO.Path]::GetTempPath())wsl-vpnkit.tar.gz"
    Invoke-WebRequest -Uri $url -OutFile $output

    if (-not (Test-Path $VpnKitDir)) {  New-Item -Path $VpnKitDir -ItemType Directory; }

    wsl --import wsl-vpnkit --version 2 $VpnKitDir $output
  }
  end {}
}

function Start-WslVpnkit {
  # Start WSL VPNKit
  wsl.exe -d wsl-vpnkit --cd /app wsl-vpnkit;
}

Set-Alias -name wsl-vpnkit -Value Start-WslVpnkit

Export-ModuleMember -Function `
  'Assert-WslReady', `
  'Install-WslVpnkit', `
  'Start-WslVpnkit'

Export-ModuleMember -Alias `
  'wsl-vpnkit'

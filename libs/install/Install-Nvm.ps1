

function Install-Nvm {
  [CmdletBinding()]
  param (
      [string]$NodeVersion = "latest"
  )

  try {
    Write-Host "Installing nvm...";
    choco install -y nvm;
    refreshenv;
  }
  catch {
    Write-Error "Failed to install NVM. Error: $_"
    break
  }

  if (-not $NodeVersion) {
    Write-Host "No Node version specified (recommended: latest). Skipping installation."
    break
  }

  try {
    if ($NodeVersion -eq "latest") {
      Write-Host "Fetching the latest Node version from the official Node.js website..."
      $NodeVersion = $( curl -s https://nodejs.org/dist/index.json | jq -r '.[0].version' )
    }

    nvm install $NodeVersion
    nvm use $NodeVersion
    nvm alias default $NodeVersion
    nvm install-latest-npm
  }
  catch {
    Write-Error "Failed to install Node version. Error: $_"
    break
  }
}

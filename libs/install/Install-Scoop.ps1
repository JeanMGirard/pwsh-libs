

function Install-Scoop {
  try {
    Write-Host "Installing scoop...";
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser;
    Invoke-RestMethod get.scoop.sh | Invoke-Expression;
    refreshenv;
  }
  catch {
    Write-Error "Failed to install Scoop. Error: $_"
  }
}

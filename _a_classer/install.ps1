

# netsh interface portproxy delete v4tov4 listenport="4000" # Delete any existing port 4000 forwarding
# $wslIp=(wsl -d Ubuntu -e sh -c "ip addr show eth0 | grep 'inet\b' | awk '{print `$2}' | cut -d/ -f1") # Get the private IP of the WSL2 instance
# netsh interface portproxy add v4tov4 listenport="4000" connectaddress="$wslIp" connectport="4000"



try { if(Get-Command "scoop"){} }
catch {
    Write-Host "Installing scoop...";
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser;
    Invoke-RestMethod get.scoop.sh | Invoke-Expression;
    refreshenv;
}
try { if(Get-Command "choco"){} }
catch {
    Write-Host "Installing choco...";
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser;
    Invoke-RestMethod https://community.chocolatey.org/install.ps1 | Invoke-Expression;
    refreshenv;
}




try { if(Get-Command "nvm"){} }
catch {
    Write-Host "Installing nvm...";
    choco install -y nvm;
    refreshenv;

    $NODE_VERSION=$(curl -s https://nodejs.org/dist/index.json | jq -r '.[0].version')

    nvm install $NODE_VERSION
    nvm use $NODE_VERSION
    nvm alias default $NODE_VERSION
    nvm install-latest-npm
}

try { if(Get-Command "task"){} } catch { scoop install task; }


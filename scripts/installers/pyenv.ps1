
$PYTHON_VERSION="3.11.4"

$PYENV_ROOT="${env:USERPROFILE}\.pyenv"
$PYENV_WIN="${PYENV_ROOT}\pyenv-win"
$PIPX_DEFAULT_PYTHON="${PYENV_WIN}\shims"




Function Remove-PyEnv() {
  Write-Host "Removing $PYENV_ROOT..."
  If (Test-Path $PYENV_ROOT) {
    Remove-Item -Recurse -Force -Path $PYENV_ROOT
  }
  Write-Host "Removing environment variables..."
  $PathParts = [System.Environment]::GetEnvironmentVariable('PATH', "User") -Split ";"
  $NewPathParts = $PathParts.Where{ $_ -ne "${PYENV_WIN}\bin" }.Where{ $_ -ne "${PYENV_WIN}\shims" }
  $NewPath = $NewPathParts -Join ";"
  [System.Environment]::SetEnvironmentVariable('PATH', $NewPath, "User")

  [System.Environment]::SetEnvironmentVariable('PYENV', $null, "User")
  [System.Environment]::SetEnvironmentVariable('PYENV_ROOT', $null, "User")
  [System.Environment]::SetEnvironmentVariable('PYENV_HOME', $null, "User")
  refreshenv

}
Function Install-PyEnvFromGit(){
  Write-Host "Installing pyenv-win..."
  git clone https://github.com/pyenv-win/pyenv-win.git $PYENV_ROOT
 
  $prevPath = [System.Environment]::GetEnvironmentVariable('path', "User")
  [System.Environment]::SetEnvironmentVariable('PYENV',     $PYENV_WIN, "User")
  [System.Environment]::SetEnvironmentVariable('PYENV_ROOT',$PYENV_WIN, "User")
  [System.Environment]::SetEnvironmentVariable('PYENV_HOME',$PYENV_WIN, "User")
  [System.Environment]::SetEnvironmentVariable('PATH', "$PYENV_WIN\bin;$PYENV_WIN\shims;$prevPath","User")
  refreshenv
  pyenv update
  # pyenv install --list

  git clone --depth=1/ $PYENV_ROOT/plugins/pyenv-virtualenv
  git clone --depth=1 https://github.com/pyenv/pyenv-virtualenvwrapper.git $PYENV_ROOT/plugins/pyenv-virtualenvwrapper

  pyenv install $PYTHON_VERSION
  pyenv global $PYTHON_VERSION
  pyenv rehash

  python3 -m pip install --upgrade pip
  # python3 -m pip install --upgrade --force pipx
  pyenv rehash
  pipx ensurepath --force

  foreach ($p in @(tox poetry pipenv pytest ruff yapf black flake8 autoflake)){
    pipx install $p
  }

}

function Install-PyEnv {
  # Install Pyenv
  Invoke-WebRequest -UseBasicParsing `
    -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" `
    -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
}


Remove-PyEnv
Install-PyEnvFromGit

# [System.Environment]::SetEnvironmentVariable("PYENV_ROOT", "$env:PYENV_ROOT", "User")

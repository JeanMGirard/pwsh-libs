

mkdir C:/WSL
wsl  --set-default  Ubuntu-20.04
cp ./.wslconfig ~/
Restart-Service LxssManager


function New-WSL(){
    wsl --import Ubuntu-20.04   Ubuntu-20.04 ubuntu-21.04-wsl-rootfs-tar.gz
}
function Export-WSL(){
    wsl --export Ubuntu-20.04 Ubuntu-20.04.tar.gz
    wsl --export Ticksmith Ticksmith.tar.gz
}
function Import-WSL(){
  # <name> <path> <file>
  wsl --import Ubuntu-20.04   Ubuntu-20.04    ubuntu.20-04.tar.gz
  wsl --import Ticksmith      ticksmith       ticksmith.tar.gz
}

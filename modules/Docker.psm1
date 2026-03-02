

#Fix for Docker on windows (docker.sock)
$Env:COMPOSE_CONVERT_WINDOWS_PATHS=1
$OutputEncoding = New-Object -typename System.Text.UTF8Encoding
[Console]::OutputEncoding = New-Object -typename System.Text.UTF8Encoding



#function composer{
#    php "${env:COMPOSER_HOME}\composer.phar" @args
#}

function Remove-Container{
  param([type]$container)
  docker stop $container; docker rm $container
}
function Remove-AllContainers{
  (docker ps -a) | ForEach-Object { Remove-Container $_.split(" ")[0]; }
}

Export-ModuleMember -Function Remove-*


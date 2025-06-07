

#Fix for Docker on windows (docker.sock)
$Env:COMPOSE_CONVERT_WINDOWS_PATHS=1
$OutputEncoding = New-Object -typename System.Text.UTF8Encoding
[Console]::OutputEncoding = New-Object -typename System.Text.UTF8Encoding



#function composer{
#    php "${env:COMPOSER_HOME}\composer.phar" @args
#}

function dk-del{
    param([type]$container)
    docker stop $container; docker rm $container
}
function dk-delall{
     (docker ps -a) | ForEach-Object { 
        docker stop $_.split(" ")[0];
        docker rm   $_.split(" ")[0];
     }
}
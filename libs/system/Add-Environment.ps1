$env:PATH = $env:PATH + ";E://Apps/bin"

#Fix for Docker on windows (docker.sock)
$Env:COMPOSE_CONVERT_WINDOWS_PATHS=1
$OutputEncoding = New-Object -typename System.Text.UTF8Encoding
[Console]::OutputEncoding = New-Object -typename System.Text.UTF8Encoding

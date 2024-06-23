


$ErrorActionPreference = "Stop";

# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; $null = New-Item -Type Directory -Force $env:appdata/ccloud; Invoke-WebRequest -Uri https://binaries.cockroachdb.com/ccloud/ccloud_windows-amd64_0.4.9.zip -OutFile ccloud.zip; Expand-Archive -Force -Path ccloud.zip; Copy-Item -Force ccloud/ccloud.exe -Destination $env:appdata/ccloud; $Env:PATH += ";$env:appdata/ccloud"; 
# # We recommend adding ";$env:appdata/ccloud" to the Path variable for your system environment. See https://docs.microsoft.com/en-us/powershell/module/microsoft.p
# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; $null = New-Item -Type Directory -Force $env:appdata/cockroach; Invoke-WebRequest -Uri https://binaries.cockroachdb.com/cockroach-v23.1.4.windows-6.2-amd64.zip -OutFile cockroach.zip; Expand-Archive -Force -Path cockroach.zip; Copy-Item -Force cockroach/cockroach-v23.1.4.windows-6.2-amd64/cockroach.exe -Destination $env:appdata/cockroach; $Env:PATH += ";$env:appdata/cockroach"; # We recommend adding ";$env:appdata/cockroach" to the Path variable for your system environment. See https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables#saving-changes-to-environment-variables for more information.

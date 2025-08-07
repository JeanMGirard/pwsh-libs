
# # --------------------------------------------------------------------------------
# # Inject environment variables
# # --------------------------------------------------------------------------------
# if (Get-Command -Name 'op' -ErrorAction SilentlyContinue) {
#   $op_tpl=(Join-Path -Path $PSScriptRoot -ChildPath ".env.example")
#   $op_dist=(Join-Path -Path $PSScriptRoot -ChildPath ".env")

#   if (!(Test-Path -Path $op_dist)) { 
#     op inject -i $op_tpl -o $op_dist; 
#   }
#   if (Test-Path -Path $op_dist) {
#     get-content $op_dist | Where-Object { $_ -like '*=*' -and $_ -notlike "*#*=*" } | ForEach-Object {
#       $name, $value = $_.Trim(" ").split('=')
#       set-content env:\$name $value.Trim('"')
#       # Write-Host "$name = $value"
#     }
#   }
# } else {
#   Write-Host "1Password CLI not found. Skipping environment variable injection."
# }


function Assert-1PasswordInstalled {
    [CmdletBinding()]
    param()
    # Check if the 1Password CLI is installed
    if (-not (Get-Command -Name 'op' -ErrorAction SilentlyContinue)) {
        throw "1Password CLI is not installed. Please install it from https://1password.com/downloads/cli/"
    }
}

function Write-1PasswordEnvFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)][string] $TemplateFile,
        [Parameter(Mandatory=$true, Position=1)][string] $EnvFile,
        [Parameter(Mandatory=$false)][switch] $Force = $false
    )

    Assert-1PasswordInstalled
    if ((Test-Path -Path $EnvFile) -and (-not $Force)) { 
      return;
    } elseif (-not (Test-Path -Path $TemplateFile)) {
      throw "Template file not found: $TemplateFile"
    }

    Write-Host "Writing to 1Password environment file: $EnvFile"
    if ($Force -and (Test-Path -Path $EnvFile)) {
      Write-Host "Force option is set. Overwriting existing file."
      Remove-Item -Path $EnvFile -Force
    }
    op inject -i $TemplateFile -o $EnvFile; 
}


function Use-1PasswordEnvFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)][string] $EnvFile,
        [Parameter(Mandatory=$false)][string] $TemplateFile = $null,
        [Parameter(Mandatory=$false)][switch] $Update = $false
    )

    Assert-1PasswordInstalled
    if ($Update -or (-not (Test-Path -Path $EnvFile))) {
        if ($TemplateFile -and (Test-Path -Path $TemplateFile)) {
            Write-Host "Environment file not found. Creating from template: $TemplateFile"
            Write-1PasswordEnvFile -TemplateFile $TemplateFile -EnvFile $EnvFile -Force
        } else {
            throw "Environment file not found: $EnvFile"
        }
    }

    get-content $op_dist | Where-Object { $_ -like '*=*' -and $_ -notlike "*#*=*" } | ForEach-Object {
      $name, $value = $_.Trim(" ").split('=')
      set-content env:\$name $value.Trim('"')
    }
}

Export-ModuleMember -Function `
  Use-1PasswordEnvFile,
  Write-1PasswordEnvFile,
  Assert-1PasswordInstalled

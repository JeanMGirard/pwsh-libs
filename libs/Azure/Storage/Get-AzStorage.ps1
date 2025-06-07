
az config set extension.use_dynamic_install=yes_without_prompt

$resourceGroup=""
$accountName=""
$containerName=""
$accountKey=""


function Get-AzStorageAuthParams {
    param(
        [Parameter(Mandatory)][string]$accountName,
        [string]$connectionString,
        [string]$accountKey,
        [string]$sasToken
    )
    $params = "--account-name",$accountName
    if ($connectionString) { $params+="--connection-string","$connectionString"
    } elseif ($accountKey) { $params+="--account-key","$accountKey"
    } elseif ($sasToken)   { $params+="--sas-token","$sasToken" }
    else {
        $accountKey = $( Read-Host "Input account key:" )
        $params+="--account-key",$accountKey
    }
    return $params
}

$connParams = Get-AzStorageAuthParams -accountName $accountName -accountKey $accountKey

function Get-AzStorageAccount {
    param(
        [Parameter(Mandatory)][string]$resourceGroup,
        [Parameter(Mandatory)][string]$accountName
    )
    process {
        $account = [PSCustomObject]$( az storage account show  --resource-group $resourceGroup --name $accountName
            | ConvertFrom-Json
        )
        Add-Member -InputObject $account -MemberType ScriptMethod -Name getKey -Value {
            return (az storage account keys list -n $this.name -g $this.resourceGroup | ConvertFrom-Json | Where-Object  { $_.permissions -match "Full" })[0]
        }
        Add-Member -InputObject $account -MemberType ScriptMethod -Name getSas -Value { az storage account generate-sas --expiry }
        return $account
    }
}

function Get-AzStorageContainer {
    param(
        [Parameter(Mandatory)][array] $ConnParams,
        [Parameter(Mandatory)][string]$containerName
    )
    process {
        return [PSCustomObject]$(az storage container show $connParams --name $containerName | ConvertFrom-Json)
    }
}
function Get-AzBlobDirectories{
    param(
        [Parameter(Mandatory)][array] $ConnParams,
        [Parameter(Mandatory)][string] $ContainerName,
        [switch] $recursive=$false,
        [string] $prefix=$null,
        [int] $MaxDepth=100
    )
    process {
        [array] $directories = @()
        [array] $params = @()

        if ($prefix) {
            $params+="--prefix",$prefix
            if ([regex]::matches($prefix, "/").count -ge $MaxDepth) { return $directories }
        }

        [array] $results=(az storage blob list $ConnParams $params -c $ContainerName -o json --delimiter "/" --query '[].name | [?ends_with(@, `/`)]' | ConvertFrom-Json)
        $directories += $results

        If (($results.Count -le 0) -or ($recursive -eq $false)) {
            return $directories
        }

        # $ScriptBlock = {
        #     param($d)
        #     Write-Host "Searching in subDirectory: $d"
        #     $directories += $(Get-AzBlobDirectories -prefix "$d" -ContainerName $ContainerName -ConnParams $ConnParams -recursive -MaxDepth $MaxDepth)
        # }
        # Start-Job $ScriptBlock -ArgumentList $results
        # Get-Job
        # While (Get-Job -State "Running"){  Start-Sleep 1; }
        # Get-Job | Receive-Job

        Foreach ($d in $results){
            Write-Host "Searching in subDirectory: $d"
            $directories += $(Get-AzBlobDirectories -prefix "$d" -ContainerName $ContainerName -ConnParams $ConnParams -recursive -MaxDepth $MaxDepth)
        }

        return $directories
    }
}

function Get-AzBlobFiles{
    param(
        [Parameter(Mandatory)][Object]$connParams,
        [Parameter(Mandatory)][string]$containerName,
        [Parameter(Mandatory)][string]$folder
    )
    process {
        $params = "-c",$containerName

        return [PSCustomObject]$(az storage blob directory list $connParams $params -d $folder
            | ConvertFrom-Json
            | Select-Object -Property name, @{Name="etag"; Expression={ $_.properties.etag }}
        )
        # az storage blob list -c foo --auth-mode login --delimiter '/' --query '[].name | [?ends_with(@, `/`)]'
    }
}

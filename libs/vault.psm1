

<#
.SYNOPSIS

.DESCRIPTION
Makes sure that vault is authenticated

.PARAMETER Check Returns false instead of throwing an exception if not connected.
.PARAMETER Silent Do not write anything to console

.EXAMPLE
Assert-VaultConnected
#>
function Assert-VaultConnected {
  [CmdletBinding()]
  param(
    [Parameter()][switch] $Check,
    [Parameter()][switch] $Silent
  )

  if ((-not $env:VAULT_TOKEN) -or (-not $env:VAULT_ADDR)){
    if (-not $Silent){
      Write-Error "Vault token and address are required!"
      Write-Error "Set VAULT_ADDR and VAULT_TOKEN environment variables to correct this"
    }
    if ($Check){ return $false }
    exit 1
  }
  if ($Check){ return $true }
}

<#
.SYNOPSIS

.DESCRIPTION
Makes sure that vault is authenticated

.PARAMETER Token the vault token to use

.EXAMPLE
Connect-Vault
#>
function Connect-Vault {
  [CmdletBinding()]
  param(
    [Parameter(Position=0)][string] $Token=$env:VAULT_TOKEN
  )
  
  if (Assert-VaultConnected -Silent -Check){ 
    Write-Host "Vault already connected"
    return $true 
  }
  
  if (-not $env:VAULT_ADDR){
    Write-Host "Enter the vault addr: "
    $Addr = Read-Host
    if (-not $Addr -eq $null) {
      $env:VAULT_ADDR = $Addr
    }
  }

  if ($Token) {
    $env:VAULT_TOKEN = $Token
    return
  }

  Write-Host "Enter your vault token: "
  $Token = Read-Host

  if (-not $Token){
    Write-Host "Token required"
    return
  }

  vault login $Token | Out-Null
  $env:VAULT_TOKEN = $Token
}

<#
.SYNOPSIS

.DESCRIPTION
Copies a secret from one path to another

.PARAMETER Source The secret to copy
.PARAMETER Dest The destination path(s) of the secret to copy
.PARAMETER Prefix A prefix for the secret to copy and the destination
.PARAMETER Delete Choose to delete the source secret after copying
.PARAMETER Force Overwrite the secret if it already exists

.EXAMPLE
Copy-VaultSecret "beneva/ad/perception/dev/ad-perception-dev1/activemqfacade" "beneva/ad/perception/dev/ad-perception-sit1/activemqfacade"

.EXAMPLE
Copy-VaultSecret -Prefix "beneva/ad/perception/dev" "ad-perception-dev1/activemqfacade" "ad-perception-sit1/activemqfacade"

.EXAMPLE
Copy-VaultSecret -Delete -Prefix "beneva/ad/perception/dev" "ad-perception-dev1/activemqfacade" "ad-perception-sit1/activemqfacade"
#>
function Copy-VaultSecret {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position=0, ValueFromPipeline)][string] $Source,
    [Parameter(Mandatory, ValueFromRemainingArguments)][string[]] $Dest,
    [Parameter()][string] $Prefix,
    [Parameter()][switch] $Delete=$false,
    [Parameter()][switch] $Force=$false
  )
  
  begin {
    Assert-VaultConnected
  }
  process {
    
    if($Prefix){ $Source="$Prefix/$Source" }
    if(-not (Test-VaultSecretExists $Source)){
      Write-Error "Secret $Source does not exist"
      exit 1
    }

    $data=$(vault kv get -mount="secret" -format="json" -field="data" "$Source" | ConvertFrom-Json)
    $dataParams=@()
    foreach ($obj in $data.PSObject.Properties) {
      $dataParams+="$($obj.Name)=$($obj.Value)"
    }
    
    foreach ($CopyTo in $Dest) {
      if($Prefix){ $CopyTo="$Prefix/$CopyTo" }
      if ($Force -or (-not $(Test-VaultSecretExists $CopyTo))) {
        vault kv put -mount="secret" -format="json" -field="data" $CopyTo ${dataParams} | Out-Null
      }
    }

    if ($Delete){
      vault kv metadata delete -mount="secret" $Source | Out-Null
    }
  }
  end { }
}


<#
.SYNOPSIS

.DESCRIPTION
Check if a secret exists

.PARAMETER Name The secret
.PARAMETER Prefix A prefix for the secret

.EXAMPLE
Test-VaultSecretExists "beneva/ad/perception/dev/ad-perception-sit1/activemqfacade"

.EXAMPLE
Test-VaultSecretExists -Prefix "beneva/ad/perception/dev" "ad-perception-dev1/activemqfacade"
#>
function Test-VaultSecretExists {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position=0)][string] $Name,
    [Parameter()][string] $Prefix
  )
  
  begin {
    Assert-VaultConnected
  }
  process {
    if ($Prefix){ $Name="$Prefix/$Name" }
    try {
      $data=$(vault kv get -non-interactive -mount="secret" -format="json" $Name 2>$null)
      if ($data){ return $true }
      return $false
    }
    catch { return $false }
  }
  end {}
}


Export-ModuleMember -Function `
  'Copy-VaultSecret', 'Assert-VaultConnected', `
  'Test-VaultSecretExists', 'Connect-Vault'


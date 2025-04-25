

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
  try {
    vault kv list -mount=secret -non-interactive "" | Out-Null
    if ($Check){ return $true; }
  } catch {
    if (-not $Silent){
      Write-Error "Vault is not connected. Please run Connect-Vault to authenticate."
    }
    if ($Check){ return $false }
    exit 1
  }
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
  Delete a secret

.PARAMETER Token the vault token to use

.EXAMPLE
  Remove-VaultSecret "example/secret"
  Remove-VaultSecret -Prefix "example" "secret"
#>
function Remove-VaultSecret {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position=0)][string] $Name,
    [Parameter()][string] $Prefix
  )
  
  begin {
    Assert-VaultConnected
  }
  process {
    if ($Prefix){ $Name="$Prefix/$Name".Replace("//", "/"); }
    try {
      vault kv metadata delete -mount="secret" $Name | Out-Null
    }
    catch { Write-Error "Error while trying to delete secret ($Name): $_" }
  }
  end {}
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
  Copy-VaultSecret "team/dev/app/secret_1" "team/dev/app/secret_2"

.EXAMPLE
  Copy-VaultSecret -Prefix "team/dev" "app/secret_1" "app/secret_2"

.EXAMPLE
  Copy-VaultSecret -Delete -Prefix "team/dev" "app/secret_1" "app/secret_2"
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
    
    if($Prefix){ $Source="$Prefix/$Source".Replace("//", "/") }
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
      Remove-VaultSecret $Source
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
  Test-VaultSecretExists "team/dev/app/secret_name"

.EXAMPLE
  Test-VaultSecretExists -Prefix "team/dev" "app/secret_name"
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
    if ($Prefix){ $Name="$Prefix/$Name".Replace("//", "/"); }
    try {
      $data=$(vault kv get -non-interactive -mount="secret" -format="json" $Name 2>$null)
      if ($data){ return $true }
      return $false
    }
    catch { return $false }
  }
  end {}
}

<#
.SYNOPSIS

.DESCRIPTION
  Lists all secrets in a path

.PARAMETER Prefix A prefix for the secrets to list
.PARAMETER Silent Do not write anything to console

.EXAMPLE
  Find-VaultSecrets "team/dev/app/secret_name"

.EXAMPLE
  Find-VaultSecrets  "team/dev/app/secret_name" -Silent

.OUTPUTS
  [string[]] The list of secrets found
#>
function Find-VaultSecrets {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$false, Position=0)][string] $Prefix="",
    [Parameter()][switch] $Silent=$false
  )
  
  begin {
    Assert-VaultConnected
  }
  process {
    try {
      $results=(vault kv list -non-interactive -mount="secret" -format="json" $Prefix  2>&1  | ConvertFrom-Json)
    }
    catch {
      if (-not $Silent){
        Write-Error "Error while trying to list secrets at ($Prefix)"
      }
      return @()
    }
    
    if ($null -eq $results){ return @(); }
    elseif ($results -is [System.String]){ $results=@($results); }
    
    $newResults=@()
    $i=0
    foreach ($item in $results | ForEach-Object { "$_" } | Where-Object { $_ -ne "" }) {
      $i++
      $current="$Prefix/$item".Replace("//", "/")
      Write-Debug " * $current"

      if (-not $Silent){
        Write-Progress -Activity "Listing Secrets" `
          -Status "$i/$($results.Count) - ($($newResults.Count) found)" `
          -PercentComplete (($i / $results.Count) * 100) `
          -CurrentOperation "$current"
      }

      if ($current.endswith("/")) {
        try { 
          $subResults=$(Find-VaultSecrets -ErrorAction SilentlyContinue $current -Silent)
          $newResults+=$subResults;
        }
        catch { $newResults+=@() }
      }
      else {
        $newResults+=@($current)
      }
    }
    return $newResults
  }
}


Export-ModuleMember -Function `
  'Copy-VaultSecret', 'Assert-VaultConnected', `
  'Test-VaultSecretExists', 'Connect-Vault', `
  'Remove-VaultSecret', 'Find-VaultSecrets'





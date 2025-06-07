function Import-AzureStorage{
  param(
    [Parameter(Mandatory)][string]$name,
    [string]$ress,
    [string]$location,
    [string]$sku,
    [string]$kind,
    [string]$tier, # [--access-tier {Cool, Hot}]
    [string]$path,
    [string]$pathCerts,

    [switch]$create,
    [switch]$delete,
    [switch]$secure
  )

  $AZ_STORAGE = az storage account list | ConvertFrom-Json  | foreach-object { $_ } |
    Where-Object  {$_.name -match $name }

  if(($create) -and (!($AZ_STORAGE))){
    if(!($ress)){ $ress = $name }
    if(!($location)){ $location = "eastus" }
    if(!($sku)){ $sku = "Standard_LRS" }
    if(!($tier)){ $tier = "Cool" }
    if(!($kind)){ $kind = "StorageV2" } # [--kind {BlobStorage, Storage, StorageV2}]

    Write-Host "Setting up Ressource Group..." -NoNewLine
    $AZ_STORAGE_RESS = az group list  | ConvertFrom-Json  | foreach-object { $_ } | Where-Object  {$_.name -match $ress }
    if(!($AZ_STORAGE_RESS)){
      $AZ_STORAGE_RESS = (az group create --name $ress --location $location) | ConvertFrom-Json
    }

    Write-Host "Done" -ForegroundColor DarkGreen

    Write-Host "Setting up storage account..."
    if($secure){
      $AZ_STORAGE = ((az storage account create -n $name -g $ress -l $location --sku $sku `
        --https-only true --default-action Deny) | ConvertFrom-Json)
    } else {
      $AZ_STORAGE = ((az storage account create -n $name -g $ress -l $location --sku $sku `
        --https-only false --default-action Allow) | ConvertFrom-Json)
    }
    Write-Host "Done" -ForegroundColor DarkGreen

      #[--assign-identity][--bypass {AzureServices, Logging, Metrics, None}]
      #[--encryption-services {blob, file, queue, table}][--custom-domain]


    $AZ_STORAGE = az storage account list | ConvertFrom-Json  | foreach-object { $_ } |
      Where-Object  {$_.name -match $name }
  }

  Add-Member -InputObject $AZ_STORAGE -MemberType ScriptMethod -Name getKey -Value {
    return (az storage account keys list -n $this.name -g $this.resourceGroup | ConvertFrom-Json | Where-Object  {$_.permissions -match "Full"})[0]
  }
  Add-Member -InputObject $AZ_STORAGE -MemberType ScriptMethod -Name getSas -Value {
    az storage account generate-sas --expiry
  }
  Add-Member -InputObject $AZ_STORAGE -MemberType ScriptMethod -Name netRules -Value {
    az storage account network-rule list -n $AZ_STORAGE.name -g $AZ_STORAGE.resourceGroup
    az storage cors list --account-name $AZ_STORAGE.name --account-key $AZ_STORAGE.getKey().value
  }

  return $AZ_STORAGE
}

function Import-AzureContainer{
  param(
    [Parameter(Mandatory)][string]$name,
    [Parameter(Mandatory)][Object]$account,
    [switch]$create,
    [switch]$delete
  )

  $key = $account.getKey()
  $AZ_CONTAINER = (az storage container list --account-name $account.name --account-key $key.value  | ConvertFrom-Json |
    foreach-object { $_ } | Where-Object  {$_.name -match $name })

  if(($create) -and (!($AZ_CONTAINER))){
    az storage container create -n $name --account-name $account.name --account-key $key.value --fail-on-exist
  } elseif (($delete) -and ($AZ_CONTAINER)){
    az storage container delete -n $name --account-name $account.name --account-key $key.value
  }

 $AZ_CONTAINER = (az storage container list --account-name $account.name --account-key $key.value  | ConvertFrom-Json |
    foreach-object { $_ } | Where-Object  {$_.name -match $name })

  return $AZ_CONTAINER
}

function Import-AzureShare{
  param(
    [Parameter(Mandatory)][string]$name,
    [Parameter(Mandatory)][Object]$account,
    [switch]$create,
    [switch]$delete
  )

  $key = $account.getKey()
  $AZ_SHARE = (az storage share list --account-name $account.name --account-key $key.value  | ConvertFrom-Json |
    foreach-object { $_ } | Where-Object  {$_.name -match $name })

  if(($create) -and (!($AZ_SHARE))){
    az storage share create -n $name --account-name $account.name --account-key $key.value --fail-on-exist
  } elseif (($delete) -and ($AZ_SHARE)){
    az storage share delete -n $name --account-name $account.name --account-key $key.value
  }

 $AZ_SHARE = (az storage share list --account-name $account.name --account-key $key.value  | ConvertFrom-Json |
    foreach-object { $_ } | Where-Object  {$_.name -match $name })

  return $AZ_SHARE
}

function Import-AzureQueue{
  param(
    [Parameter(Mandatory)][string]$name,
    [Parameter(Mandatory)][Object]$account,
    [switch]$create,
    [switch]$delete
  )
  $key = $account.getKey()
  $AZ_QUEUE = (az storage queue list --account-name $account.name --account-key $key.value  | ConvertFrom-Json |
    foreach-object { $_ } | Where-Object  {$_.name -match $name })

  if(($create) -and (!($AZ_QUEUE))){
    az storage queue create -n $name --account-name $account.name --account-key $key.value --fail-on-exist
  } elseif (($delete) -and ($AZ_QUEUE)){
    az storage queue delete -n $name --account-name $account.name --account-key $key.value
  }

  $AZ_QUEUE = (az storage queue list --account-name $account.name --account-key $key.value  | ConvertFrom-Json |
     foreach-object { $_ } | Where-Object  {$_.name -match $name })

  return $AZ_QUEUE
}

function Import-AzureTable{
  param(
    [Parameter(Mandatory)][string]$name,
    [Parameter(Mandatory)][Object]$account,
    [switch]$create,
    [switch]$delete
  )
  $key = $account.getKey()
  $AZ_TABLE = (az storage table list --account-name $account.name --account-key $key.value  | ConvertFrom-Json |
    foreach-object { $_ } | Where-Object  {$_.name -match $name })

  if(($create) -and (!($AZ_TABLE))){
    az storage table create -n $name --account-name $account.name --account-key $key.value --fail-on-exist
  } elseif (($delete) -and ($AZ_TABLE)){
    az storage table delete -n $name --account-name $account.name --account-key $key.value
  }

  $AZ_TABLE = (az storage table list --account-name $account.name --account-key $key.value  | ConvertFrom-Json |
     foreach-object { $_ } | Where-Object  {$_.name -match $name })

  return $AZ_TABLE
}
Export-ModuleMember -Function 'Import-*'

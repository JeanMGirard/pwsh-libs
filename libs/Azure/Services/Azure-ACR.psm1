function Import-AzureACR{
  param(
    [Parameter(Mandatory)][string]$name,
    [string]$ress,
    [string]$sku,
    [string]$location,
    [string]$storageAccount,
    [switch]$create,
    [switch]$delete
  )

  # $AZ_ACR = az acr show -n $name -g $ress
  if($create){
    if(!($sku))     { $sku = "Basic" }
    if(!($ress))    { $ress = $name }
    if(!($location)){ $location = "eastus" }

    az acr create -n $name -g $ress --sku $sku --admin-enabled $true --location $location # --storage-account-name $storageAccount
  }
}

Export-ModuleMember -Function 'Import-*'

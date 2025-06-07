
function Import-AzureVNet{
  param(
    [string]$name,
    [switch]$create,
    [switch]$delete,
    [switch]$deleteSub,
    [switch]$getSubnet,
    [Object]$vnet,
    [string]$ress,
    [string]$location,
    [string]$prefix,
    [string]$subnet,
    [string]$subnet_pref,
    [string]$path
  )
  Write-Host "Getting Virtual Network... "
  if(!($vnet)){
    if(!($location)) {$location = "eastus"}
    if(!($ress))     {$ress = $name}
    if(!($prefix))   {$prefix = "10.0.0.0/16"}
    if(!($subnet))   {$subnet = $name}
    if(!($subnet_pref))   {$subnet_pref = "10.0.1.0/24"}

    $AZ_VNET = az network vnet list | ConvertFrom-Json  | foreach-object { $_ } | Where-Object  {$_.name -match $name }
  }
  else {
    $AZ_VNET = $vnet
    $name = $AZ_VNET.name
    $ress = $AZ_VNET.resourceGroup
    $prefix = $AZ_VNET.addressSpace
    $location = $AZ_VNET.location
  }







  [console]::ForegroundColor = "White"

  if(($create) -and (!($AZ_VNET))){



    Write-Host "Setting up Ressource Group..." -NoNewLine
    $AZ_VNET_RESS = az group list  | ConvertFrom-Json  | foreach-object { $_ } | Where-Object  {$_.name -match $ress }
    if(!($AZ_VNET_RESS)){ $AZ_VNET_RESS = ((az group create --name $ress --location $location) | ConvertFrom-Json) }
    Write-Host "Done" -ForegroundColor DarkGreen


    Write-Host "Setting up Virtual Network..." -ForegroundColor Yellow
    #[--ddos-protection {false, true}][--ddos-protection-plan][--dns-servers] [--tags][--vm-protection {false, true}]
    $AZ_VNET = ((az network vnet create --name $name `
                         --resource-group $ress `
                         --address-prefix $prefix `
                         --subnet-name $subnet `
                         --subnet-prefix $subnet_pref `
                         --location $location) | ConvertFrom-Json )

    $AZ_VNET = az network vnet list | ConvertFrom-Json  | foreach-object { $_ } |
      Where-Object  {$_.name -match $name }

    if($path){
      $AZ_VNET | ConvertTo-Json | Set-Content (Join-Path -path $path -ChildPath (-join($name, ".json")))
    }

    $AZ_SNET = az network vnet subnet list -g $ress --vnet-name $name | ConvertFrom-Json | foreach-object { $_ } | Where-Object  {$_.name -match $subnet }

    Write-Host "Done" -ForegroundColor DarkGreen
  }

  elseif(($create) -and (!($AZ_SNET))){

    Write-Host "Setting up Subnet..." -NoNewLine

    $AZ_SNET = ((az network vnet subnet create `
        --vnet-name $name `
        --resource-group $ress `
        --name $subnet `
        --address-prefix $subnet_pref)  | ConvertFrom-Json)

    $AZ_SNET = az network vnet subnet list --resource-group $ress --vnet-name $name |
        ConvertFrom-Json | foreach-object { $_ } | Where-Object  {$_.name -match $subnet }

    Write-Host "Done" -ForegroundColor DarkGreen
  }

  if(($delete) -and ($AZ_VNET)){
    Write-Host "Deleting network..." -NoNewLine
    az group delete --name $ress --yes --no-wait
    Write-Host "Done" -ForegroundColor DarkGreen
    return $null
  }
  elseif(($deleteSub) -and ($AZ_SNET)){
    Write-Host "Deleting subnet..." -NoNewLine
    az network vnet subnet delete --vnet-name $AZ_VNET.name --resource-group $AZ_VNET.resourceGroup --name $AZ_SNET.name  --no-wait --yes
    $AZ_SNET = $null
    Write-Host "Done" -ForegroundColor DarkGreen
  }

  if($getSubnet){
    if($AZ_SNET){
      Add-Member -InputObject $AZ_SNET -MemberType NoteProperty -Name vnetName -Value $AZ_VNET.name
      Add-Member -InputObject $AZ_SNET -MemberType NoteProperty -Name vnetResGroup -Value $AZ_VNET.resourceGroup
      Add-Member -InputObject $AZ_SNET -MemberType ScriptMethod -Name delete -Value {
        az network vnet subnet delete --vnet-name $this.vnetName --resource-group $this.vnetResGroup --name $this.name --yes
      }
    }
    return $AZ_SNET
  }
  return $AZ_VNET


}

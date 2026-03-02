

function Import-AzureIP{
  param(
    [string]$name,
    [string]$ress,
    [string]$dnsName,
    [string]$revFQDN,
    [string]$location,
    [string]$sku,
    [switch]$ipv4,
    [switch]$ipv6,
    [switch]$static,
    [switch]$create,
    [switch]$delete
  )
  if(!($ress)){ $ress = $name }

  $AZ_IP = az network public-ip list | ConvertFrom-Json  | foreach-object { $_ } |
    Where-Object  {$_.name = $name }


  if(($create) -and (!($AZ_IP))){
    if(!($location)){ $location = "eastus" }
    if(!($sku)){ $sku = "Basic" }
    if((!($ipv4)) -and (!($ipv6))){
      $ipv4 = $true
    }
    if($static){ $allocMeth = "Static"
    } else { $allocMeth = "Dynamic" }

    $AZ_IP_RESS = az group list  | ConvertFrom-Json | foreach-object { $_ } | Where-Object  {$_.name -match $ress }
    if(!($AZ_IP_RESS)){ $AZ_IP_RESS = (az group create --name $ress --location $location) | ConvertFrom-Json    }

    if($ipv4){
      $ip4 = (az network public-ip create -g $ress -n $name -l $location --sku $sku --allocation-method $allocMeth --version IPv4 )  | ConvertFrom-Json
    } elseif($ipv6){
      $ip6 = (az network public-ip create -g $ress -n $name -l $location --sku $sku --allocation-method $allocMeth --version IPv6 )
    }
    if($dnsName){ az network public-ip update -g $ress -n $name --dns-name $dnsName }
    if($revFQDN){ az network public-ip update -g $ress -n $name --reverse-fqdn $revFQDN }


  } elseif(($delete) -and ($AZ_IP)){
    az network public-ip delete -n $name -g $ress
  }

  $AZ_IP = (az network public-ip list | ConvertFrom-Json  | foreach-object { $_ } |
    Where-Object  {$_.name -match $name })

  return $AZ_IP
}


function Import-AzureNSG{
  param(
    [string]$name,
    [string]$ress,
    [string]$location,
    [switch]$create,
    [switch]$delete
  )
  if(!($ress)){ $ress = $name }

  $AZ_NSG = az network nsg list   | ConvertFrom-Json  | foreach-object { $_ } | Where-Object  {$_.name -match $name }
  if(($create) -and (!($AZ_NSG))){

    if(!($location)){ $location = "eastus" }

    $AZ_NSG_RESS = az group list  | ConvertFrom-Json  | foreach-object { $_ } | Where-Object  {$_.name -match $ress }
    if(!($AZ_NSG_RESS)){ $AZ_NSG_RESS = (az group create --name $ress --location $location) | ConvertFrom-Json    }

    $AZ_NSG = (az network nsg create -n $name -g $ress --location $location | ConvertFrom-Json)

  } elseif(($delete) -and ($AZ_IP)){
    az network nsg delete -n $name -g $ress
    $AZ_NSG = $null
  }
  return $AZ_NSG
}
Export-ModuleMember -Function 'Import-*'

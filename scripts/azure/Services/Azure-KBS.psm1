

function Import-AzureKBS{
  param(
    [Parameter(Mandatory)][string]$name,
    [Object]$sp,
    [Object]$subnet,
    [switch]$create,
    #[switch]$helm,
    #[switch]$wait,
    [string]$ress,
    [string]$location,
    [string]$cidr,
    [string]$dns,
    [string]$dnsPrefix,
    [string]$vmSize,
    [int]$vmCount,
    [string]$path,
    [string]$pathCerts
  )
  Write-Host "Getting Kubernetes Cluster"

  $AZ_KBS = az aks list  | ConvertFrom-Json  | foreach-object { $_ } |
    Where-Object  {$_.name -match $name }

  #if($wait){ $wait = "" }
  #else{ $wait = "--no-wait" }

  if(($create) -and (!($AZ_KBS))){

    if(!($location)) {$location = "eastus"}
    if(!($ress))     {$ress = $subnet.resourceGroup}
    if(!($dns))      {$dns = "10.0.0.10"}
    if(!($dnsPrefix)){$dnsPrefix = $name}
    if(!($cidr))     {$cidr = "10.0.0.0/24"}
    if(!($vmSize))   {$vmSize = "Standard_B2s"}
    if(!($vmCount))  {$vmCount = 3}
    $dnsPrefix = ($dnsPrefix.replace("_", "-").toLower())

    Write-Host "Setting up Ressource Group..." -NoNewLine
    $AZ_KBS_RESS = az group list  | ConvertFrom-Json  | foreach-object { $_ } | Where-Object  {$_.name -match $ress }
    if(!($AZ_KBS_RESS)){ $AZ_KBS_RESS = ((az group create --name $ress --location $location) | ConvertFrom-Json)}

    Write-Host "Done" -ForegroundColor DarkGreen

    Write-Host "Setting up Cluster..."
    # Ressource group
    $AZ_KBS = ((az aks create -k "1.11.1"  `
      --name $name `
      --resource-group $ress `
      --service-principal $AZ_SP.appId `
      --client-secret $AZ_SP.Password `
      --location $location `
      --node-vm-size $vmSize `
      --node-count $vmCount `
      --generate-ssh-keys `
      --enable-addons monitoring `
      --network-plugin azure `
      --vnet-subnet-id $subnet.id `
      --docker-bridge-address 172.17.0.1/16 `
      --dns-service-ip $dns `
      --dns-name-prefix $dnsPrefix `
      --service-cidr $cidr) | ConvertFrom-Json)
      # "Standard_DS1_v2"
      # --node-osdisk-size 30 `
      # --pod-cidr 10.7.1.0/16
      # --admin-username $AZ_KBS_ADMIN `
      # --aad-client-app-id $AZ_SP.appId `
      # --aad-tenant-id $AZ_SP.appOwnerTenantId `
      # --aad-server-app-id https://apiserver:443
      # --aad-server-app-secret
      # --no-wait
      #  --enable-rbac `

      $AZ_KBS = az aks list  | ConvertFrom-Json  | foreach-object { $_ } |
        Where-Object  {$_.name -match $name }

      if($path){
        ($AZ_KBS) | ConvertTo-json | Set-Content (Join-Path -path $path -ChildPath (-join($AZ_KBS.name, ".json")))
      }

      az aks get-credentials --resource-group $AZ_KBS.resourceGroup --name $AZ_KBS.name
      kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
      Write-Host "Done" -ForegroundColor DarkGreen

    }

    if($AZ_KBS){
      Add-Member -InputObject $AZ_KBS -MemberType ScriptMethod -Name delete -Value {
        az group delete --name $this.resourceGroup --no-wait --yes
        kubectl config delete-context $this.name
        kubectl config delete-cluster $this.name
        #((kubectl config view).users | foreach-object { $_ } |
        #  Where-Object  {$_.user -match (-join('*', $AZ_KBS.name, '*')) }) | foreach-object { kubectl config unset (-join("users.", $_ )) }
        # kubectl config unset users.clusterUser_DmKube_DmKube-01
        $this = $null
      }

      Add-Member -InputObject $AZ_KBS -MemberType ScriptMethod -Name dashboard -Value {
        az aks browse --name $this.name -g $this.resourceGroup
      }

      Add-Member  -in $AZ_KBS ScriptMethod -Name enable -Value  {
        param( [switch]$httpRouting, [switch]$dashboard , [switch]$helm )
        if($httpRouting){  az aks enable-addons --addons http_application_routing -n $this.name -g $this.resourceGroup  }
        if($dashboard)  {  az aks enable-addons --addons monitoring -n $this.name -g $this.resourceGroup  }
        if($helm)       {
          kubectl create serviceaccount --namespace kube-system tiller
          kubectl create clusterrolebinding tiller-cluster-role --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
          helm init --service-account tiller
        }
      }
      Add-Member  -in $AZ_KBS ScriptMethod -Name disable -Value  {
        param([switch]$httpRouting, [switch]$dashboard, [switch]$helm)
        if($httpRouting){  az aks disable-addons --addons http_application_routing -n $this.name -g $this.resourceGroup  }
        if($dashboard)  {  az aks disable-addons --addons monitoring -n $this.name -g $this.resourceGroup  }
        if($helm)       {
          kubectl delete serviceaccount --namespace kube-system tiller
          kubectl delete clusterrolebinding tiller-cluster-role --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
          # helm init --service-account tiller
        }
      }

      Add-Member  -in $AZ_KBS ScriptMethod -Name refresh -Value  {
        $this = AzureKBS -name $this.name -path $CONFIG_FOLDER -pathCerts $CERTS_FOLDER -ress $this.resourceGroup
      }
    }
    return $AZ_KBS
  }
Export-ModuleMember -Function 'Import-*'

## Prerequisites
# * A [Microsoft Azure account](https://azure.microsoft.com/en-us/free/).
# * Install [Minikube](https://storage.googleapis.com/minikube/releases/v0.25.2/minikube-windows-amd64.exe).
# * Install the [Azure CLI](https://aka.ms/InstallAzureCliWindows).
# * Install the [Kubernetes CLI](#install-the-kubernetes-cli).
# * Install the [Helm CLI](https://storage.googleapis.com/kubernetes-helm/helm-v2.7.2-windows-amd64.tar.gz).
# * [Setup Azure](#setup-azure)

az login

$env:AZURE_SUBSCRIPTION_ID = "<SUBSCRIPTION>"
$env:AZURE_TENANT_ID = "<Tenant>"
$env:AZURE_CLIENT_ID = "<AppId>"
$env:AZURE_CLIENT_SECRET = "<Password>"
$env:AZ_RES_GROUP="dimgo-svc"

az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Storage



[console]::ForegroundColor = "White"
Write-Host "Done" -ForegroundColor DarkGreen

Write-Host "Setting up Azure ServicePrincipal"  -ForegroundColor Yellow
$AZ_SP   = AzureSP  -create  -name $AZ_KBS_SP  -path $CONFIG_FOLDER -pathCerts $CERTS_FOLDER

Write-Host "Setting up Azure Storage"  -ForegroundColor Yellow
$AZ_STORAGE   = AzureStorage -create -name $AZ_STORAGE_NAME -ress $AZ_STORAGE_RESS  -path $CONFIG_FOLDER -pathCerts $CERTS_FOLDER
$AZ_CONTAINER = AzureContainer -name $AZ_CONTAINER_NAME -account $AZ_STORAGE -create
$AZ_SHARE     = AzureShare     -name $AZ_SHARE_NAME     -account $AZ_STORAGE -create
$AZ_QUEUE     = AzureQueue     -name $AZ_QUEUE_NAME     -account $AZ_STORAGE -create
#$AZ_TABLE     = AzureTable     -name $AZ_QUEUE_NAME     -account $AZ_STORAGE -create

Write-Host "Setting up Azure Virtual Network"  -ForegroundColor Yellow

$AZ_VNET = AzureVNet -name $AZ_VNET_NAME -path $CONFIG_FOLDER -ress $AZ_VNET_RESS -create `
  -subnet $AZ_VNET_SNET -location "eastus" -prefix 10.7.0.0/16 -subnet_pref 10.7.0.0/24
$AZ_SNET_11  = AzureVNet -getSubnet -vnet $AZ_VNET -subnet $AZ_KBS_SNET -create  -subnet_pref 10.7.11.0/24
$AZ_IP = AzureIP -name $AZ_IP_NAME -ress $AZ_KBS_RESS -static -create -dnsName $AZ_IP_DNS


Write-Host "Setting up Azure Kubernetes cluster"  -ForegroundColor Yellow
# $AZ_ACR  = AzureACR -create -name $AZ_ACR_NAME -ress $AZ_ACR_RESS
$AZ_KBS  = (AzureKBS -name $AZ_KBS_CLUSTER -path $CONFIG_FOLDER -pathCerts $CERTS_FOLDER -ress $AZ_KBS_RESS `
   -sp $AZ_SP -subnet $AZ_SNET_11 -create  `
   -cidr 10.7.0.0/24 -dns 10.7.0.10 -dnsPrefix ($AZ_KBS_DOMAIN.Split(".")[0]))
$AZ_KBS.enable(($dashboard=$true), ($helm=$true))
#$AZ_KBS.enable(($httpRouting=$true)
# $AZ_KBS.disable(($httpRouting=$true))


#$AZ_LB = az network lb list
# az storage directory create --account-name $AZ_STORAGE_NAME --account-key ($AZ_STORAGE.getKey()).value --share-name $AZ_SHARE_NAME
# az aks disable-addons --addons http_application_routing --name $AZ_KBS.name --resource-group $AZ_KBS.resourceGroup
function testest{
  Write-Host "Setting up vpn on azure"  -ForegroundColor Yellow
  #$AZ_STORAGE_KEY = $AZ_STORAGE.getKey().value
  #kubectl create secret generic azure-secret --from-literal=azStorageAccount=$AZ_STORAGE_NAME --from-literal=azStorageKey=$AZ_STORAGE_KEY
  $AZ_VPN = KubeOVPN -svc "ovpn" -path "E:\Network\src\openvpn"
  $svc = "ovpn"
  $path = "E:\Network\src\openvpn"
  [console]::ForegroundColor = "White"

  exit


  $svc = "kubevpn"
  $create = $true
  $path = "E:\Network\src\openvpn"
  $pathCerts = $CERTS_FOLDER







  $AZ_SNET_12  = AzureVNet -create -getSubnet -vnet $AZ_VNET -subnet "testing" -subnet_pref 10.7.12.0/24
  $AZ_SNET_13  = AzureVNet -create -getSubnet -vnet $AZ_VNET -subnet "testing2" -subnet_pref 10.7.13.0/24
  $AZ_SNET_14  = AzureVNet -create -getSubnet -vnet $AZ_VNET -subnet "testing3" -subnet_pref 10.7.14.0/24

  $AZ_KBS2  = AzureKBS -create -name "kubetest2" -path $CONFIG_FOLDER -pathCerts $CERTS_FOLDER -ress "kubetest2" `
    -sp $AZ_SP -subnet $AZ_SNET_12 -helm -vmCount 2 `
    -cidr 10.7.0.0/24 -dns 10.7.0.15 -dnsPrefix "testkube2" ; [console]::ForegroundColor = "White"
  $AZ_KBS3  = AzureKBS -create -name "kubetest3" -path $CONFIG_FOLDER -pathCerts $CERTS_FOLDER -ress "kubetest3" `
    -sp $AZ_SP -subnet $AZ_SNET_13 -helm -vmCount 1 `
    -cidr 10.7.0.0/24 -dns 10.7.0.16 -dnsPrefix "testkube3" ; [console]::ForegroundColor = "White"
  $AZ_KBS4  = AzureKBS -create -name "kubetest4" -path $CONFIG_FOLDER -pathCerts $CERTS_FOLDER -ress "kubetest4" `
    -sp $AZ_SP -subnet $AZ_SNET_14 -helm -vmCount 1 `
    -cidr 10.7.0.0/24 -dns 10.7.0.17 -dnsPrefix "testkube4" ; [console]::ForegroundColor = "White"
  # az aks scale --resource-group $AZ_KBS_RESS --name $AZ_KBS_CLUSTER --node-count 1
}

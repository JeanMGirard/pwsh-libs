## Prerequisites
# * A [Microsoft Azure account](https://azure.microsoft.com/en-us/free/).

az login

$env:AZURE_SUBSCRIPTION_ID = "<SUBSCRIPTION>"
$env:AZURE_TENANT_ID = "<Tenant>"
$env:AZURE_CLIENT_ID = "<AppId>"
$env:AZURE_CLIENT_SECRET = "<Password>"

az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Storage


function New-ServicePrincipal-RBAC{
  param(
      [Parameter(Mandatory)]
      [string]$Name
  )

  az ad sp create-for-rbac --name $Name -o table
}

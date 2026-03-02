

function Search-HelmResources {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)][string]$ChartName,
    [Parameter(Mandatory=$false)][string]$Namespace = "default"
  )

  $Labels="app.kubernetes.io/managed-by=Helm"
  $Filter="jsonpath-as-json={.items[?(@.metadata.annotations.meta\.helm\.sh/release-name==`"${ChartName}`")]}"
  $Types=(kubectl api-resources -o name -n $Namespace | Join-String -Separator ',')
  
  Return (kubectl get -n $Namespace -o $Filter -l $Labels $Types --no-headers  2>$null | Out-String | ConvertFrom-Json)
  #  | Select-Object -Property * -ExcludeProperty data
}

function Debug-HelmChart {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)][string]$ChartName,
    [Parameter(Mandatory=$false)][string]$Namespace = "default"
  )
  Write-Host " --- Chart Status --------------------------------------------------- " -ForegroundColor Green
  helm status -n $Namespace $ChartName
  Write-Host " -------------------------------------------------------------------- " -ForegroundColor Green
  Search-HelmResources -ChartName $ChartName -Namespace $Namespace | ForEach-Object {
    $Name = $_.metadata.name
    $Type = $_.kind
    Write-Host " $Type/$Name " -ForegroundColor Yellow
    $Details=(kubectl describe -n $Namespace $Type/$Name 2>$null | Out-String)
    Write-Host "$Details"
  }
  Write-Host " -------------------------------------------------------------------- " -ForegroundColor Green
}



Export-ModuleMember -Function Debug-*
Export-ModuleMember -Function Search-*
Export-ModuleMember -Alias kc-*

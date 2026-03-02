Connect-AzureRmAccount


$myPublisher="Dimgo Technologies"
$myPublisher="Dimgo"
$myPublisher="Innovative.Earth"
$myPublisher="Miradore Ltd"

DeletePublisher "Dimgo"
DeletePublisher "Innovative.Earth"
DeletePublisher "Miradore Ltd"


function Get-PublisherSPs{
  param([Parameter(Mandatory)]
        [string]$Publisher
  )
  az ad sp list | ConvertFrom-Json | Sort-Object -Property publisherName, displayName | `
  foreach-object { $_ } | Where-Object  {$_.publisherName -match $Publisher } | `
    Format-Table -Property publisherName, displayName
    # Format-Table -Property publisherName, displayName -GroupBy publisherName
  }
function Get-PublisherApps{
  param([Parameter(Mandatory)]
        [string]$PublisherDomain
  )
  az ad app list | ConvertFrom-Json | Sort-Object -Property publisherDomain, displayName | `
  foreach-object { $_ } | Where-Object  {$_.publisherDomain -match $PublisherDomain }   | `
    Format-Table -Property publisherDomain, displayName -GroupBy publisherDomain
  }





function Delete-PublisherSPs{
  param([Parameter(Mandatory)]
        [string]$Publisher
  )
  az ad sp list | ConvertFrom-Json | Sort-Object -Property publisherName, displayName | `
  foreach-object { $_ } | Where-Object  {$_.publisherName -match $Publisher }   | `
    ForEach-Object -Process { az ad sp delete --id $_.objectId }
}
function Delete-PublisherApps{
  param([Parameter(Mandatory)]
        [string]$PublisherDomain
  )
  az ad app list | ConvertFrom-Json | Sort-Object -Property publisherDomain, displayName | `
  foreach-object { $_ } | Where-Object  {$_.publisherDomain -match $PublisherDomain }   | `
    ForEach-Object -Process { `
      Set-AzureRmADApplication -ObjectId $_.objectId -AvailableToOtherTenants $false; `
      Remove-AzureRmADApplication -ObjectId $_.objectId `
    }
}


az ad app list | ConvertFrom-Json | `
  Sort-Object -Property publisherDomain, displayName | foreach-object { $_ } | `
  Where-Object  {$_.publisherDomain -match $PublisherDomain }  | `
  Format-Table -Property publisherName, displayName









#

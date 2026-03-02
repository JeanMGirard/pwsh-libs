Function GetAuthToken{
  param(
    [Parameter(Mandatory=$false)]$Name,
    [Parameter(Mandatory=$false)]$Pass,
  )
  Import-Module Azure
  $credential = Get-Credential
  if((!($credential)) -or (!($ExpFolder))){
    return $null
  }

  Connect-AzureAD -Credential $credential
  Connect-MsolService -Credential $credential
  Connect-MicrosoftTeams -Credential $credential
  $tenant = Get-AzureADTenantDetail


  $clientId = "1950a258-227b-4e31-a9cf-717495945fc2"
  $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
  $resourceAppIdURI = "https://graph.microsoft.com"
  $authority = "https://login.microsoftonline.com/$TenantName"
  $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
  $Credential = Get-Credential
  $AADCredential = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserCredential" -ArgumentList $credential.UserName,$credential.Password
  $authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId,$AADCredential)
  return $authResult
}

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)][switch]$Unread = $false,
    [Parameter(Mandatory = $false)][switch]$SenderOnly = $false,
    [Parameter(Mandatory = $false)][switch]$Distinct = $false,
    [Parameter(Mandatory = $false)][string]$Output = $null,
    [Parameter(Mandatory = $false)][int]$StartAt = 0
)


# Define required variables
# $tenantId = "YOUR_TENANT_ID"
# $clientId = "YOUR_CLIENT_ID"
# $clientSecret = "YOUR_CLIENT_SECRET"
# $accessTokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
# $graphApiUrl = "https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messages"

$graphApiUrl = "https://graph.microsoft.com/v1.0/me/messages"
$paramFilter = ""
$outFile = "$(Get-Location)/${Output}"



if ($Unread) { $paramFilter = "isRead eq false"; }
if ($Output -and (Test-Path -Path "${outFile}.temp" -PathType Leaf)) {
  Remove-Item -Path "${outFile}.temp" -Force
}


# Get unread emails
$headers = @{
    Authorization = "Bearer $env:MSGRAPH_ACCESS_TOKEN"
}

function Format-Email {
    param (
        [Parameter(Mandatory = $true)][object]$email
    )

    if ($SenderOnly) {
        return $email.sender.emailAddress.address
    } else {
        return $email | Select-Object `
            id, `
            subject, `
            receivedDateTime, `
            sender, `
            from, `
            toRecipients, `
            ccRecipients, `
            bccRecipients, `
            isRead, `
            importance, `
            bodyPreview
    }
}

$i=0
$nextLink = "${graphApiUrl}?filter=${paramFilter}&skip=${StartAt}&top=200"
# Write-Host "$nextLink"
while ($nextLink) {
  $response=Invoke-RestMethod -Method Get -Uri "${nextLink}" -Headers $headers
  $nextLink = $response.'@odata.nextLink'
  # List sender email addresses
  foreach ($email in $response.value) {
    $entry = Format-Email -email $email
    Write-Output $entry

    if ($Output) {
      Write-Output $entry >> "${outFile}.temp"  
      # | ConvertTo-Json -Compress   -Path -NoTypeInformation -Append
    } else {
      Write-Output $entry
    }
  }
  $i++
  if ($i -gt 1000) { break; }
}


if ($Output){
  Start-Sleep -Seconds 1

  if ($Distinct) {
    # If Distinct is true, filter out duplicates
    [IO.File]::WriteAllLines("${outFile}",
      [Linq.Enumerable]::Distinct([IO.File]::ReadLines("${outFile}.temp"))
    )
  } else {
    [IO.File]::WriteAllLines("${outFile}", [IO.File]::ReadLines("${outFile}.temp"))
  }
  Remove-Item -Path "${outFile}.temp" -Force
}

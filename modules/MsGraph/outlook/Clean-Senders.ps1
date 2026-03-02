[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)][switch]$CreateRule = $false,
    [Parameter(Mandatory = $false)][string]$MoveTo=$null,
    [Parameter(Mandatory = $false)][switch]$MarkAsRead = $false,
    [Parameter(Mandatory = $true)][string]$FilePath
)


# Get unread emails
$headers = @{
    Authorization = "Bearer $accessToken"
    "Content-Type" = "application/json"
}


$graphApiUrl = "https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messages"
$graphApiUrlRules = "https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messageRules"
$destinationFolderId = "$MoveTo"
$emailAddresses = Get-Content "$FilePath" 


if(-not $CreateRule){
  $i=0
  $nextLink = "${graphApiUrl}?filter=${paramFilter}&top=200"
  # Write-Host "$nextLink"
  while ($nextLink) {
    $response=Invoke-RestMethod -Method Get -Uri "${nextLink}" -Headers $headers
    $nextLink = $response.'@odata.nextLink'

    foreach ($email in $response.value) {
      if (-not ($email.sender.emailAddress.address -in $emailAddresses)){
        continue
      }

      if($MoveTo){
        # Move email to the target folder
        $moveBody = @{ destinationId = $destinationFolderId }
        Invoke-RestMethod -Method Post -Uri "$graphApiUrl/$($email.id)/move" -Headers $headers -Body ($moveBody | ConvertTo-Json)
      }

      if ($MarkAsRead) {
        # Mark email as read
        $updateBody = @{ isRead = $true }
        Invoke-RestMethod -Method Patch -Uri "$graphApiUrl/$($email.id)" -Headers $headers -Body ($updateBody | ConvertTo-Json)
      }
    }
    $i++
    if ($i -gt 1000) { break; }
  }
} else {

  # Create a rule to move emails from specified senders
  $actions = @{}
  if ($MoveTo) { $actions.moveToFolder = $destinationFolderId; }
  if ($MarkAsRead) { $actions.markAsRead = $true }

  $ruleBody = @{
      displayName = "${destinationFolderId} - Senders"
      conditions = @{
          senderContains = $emailAddresses
      }
      actions = $actions
      isEnabled = $true
  }

  Invoke-RestMethod -Method Post -Uri $graphApiUrlRules -Headers $headers -Body ($ruleBody | ConvertTo-Json -Depth 3)
}








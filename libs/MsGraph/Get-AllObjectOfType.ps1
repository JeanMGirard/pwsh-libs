Function Get-Graph-AllObjectOfType
    {
    param
        (
        [Parameter(Mandatory=$true)]
        $Tenant,
        [Parameter(Mandatory=$true)]
        $Type,
        [Parameter(Mandatory=$false)]
        $BatchSize,
        [Parameter(Mandatory=$false)]
        $Version
        )
  
    if($BatchSize -eq $null) {$BatchSize=100}
    if($Version -eq $null) {$Version='Beta'}
    #------Get the authorization token------#
    $token = GetAuthToken -TenantName $tenant 
  
    #------Building Rest Api header with authorization token------#
    $authHeader = @{
        'Content-Type'='application\json'
        'Authorization'=$token.CreateAuthorizationHeader()
        }

    #------Initial URI Construction------#
    $uri = "https://graph.microsoft.com/$Version/$type`?top=$BatchSize"
    $ObjCapture= @()
    do{
        $users = Invoke-RestMethod -Uri $uri –Headers $authHeader –Method Get
        $FoundUsers = ($Users.value).count
        write-host "URI" $uri " | Found:" $FoundUsers
        #------Batched URI Construction------#
        $uri = $users.'@odata.nextlink'
        $ObjCapture = $ObjCapture + $users.value
       
    }until ($uri -eq $null)
    $ObjCapture
}
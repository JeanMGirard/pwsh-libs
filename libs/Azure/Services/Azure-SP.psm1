


function Import-AzureSP{
  param(
      [Parameter(Mandatory)][string]$name,
      [switch]$create,
      [switch]$passOnly,
      [switch]$certOnly,
      [switch]$delete,
      [string]$path,
      [string]$pathCerts
  )
  Write-Host "Getting ServicePrincipal... " -NoNewLine
  ## Prerun verifications
  if(($passOnly) -and ($certOnly)){
    Write-Host "-CertOnly and -PassOnly cannot be set together, exiting.." ; exit
  }
  if(($path) -and ($pathCerts)){
    $path_conf  = (Join-Path -Path $path -ChildPath (-join($name, ".json")))
    $path_cert  = (Join-Path -Path $pathCerts -ChildPath (-join($name, ".cer" )))
    $path_pem   = (Join-Path -Path $pathCerts -ChildPath (-join($name, ".pem")))
    $path_pubkey = (Join-Path -Path $pathCerts -ChildPath (-join($name, ".pub")))
  }
  elseif($path){
    $path_conf  = (Join-Path -Path $path -ChildPath (-join($name, ".json")))
    $path_cert  = (Join-Path -Path $path -ChildPath (-join($name, ".cer" )))
    $path_pem   = (Join-Path -Path $path -ChildPath (-join($name, ".pem")))
    $path_pubkey = (Join-Path -Path $path -ChildPath (-join($name, ".pub")))
  }


  ## Check exists..
  $AZ_SP = (az ad sp list | ConvertFrom-Json  | foreach-object { $_ } | Where-Object  {$_.appDisplayName -match $name })

  if(($create) -and (!($AZ_SP))){
    Write-Host "`n Creating ServicePrincipal... "
    if((!($passOnly)) -and (!($certOnly))){
      $AZ_SP  = ((az ad sp create-for-rbac --name $name --role contributor)       | ConvertFrom-Json)
      $AZ_SP2 = ((az ad sp credential reset --name $name --append --create-cert)  | ConvertFrom-Json)
      Add-Member -InputObject $AZ_SP -MemberType NoteProperty -Name fileWithCertAndPrivateKey -Value $AZ_SP2.fileWithCertAndPrivateKey
    }
    elseif($passOnly){
      $AZ_SP  = ((az ad sp create-for-rbac --name $name --role contributor)       | ConvertFrom-Json)
    }
    elseif($certOnly){
      $AZ_SP = ((az ad sp create-for-rbac reset --name $name --create-cert)  | ConvertFrom-Json)
    }

    if($path){
      $AZ_SP | ConvertTo-json | Set-Content $path_conf
    }

    $AZ_SP = (az ad sp list | ConvertFrom-Json  | foreach-object { $_ } | Where-Object  {$_.appDisplayName -match $name })
  }

  if($AZ_SP){

    Add-Member -InputObject $AZ_SP -MemberType NoteProperty -Name Username -Value $name
    Add-Member -InputObject $AZ_SP -MemberType NoteProperty -Name Password -Value ""
    Add-Member -InputObject $AZ_SP -MemberType NoteProperty -Name CertFile -Value ""
    Add-Member -InputObject $AZ_SP -MemberType NoteProperty -Name PubkeyFile -Value ""

    if($path){
      $AZ_SP.Password = (Get-Content -Path $path_conf -Raw | ConvertFrom-Json | Select password).password
      $AZ_SP.CertFile = (Get-Content -Path $path_conf -Raw | ConvertFrom-Json | Select fileWithCertAndPrivateKey).fileWithCertAndPrivateKey

      if (Test-Path $AZ_SP.CertFile){
          openssl x509 -in $AZ_SP.CertFile -out $path_cert -trustout
          Move-Item -Path $AZ_SP.CertFile -Destination $path_pem -Force
      }
      $AZ_SP.CertFile = $path_cert
      $AZ_SP.PubkeyFile = $path_pubkey

      if (!(Test-Path $path_pubkey)){
        openssl x509 -in $path_cert -noout -pubkey | Set-Content $path_pubkey
      }
    }

    Add-Member -InputObject $AZ_SP -MemberType ScriptMethod -Name Login -Value `
      { az login --service-principal -u $AZ_SP.homepage -p $AZ_SP.Password }

    if(($delete) -and ($AZ_SP)){
      Write-Host "`r Deleting ServicePrincipal..."
      az ad sp delete --id $AZ_SP.appId

      if($path){
        Remove-Item -Path $path_conf -Force
        Remove-Item -Path $path_pem -Force
        Remove-Item -Path $path_cert -Force
        Remove-Item -Path $path_pubkey -Force
      }

      $AZ_SP = $null
    }

    Write-Host "Done" -ForegroundColor DarkGreen

  }

  Write-Host "Done" -ForegroundColor DarkGreen
  return $AZ_SP
}
Export-ModuleMember -Function 'Import-*'

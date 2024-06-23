
$winget_config = Join-Path -Path $(Split-Path "$PSScriptRoot") -ChildPath "\config\winget.json"
$choco_config  = Join-Path -Path $(Split-Path "$PSScriptRoot") -ChildPath "\config\choco.config"
$az_config     = Join-Path -Path $(Split-Path "$PSScriptRoot") -ChildPath "\config\az.config"

function Save-Winget{ 
  $res = Read-Host "Save winget packages to $winget_config ? [y/n]";
  if ($res -eq 'y') { 
    winget export -o $winget_config; 
  }
}
function Save-Choco  { 
  $res = Read-Host "Save choco packages to $choco_config ? [y/n]";
  if ($res -eq 'y') { 
    choco export -o $choco_config; 
  }
}
function Save-AzExtensions  {
  az extension list-available --output table
  az list > $az_config
}


<#
	Creates a new instance of a PackageSource object
#>
function New-PackageSource {
	param(
		[Parameter(Mandatory=$true)][string] $name,
		[Parameter(Mandatory=$true)][string] $location,
		[Parameter(Mandatory=$true)][bool] $trusted,
		[Parameter(Mandatory=$true)][bool] $registered,
		[bool] $valid = $false,
		[System.Collections.Hashtable] $details = $null
	)

	return New-Object -TypeName Microsoft.PackageManagement.MetaProvider.PowerShell.PackageSource -ArgumentList $name,$location,$trusted,$registered,$valid,$details
}

<#
	Creates a new instance of a SoftwareIdentity object
#>
function New-SoftwareIdentity {
	param(
		[Parameter(Mandatory=$true)][string] $fastPackageReference,
		[Parameter(Mandatory=$true)][string] $name,
		[Parameter(Mandatory=$true)][string] $version,
		[Parameter(Mandatory=$true)][string] $versionScheme,
		[Parameter(Mandatory=$true)][string] $source,
		[string] $summary,
		[string] $searchKey = $null,
		[string] $fullPath = $null,
		[string] $filename = $null,
		[System.Collections.Hashtable] $details = $null,
		[System.Collections.ArrayList] $entities = $null,
		[System.Collections.ArrayList] $links = $null,
		[bool] $fromTrustedSource = $false,
		[System.Collections.ArrayList] $dependencies = $null,
		[string] $tagId = $null,
		[string] $culture = $null,
        [string] $destination = $null
	)
	return New-Object -TypeName Microsoft.PackageManagement.MetaProvider.PowerShell.SoftwareIdentity -ArgumentList $fastPackageReference, $name, $version,  $versionScheme,  $source,  $summary,  $searchKey, $fullPath, $filename , $details , $entities, $links, $fromTrustedSource, $dependencies, $tagId, $culture, $destination
}

<#
	Creates a new instance of a SoftwareIdentity object based on an xml string
#>
function New-SoftwareIdentityFromXml {
    param(
        [Parameter(Mandatory=$true)][string] $xmlSwidtag,
        [bool] $commitImmediately = $false
    )

    return New-Object -TypeName Microsoft.PackageManagement.MetaProvider.PowerShell.SoftwareIdentity -ArgumentList $xmlSwidtag, $commitImmediately
}

<#
	Creates a new instance of a DyamicOption object
#>
function New-DynamicOption {
	param(
		[Parameter(Mandatory=$true)][Microsoft.PackageManagement.MetaProvider.PowerShell.OptionCategory] $category,
		[Parameter(Mandatory=$true)][string] $name,
		[Parameter(Mandatory=$true)][Microsoft.PackageManagement.MetaProvider.PowerShell.OptionType] $expectedType,
		[Parameter(Mandatory=$true)][bool] $isRequired,
		[System.Collections.ArrayList] $permittedValues = $null
	)

	if( -not $permittedValues ) {
		return New-Object -TypeName Microsoft.PackageManagement.MetaProvider.PowerShell.DynamicOption -ArgumentList $category,$name,  $expectedType, $isRequired
	}
	return New-Object -TypeName Microsoft.PackageManagement.MetaProvider.PowerShell.DynamicOption -ArgumentList $category,$name,  $expectedType, $isRequired, $permittedValues.ToArray()
}

<#
	Creates a new instance of a Feature object
#>
function New-Feature {
	param(
		[Parameter(Mandatory=$true)][string] $name,
		[System.Collections.ArrayList] $values = $null
	)

	if( -not $values ) {
		return New-Object -TypeName Microsoft.PackageManagement.MetaProvider.PowerShell.Feature -ArgumentList $name
	}
	return New-Object -TypeName Microsoft.PackageManagement.MetaProvider.PowerShell.Feature -ArgumentList $name, $values.ToArray()
}

<#
	Duplicates the $request object and overrides the client-supplied data with the specified values.
#>
function New-Request {
	param(
		[System.Collections.Hashtable] $options = $null,
		[System.Collections.ArrayList] $sources = $null,
		[PSCredential] $credential = $null
	)

	return $request.CloneRequest( $options, $sources, $credential )
}

function New-Entity {
	param(
		[Parameter(Mandatory=$true)][string] $name,
		[Parameter(Mandatory=$true,ParameterSetName="role")][string] $role,
		[Parameter(Mandatory=$true,ParameterSetName="roles")][System.Collections.ArrayList]$roles,
        [string] $regId = $null,
        [string] $thumbprint= $null
	)

	$o = New-Object -TypeName Microsoft.PackageManagement.MetaProvider.PowerShell.Entity
	$o.Name = $name

	# support role as a NMTOKENS string or an array of strings
	if( $role ) {
		$o.Role = $role
	} 
	if( $roles )  {
		$o.Roles = $roles
	}

	$o.regId = $regId
	$o.thumbprint = $thumbprint
	return $o
}

function New-Link {
	param(
		[Parameter(Mandatory=$true)][string] $HRef,
		[Parameter(Mandatory=$true)][string] $relationship,
		[string] $mediaType = $null,
		[string] $ownership = $null,
		[string] $use= $null,
		[string] $appliesToMedia= $null,
		[string] $artifact = $null
	)

	$o = New-Object -TypeName Microsoft.PackageManagement.MetaProvider.PowerShell.Link

	$o.HRef = $HRef
	$o.Relationship =$relationship
	$o.MediaType =$mediaType
	$o.Ownership =$ownership
	$o.Use = $use
	$o.AppliesToMedia = $appliesToMedia
	$o.Artifact = $artifact

	return $o
}

function New-Dependency {
	param(
		[Parameter(Mandatory=$true)][string] $providerName,
		[Parameter(Mandatory=$true)][string] $packageName,
		[string] $version= $null,
		[string] $source = $null,
		[string] $appliesTo = $null
	)

	$o = New-Object -TypeName Microsoft.PackageManagement.MetaProvider.PowerShell.Dependency

	$o.ProviderName = $providerName
	$o.PackageName =$packageName
	$o.Version =$version
	$o.Source =$source
	$o.AppliesTo = $appliesTo

	return $o
}

Export-ModuleMember -Function Save-*, New-*


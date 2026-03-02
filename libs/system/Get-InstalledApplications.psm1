#requires -version 2

Function Get-InstalledApplications
{
<#
 	.SYNOPSIS
        Gets the installed applications on a local or remote computer.
    .DESCRIPTION
        The Get-InstalledApplications cmdlet gets installed application on local or remote computer.
    .PARAMETER  -ComputerName <String[]>
		Gets the installed applications on the specified computers. 
		
		Required?                    false
		Position?                    named
		Default value                Local computer
		Accept pipeline input?       true (ByValue)
		Accept wildcard characters?  false
		
    .PARAMETER  -ComputerFilePath	
		Specifies the path to the CSV file. This file should contain "Name" column with one or more computers. 
		
		Required?                    true
		Position?                    named
		Default value                none
		Accept pipeline input?       false
		Accept wildcard characters?  false
	.INPUTS
		System.String
		
		You can pipe a computer name to Get-InstalledApplication
    .EXAMPLE
        C:\PS> Get-InstalledApplications 
		
		This command retrieves installed applications on the local system.
	.EXAMPLE
        C:\PS> Get-InstalledApplications -ComputerName "Server01","Server02"
		
		This command retrieves installed applications on Server01 and Server02.
    .EXAMPLE
        C:\PS> Get-InstalledApplications -ComputerFilePath C:\ComputerList.csv
		
		This command loads computers names from file C:\ComputerList.csv and retrieves installed applications.
    .EXAMPLE
        C:\PS> Get-InstalledApplications -ComputerName "Server01" | Export-Csv -Path C:\installedApplication.csv
		
		This command retrieves installed applications on Server01 and saves the strings to a CSV file.
#>
    [CmdletBinding(DefaultParameterSetName='SinglePoint')]
    Param
    (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, ParameterSetName="SinglePoint")]
        [Alias('CName')]		
		[String[]]
		$ComputerName=$env:computername,
		
        [Parameter(Mandatory=$true, ParameterSetName="MultiplePoint")]
		[Alias('CNPath')]	
		[String]
		$ComputerFilePath=""
    )
	If($ComputerFilePath.Length -gt 0)
	{
		If(Test-Path $ComputerFilePath)
		{
			try
			{
				$ComputerName = Import-Csv -Path $ComputerFilePath -ErrorAction Stop |select -expand Name
			}
			catch
			{
				Write-Error "Cannot import $ComputerFilePath. Error:$_"
			}        
		}
	}
    If($ComputerName)
    {
        Foreach($CN in $ComputerName)
        {
            If(Test-Connection -ComputerName $CN -Count 1 -Quiet)
            {				
                FindInstalledApplicationInfo -ComputerName $CN
            }
            Else
            {
                Write-Warning "$($CN): Failed to connect"
            }
        }
    }
	
}

Function FindInstalledApplicationInfo($ComputerName)
{
	GetRegistryApplicationInfo -ComputerName $ComputerName -RegKey "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | ?{$_ -is [PSCustomObject]} 
	if(Is64bit -ComputerName $ComputerName)
	{
		GetRegistryApplicationInfo -ComputerName $ComputerName -RegKey "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | ?{$_ -is [PSCustomObject]}
	}     
}
Function GetRegistryApplicationInfo($ComputerName,$RegKey)
{
	$HKLM=2147483650	
    try
	{	
		$stdregprov=gwmi StdRegProv -List -namespace root\default -ComputerName $ComputerName
		try
		{
			foreach ($key in ($stdregprov.EnumKey($HKLM,$RegKey).sNames -split ","))
			{
				try
				{
					$vals=$stdregprov.EnumValues($HKLM,"$RegKey\$key")
					$Obj=$null					
					for ($i=0;$i -lt @($vals.sNames).count;$i++)				
					{
						$valname=$vals.sNames[$i]						
						if($valname -ne "")
						{
							try
							{
								$val=$null				
								switch ($vals.Types[$i])
								{
									1{$val=($stdregprov.GetStringValue($HKLM,"$RegKey\$key",$valname).sValue)}
									2{$val=($stdregprov.GetExpandedStringValue($HKLM,"$RegKey\$key",$valname).sValue)}
									3{$val=($stdregprov.GetBinaryValue($HKLM,"$RegKey\$key",$valname).sValue)}
									4{$val=($stdregprov.GetDWORDValue($HKLM,"$RegKey\$key",$valname).sValue)}
									7{$val=($stdregprov.GetMultiStringValue($HKLM,"$RegKey\$key",$valname).sValue)}
								}
								if($val)
								{
									if(!$Obj)
									{
										$Obj="" | select @{n=$valname;e={$val}}
									}
									else
									{
										$Obj=$Obj | select *,@{n=$valname;e={$val}}
									}
								}					
							}
							catch{}
						}
					}
					if($Obj)
					{
						try
						{
							$null=$Obj.DisplayName
						}
						catch
						{
							$Obj=$Obj|select *,@{n="DisplayName";e={$key}} 
						}
						write-output $Obj
					}
					
				}
				catch{$_}
			}				
		}
		catch
		{
			Write-Warning "$($ComputerName): Failed to enum installed application"
		}
	}
	catch
	{		
		Write-Warning "$($ComputerName): Failed to connect to StdRegProv"	
	}
}
Function Is64bit($ComputerName)
{
	try
	{
		if ("64-bit" -eq (gwmi -ComputerName $ComputerName -namespace root\cimv2 -query "Select OSArchitecture from Win32_OperatingSystem" | select -expand OSArchitecture))
		{
			$true
		}
		else
		{
			$false
		}
	}
	catch
	{
		Write-Warning "$($ComputerName): Failed to connect to WMI"
	}
	
}
Export-ModuleMember -Function "Get-InstalledApplications"
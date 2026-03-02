#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support 
#program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including,  
#without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  
#the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or 
#delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft 
#has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- 
#
# v2.0 - XP - 2016/10/26 - Allow changing current UI on Windows 10 if language pack already present
#
#requires -Version 2.0

<#
 	.SYNOPSIS
       This script can
            .display the language pack still installed in Windows.
            .display the language pack available on a DFS/MDT share.
            .change the system display language in Windows.
            .install language pack from DFS/MDT share
            .remove local language pack from DFS/MDT share
    .PARAMETER  'AvaliableLanguage'
		List all of installed system language in Windows.
	.PARAMETER	'SetLanguage'
        Specifies the installed system language.
    .PARAMETER  'InstallLanguage'
        Install a language pack from DFS/MDT share
    .PARAMETER  'RemoveLanguage'
        Remove a local language pack from DFS/MDT share
    .PARAMETER  'AvailableDFSLanguage'
        List all language pack available on the DFS/MDT share

	.EXAMPLE
        C:\PS> C:\Script\ChangeSystemDisplayLanguage.ps1 -AvailiableLanguage

        ID InstalledLanguageTag
        -- --------------------
         1 en-US

		This example shows how to list all of isntalled system language in Windows.
	.EXAMPLE
        C:\PS> C:\Script\ChangeSystemDisplayLanguage.ps1 -SetLanguage "zh-CN"

        Successfully change the system display language.

        Restart the computer.
        It will take effect after logoff the current user, do you want to logoff right now?
        [Y] Yes  [N] No  [?] Help (default is "Y"):

        This example shows how to change the system display language in Windows.
#>

[CmdletBinding(DefaultParameterSetName='SetLanguage')]
Param
(
    [Parameter(Mandatory=$true,ParameterSetName='AvaliableLanguage')]
    [Switch]$AvailableLanguage,
    [Parameter(Mandatory=$true,ParameterSetName='SetLanguage')]
    [String]$SetLanguage,
    [Parameter(Mandatory=$true,ParameterSetName='InstallLanguage')]
    [String]$InstallLanguage,
    [Parameter(Mandatory=$true,ParameterSetName='RemoveLanguage')]
    [String]$RemoveLanguage,
    [Parameter(Mandatory=$false,ParameterSetName='AvailableDFSLanguage')]
    [Switch]$AvailableDFSLanguage
)

$DFSLanguagePacksRootPath = "\\mydomain.com\mdt\2013\Prod"

Function GetChoice
{
    #Prompt message
    $Caption = "Logoff needed."
    $Message = "It will take effect after logoff the current user, do you want to logoff right now?"
    $Choices = [System.Management.Automation.Host.ChoiceDescription[]]`
    @("&Yes","&No")

    [Int]$DefaultChoice = 0

    $ChoiceRTN = $Host.UI.PromptForChoice($Caption, $Message, $Choices, $DefaultChoice)
	
    Switch ($ChoiceRTN)
    {
        0 {Logoff}
        1 {break}
    }
}

Function CheckInstalledLanguage
{
     Write-Host "> Current Culture :"$((Get-Culture).Name)
    $OSInfo = Get-WmiObject -Class Win32_OperatingSystem
    $languagePacks = $OSInfo.MUILanguages
    $languagePacks
}

Function Get-GeoId($Name='*')
{
    $cultures = [System.Globalization.CultureInfo]::GetCultures('InstalledWin32Cultures') #| Out-GridView
     foreach($culture in $cultures)
    {
       try{
           $region = [System.Globalization.RegionInfo]$culture.Name
           #Write-Host "00 :"$Name "|" $region.DisplayName "|" $region.Name "|" $region.GeoId "|" $region.EnglishName "|" $culture.LCID
           if($region.Name -like $Name)
           {
                $region.GeoId
           }
       }
       catch {}
    }
}

Function Get-LCID($Name='*')
{
    $cultures = [System.Globalization.CultureInfo]::GetCultures('InstalledWin32Cultures') #| Out-GridView

     foreach($culture in $cultures)
    {
       try{
           $region = [System.Globalization.RegionInfo]$culture.Name
           #Write-Host "00 :"$Name "|" $region.DisplayName "|" $region.Name "|" $region.GeoId "|" $region.EnglishName "|" $culture.LCID
           if($region.Name -like $Name)
           {
                $culture.LCID
                #Write-Host "LCID=" $culture.LCID
           }
       }
       catch {}
    }
}


Function Get-KeyboardLayout($Name='*')
{
    #Input = fr-FR -> LCID = 1036 -> Keyboard Hex = 40C
    $LCID = Get-LCID($Name)
    #[convert]::ToInt16($LCID,16)
    [convert]::ToString($LCID,16)
    #Write-Host "KeyboardLayout:" $([convert]::ToString($LCID,16))
}

Function Get-OSCurrentVersion()
{
    [System.Environment]::OSVersion
}

Function Get-MUIPackagePath($Name='*',$Version)
{
    $ID=1
    #Write-Host "Language Packs DFS Root path : $DFSLanguagePacksRootPath\Packages\LanguagePack"
    $(Get-ChildItem -Path "$DFSLanguagePacksRootPath\Packages\LanguagePack") | 
    ForEach-Object `    {
        $N = $_.Name.ToString().LastIndexOf("_")
        $N2 = $_.Name.ToString().LastIndexOf("_",$N-1)
        $N1 = $_.Name.ToString().LastIndexOf("_",$N2-1)+1
        $NV = $_.Name.ToString().LastIndexOf("_",$N1-2)
        $MUI = New-Object -TypeName PSObject -Property @{'ID' = $ID++; 'LanguageTag' = $_.Name.ToString().Substring($N1,$N2-$N1); 'Version' = $_.Name.ToString().Substring($NV+1,$N1-$NV-2); 'Path' = $_.FullName.ToString()+"\lp.cab"} | Select ID,LanguageTag,Version,Path  
        $MUI.Version = [Version]$MUI.Version
        If ($MUI.LanguageTag -eq $Name -and $MUI.Version.Major -eq $Version.Major -and $MUI.Version.Minor -eq $Version.Minor -and $MUI.Version.Build -eq $Version.Build){
        Return $MUI
        }
    }    #| Format-Table -AutoSize
}
#---------------------------------------

If ([System.Environment]::OSVersion.Version.Major -lt 10)
{
    Write-Host "Exit." -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "Need to execute on Windows 10 version or greater." -ForegroundColor Yellow -BackgroundColor Black
    Exit
}

#---------------------------------------

If($AvailableLanguage)
{
    $ID = 1
    CheckInstalledLanguage | Foreach{New-Object -TypeName PSObject -Property @{'ID' = $ID++; 'InstalledLanguageTag' = $_}}|Format-Table -AutoSize
}


If($SetLanguage)
{
    $InstalledLngTags = CheckInstalledLanguage
    $ID = 1
    Write-Host "Found $($InstalledLngTags.Count) installed languages."
    $InstalledLngTags | Foreach{New-Object -TypeName PSObject -Property @{'ID' = $ID++; 'InstalledLanguageTag' = $_}}|Format-Table -AutoSize
    #$FoundLanguage = $False
 
    If (!$InstalledLngTags)
    {
            #Handle no language pack found - Language not installed
            Write-Host "This language pack $SetLanguage is not installed. Please install at first."
    }
    ElseIf($InstalledLngTags.ToLower() -contains $SetLanguage.ToLower() -eq $False)
    {
            #Handle language pack not matching - Language not installed
            Write-Host "This language pack $SetLanguage is not installed. Please install at first."
    }
    Else
    {
            #Language installed, set it.
            Set-Culture $SetLanguage
            Set-WinSystemLocale $SetLanguage
            Set-WinHomeLocation $(Get-GeoId($SetLanguage))
            Set-WinUserLanguageList $SetLanguage -force

            Write-Host "Successfully change the system display language to :"$SetLanguage"."
            GetChoice    
    }
}

If($InstallLanguage)
{
    Write-Host "Installing $InstallLanguage language pack from DFS location."
    $LP = Get-MUIPackagePath $InstallLanguage $(Get-OSCurrentVersion).Version
    If (!$LP)
    {
        Write-Host ">This language pack '$InstallLanguage' with version '$((Get-OSCurrentVersion).Version)' is not available on the DFS share." -ForegroundColor Red -BackgroundColor Black
        Write-Host ">Use -AvailableDFSLanguage argument to display list." -ForegroundColor Red -BackgroundColor Black
        Exit
    }
    Add-WindowsPackage -Online -PackagePath $LP.Path
    Write-Host "You need to restart the computer to be able to use this new language pack."
    Restart-Computer -Force -Confirm        
}

If($RemoveLanguage)
{
    Write-Host "Removing $RemoveLanguage local language pack from DFS location"
    $LP = Get-MUIPackagePath $RemoveLanguage $(Get-OSCurrentVersion).Version
    If (!$LP)
    {
        Write-Host ">This language pack '$RemoveLanguage' with version '$((Get-OSCurrentVersion).Version)' is not available on the DFS share." -ForegroundColor Red -BackgroundColor Black
        Write-Host ">Use -AvailableDFSLanguage argument to display list." -ForegroundColor Red -BackgroundColor Black
        Exit
    }
    Remove-WindowsPackage -Online -PackagePath $LP.Path
    Write-Host "Language pack removed"    
}

If ($AvailableDFSLanguage)
{
    $ID=1
    Write-Host "Language Packs DFS Root path : $DFSLanguagePacksRootPath\Packages\LanguagePack"
    $(Get-ChildItem -Path "$DFSLanguagePacksRootPath\Packages\LanguagePack").Name | 
    ForEach-Object `    {
        $N = $_.ToString().LastIndexOf("_")
        $N2 = $_.ToString().LastIndexOf("_",$N-1)
        $N1 = $_.ToString().LastIndexOf("_",$N2-1)+1
        $NV = $_.ToString().LastIndexOf("_",$N1-2)
        New-Object -TypeName PSObject -Property @{'ID' = $ID++; 'LanguageTag' = $_.ToString().Substring($N1,$N2-$N1); 'Version' = $_.ToString().Substring($NV+1,$N1-$NV-2)} | Select ID,LanguageTag,Version
    }    | Format-Table -AutoSize
}

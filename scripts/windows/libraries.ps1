



$LIBRARY_TYPES = @{
  Generic =	"5f4eab9a-6833-4f61-899d-31cf46979d49"
  Users =	"C4D98F09-6124-4fe0-9942-826416082DA9"
  Documents =	"7D49D726-3C21-4F05-99AA-FDC2C9474656"
  Pictures =	"B3690E58-E961-423B-B687-386EBFD83239"
  Videos =	"5fa96407-7e77-483c-ac93-691d05850de8"
  Games =	"b689b0d0-76d3-4cbb-87f7-585d0e0ce070"
  Music =	"94d6ddcc-4a68-4175-a374-bd584a510b78"
  Contacts	= "DE2B70EC-9BF7-4A93-BD3D-243F7881D492"
}




function Create-Library{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]$Name,
    [ValidateSet("Generic","Users","Documents","Pictures","Videos","Games","Music","Contacts")]
    [string]$Type="Generic",
    [string]$Icon="imageres.dll,-1002",
    [Parameter(Mandatory, ValueFromPipeline)]
    [string[]]$Paths
  )
  
  Begin{
  }
  Process{
    $folders=""
    $i=0
    foreach($path in $Paths){
      $i++
      $folders += '
      <searchConnectorDescription>
        <isDefaultSaveLocation>'+($i -eq 1 ? $true : $false)+'</isDefaultSaveLocation>
        <isDefaultNonOwnerSaveLocation>'+($i -eq 1 ? $true : $false)+'</isDefaultNonOwnerSaveLocation>
        <isSupported>true</isSupported>
        <simpleLocation>
          <url>'+$path+'</url>
        </simpleLocation>
      </searchConnectorDescription>
      '
    }

    $value = '<?xml version="1.0" encoding="UTF-8"?>
    <libraryDescription xmlns="http://schemas.microsoft.com/windows/2009/library">
      <version>1</version>
      <isLibraryPinned>true</isLibraryPinned>
      <name>'+$Name+'</name>
      <iconReference>imageres.dll,-1002</iconReference>
      <templateInfo>
        <folderType>{'+$LIBRARY_TYPES[$Type]+'}</folderType>
      </templateInfo>
      <propertyStore>
        <property name="HasModifiedLocations" type="boolean"><![CDATA[true]]></property>
      </propertyStore>
      <searchConnectorDescriptionList>
      '+$folders+'
      </searchConnectorDescriptionList>
    </libraryDescription>'
    
    Write-Host $value
    $library = New-Item "$env:appData\Microsoft\Windows\Libraries\$Name.library-ms"  -Value $value


    return $library
  }
  End {

  }
}


function Get-Library{
  param(
    [string]$Name
  )
  $library = Get-Item -Path "$env:appData\Microsoft\Windows\Libraries\$Name.library-ms"
}


function Remove-Library{
  param([string]$Name)
  Remove-Item -Path "$env:appData\Microsoft\Windows\Libraries\$Name.library-ms" -Force
}

function Find-Libraries{
  param()
  begin {
    Add-type -path Microsoft.WindowsAPICodePack.Shell.dll
  }
  # $libraries = (Get-Item -Path "$env:appData\Microsoft\Windows\Libraries").GetFiles()
  process {
    [Microsoft.WindowsAPICodePack.Shell.KnownFolders]::Libraries | Select-Object Name,ParsingName
  } 
}


function Add-LibraryFolder{
  param(
    [string]$LibraryName,
    [string]$FolderName,
    [string]$FolderPath
  )
  $library = Get-Item -Path "$env:appData\Microsoft\Windows\Libraries\$LibraryName.library-ms"
  $libraryXml = [xml](Get-Content $library.FullName)
  $folder = $libraryXml.CreateElement($FolderName)
  $folder.SetAttribute('path', $FolderPath)
  $libraryXml.libraryDescription.AppendChild($folder)
  $libraryXml.Save($library.FullName)


  $folder = Get-Item $FolderPath

}




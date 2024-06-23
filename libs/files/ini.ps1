


function Get-IniContent {
  Param (
    [Parameter(Position = 0)]
    [string]$FilePath
  )

  $ini = @{}
  switch -regex -file $FilePath {
    “^\[(.+)\]” { # Section
      $section = $matches[1]
      $ini[$section] = @{}
      $CommentCount = 0
    }
    “^(;.*)$” { # Comment
      $value = $matches[1]
      $CommentCount = $CommentCount + 1
      $name = “Comment” + $CommentCount
      $ini[$section][$name] = $value
    }
    “(.+?)\s*=(.*)” { # Key
      $name, $value = $matches[1..2]
      $ini[$section][$name] = $value
    }
  }
  return $ini
}


function Out-IniFile {
  Param (
    [Parameter(Position = 0)]
    [string]$FilePath,
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [hashtable]$InputObject
  )
  Write-Verbose "Writing to $FilePath"

  if (Test-Path $FilePath) {
    Clear-Content -Path $FilePath -Force
    $outFile = Get-Item -Path $FilePath -Force
  } else {
    $outFile = New-Item -ItemType file -Path $Filepath -Force
  }
  

  foreach ($i in $InputObject.keys) {
    if (!($($InputObject[$i].GetType().Name) -eq "Hashtable")) {
      #No Sections
      Add-Content -Path $outFile -Value "$i=$($InputObject[$i])"
    }
    else {
      #Sections
      Add-Content -Path $outFile -Value "[$i]"
      Foreach ($j in ($InputObject[$i].keys | Sort-Object)) {
        if ($j -match "^Comment[\d]+") {
          Add-Content -Path $outFile -Value "$($InputObject[$i][$j])"
        }
        else {
          Add-Content -Path $outFile -Value "$j=$($InputObject[$i][$j])" 
        }

      }
      Add-Content -Path $outFile -Value ""
    }
  }
}



function Set-IniValue {
  param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Section,
    [Parameter(Mandatory, Position = 1)]
    [string]$Key,
    [Parameter(Mandatory, Position = 2)]
    [string]$Value,
    [Parameter(Mandatory=$false, Position = 4)]
    [string]$FilePath=$null,
    [Parameter(Mandatory=$false, ValueFromPipeline)]
    [hashtable]$InputObject
  )

  if(Test-Path $InputObject){
    $FilePath = $InputObject
    $ini = Get-IniContent $FilePath
  } elseif($InputObject -is [hashtable]) {
    $ini = $InputObject
  } else {
    $ini = @{}
  }

  if (($null -eq $ini[$Section]) -or (!($ini[$Section] -is [Hashtable]))) {
    $ini[$Section] = @{}
  }

  $ini[$Section][$Key] = $Value
  if($FilePath){
    Out-IniFile -InputObject $ini -FilePath $FilePath
  } else {
    Write-Verbose "Unable to get ouptut file path"
  }
  return $ini
}

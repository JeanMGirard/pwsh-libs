


function Find-DuplicateFiles {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$false, Position=0)]
    [String] $Path = ".",
    
    [Parameter(Mandatory=$false)]
    [int] $Depth = 5
  )
  Get-ChildItem -Depth $Depth -File $Path -Recurse | get-filehash | group -property hash | where { $_.count -gt 1 } | % { $_.group }
}


Export-ModuleMember -Function Find-DuplicateFiles

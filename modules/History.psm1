


function Search-History {
  Param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$Pattern
  )

  $historyFilePath = (Get-PSReadlineOption).HistorySavePath
  Get-Content -Path $historyFilePath | Select-String -Pattern $Pattern
}

function Clear-History {
  $historyFilePath = (Get-PSReadlineOption).HistorySavePath
  Clear-Content -Path $historyFilePath
}

function Get-History {
  $historyFilePath = (Get-PSReadlineOption).HistorySavePath
  Get-Content -Path $historyFilePath
}

Export-ModuleMember -Function Search-History, Clear-History, Get-History

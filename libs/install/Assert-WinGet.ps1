

# Verify the command is present in the Microsoft.WinGet.Client Module
function Assert-WinGetCommand([string]$cmdletName) {
    $null = Get-Command -Module "Microsoft.WinGet.Client" -Name $cmdletName -ErrorAction Stop
}


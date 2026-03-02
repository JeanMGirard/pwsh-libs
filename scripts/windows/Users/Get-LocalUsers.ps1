param(
    [string]$Computer
    )

$SystemStatus = (Test-Connection -Computername $computer -BufferSize 16 -Count 1 -Quiet)
    If($SystemStatus){
    invoke-command -comp $Computer{
        $c = $env:COMPUTERNAME
        $LocalGroups = (Get-CimInstance Win32_Group -Filter "Domain='$c'").Name
        Foreach ($g in $LocalGroups){
            $x = net localgroup "$g" | select -skip 6 | select -SkipLast 2 | where {$_ -notmatch "NT AUTHORITY"} 
            If ($x){
                "`n ---$g---"
                $x
            }
        }
        "`n"
    }
}
Else {"System Offline"}
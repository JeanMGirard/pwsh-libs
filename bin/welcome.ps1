

if ($env:WELCOMED) { return }
$env:WELCOMED = $true

# echo 'plink -ssh -i C:\Users\JeanM\.ssh\Muirwood\mws.ppk ec2-user@ifm.mwstudio.ca -pw [pass]';
# list-my-alias-pretty

Find-Aliases -Pretty

Write-Host "
Useful Commands: Find-Aliases -Pretty
Notes: nb, kb, log4brains, logseq, tldr


"


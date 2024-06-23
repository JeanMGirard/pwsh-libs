

function Reset-KubeManifest{
  kubectl delete -f @args;  
  kubectl apply -f @args;
}

Set-Alias -Name kubectl-apply   -Value 'kubectl apply  -f'
Set-Alias -Name kubectl-delete  -Value 'kubectl delete  -f'
Set-Alias -Name kubectl-a     -Value 'kubectl --all-namespaces'

Export-ModuleMember -Function Reset-KubeManifest
Export-ModuleMember -Alias kubectl-*

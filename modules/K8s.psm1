

function Reset-KubeManifest{
  kubectl delete -f @args;  
  kubectl apply -f @args;
}



Set-Alias -Name kc-apply      -Value 'kubectl apply  -f'
Set-Alias -Name kc-delete     -Value 'kubectl delete  -f'
Set-Alias -Name kc-a          -Value 'kubectl --all-namespaces'
Set-Alias -Name kc-get        -Value 'kubectl get'
Set-Alias -Name kc-ns         -Value 'kubectl get namespaces'
Set-Alias -Name kc-resources  -Value 'kubectl api-resources -o name'

Export-ModuleMember -Function Reset-KubeManifest
Export-ModuleMember -Alias kc-*

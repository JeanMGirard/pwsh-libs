
# ALIASES
# Remove-Alias -Name dkc   
#Set-Alias -Name python -Value Python-Launcher

Set-Alias -Name dk      -Value docker
function        dkc { docker compose @args; }
Set-Alias -Name dkm     -Value docker-machine


Set-Alias -Name faas    -Value faas-cli
Set-Alias -Name g       -Value git
Set-Alias -Name gcmt    -Value git-commit
Set-Alias -Name gacp    -Value git-add-commit-push
Set-Alias -Name gf      -Value git-flow
Set-Alias -Name gitc    -Value git-commit
Set-Alias -Name gitf    -Value git-flow

Set-Alias -Name kc      -Value kubectl
Set-Alias -Name kctl    -Value kubectl

# Remove-PSFAlias kba
function kbctl-apply            { kubectl apply  -f @args;  }
function kbctl-delete           { kubectl delete -f @args;  }
function kbctl-delete-and-apply { kubectl delete -f @args;  kubectl apply -f @args; }
function kbctl-get              { kubectl get @args; }
function kbctl-get-all-ns       { kubectl get @args --all-namespaces; }

function        kctl-a   { kubectl apply @args; }
function        kctl-af  { kubectl apply -f @args; }
function        kctl-c   { kubectl create @args; }
function        kctl-cf  { kubectl create -f @args; }
function        kctl-d   { kubectl delete @args; }
function        kctl-df  { kubectl delete -f @args; }
function        kctl-da  { kubectl delete @args; kubectl apply @args; }
function        kctl-dfa { kubectl delete -f @args; kubectl apply -f @args; }
function        kctl-g   { kubectl get @args; }
function        kctl-ga  { kubectl get --all-namespaces @args; }
function        helm-add { helm upgrade --install @args; }
function        helm-rem { helm uninstall @args; }

Set-Alias -Name mkube   -Value minikube
Set-Alias -Name py      -Value python
Set-Alias -Name tf      -Value terraform
Set-Alias -Name tg      -Value terragrunt
Set-Alias -Name wd      -Value wikidata-cli
Set-Alias -Name wdtax   -Value wdtaxonomy


function        mvnw { mvn wrapper:wrapper @args; }
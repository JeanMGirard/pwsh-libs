# ALIASES


# =================================================================
# Java
# =================================================================
function mvnw { mvn wrapper:wrapper @args; }
Set-Alias -Name maven -Value mvn


# =================================================================
# Other
# =================================================================
# Remove-Alias -Name dkc   
#Set-Alias -Name python -Value Python-Launcher

Set-Alias -Name dk      -Value docker
function        dkc { docker compose @args; }
Set-Alias -Name dkm     -Value docker-machine

Set-Alias -Name git     -Value hub
Set-Alias -Name faas    -Value faas-cli
Set-Alias -Name g       -Value hub
Set-Alias -Name gcmt    -Value git-commit
Set-Alias -Name gacp    -Value git-add-commit-push
Set-Alias -Name gf      -Value git-flow
Set-Alias -Name gitc    -Value git-commit
Set-Alias -Name gitf    -Value git-flow

Set-Alias -Name kc      -Value kubectl
Set-Alias -Name kctl    -Value kubectl
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
Set-Alias -Name syslog  -Value Get-SystemEventlog

# function tf { terraform @args;}
# function tg { terragrunt @args;}
function mvnw { mvn wrapper:wrapper @args; }



# =================================================================
# Git
# =================================================================
# act:         Extension act
# actions-importer: Extension actions-importer
# bump:        Extension bump
# changelog:   Extension changelog
# classroom:   Extension classroom
# clean-branches: Extension clean-branches
# codeql:      Extension codeql
# combine-prs: Extension combine-prs
# copilot:     Extension copilot
# dash:        Extension dash
# dependabot:  Extension dependabot
# f:           Extension f
# markdown-preview: Extension markdown-preview
# metrics:     Extension metrics
# milestone:   Extension milestone
# ost:         Extension ost
# projects:    Extension projects
# qldb:        Extension qldb
# repo-config: Extension repo-config
# repo-explore: Extension repo-explore
# repo-stats:  Extension repo-stats
# sbom:        Extension sbom
# screensaver: Extension screensaver
# slack:       Extension slack
# tidy:        Extension tidy
# todo:        Extension todo
# token:       Extension token
# user-stars:  Extension user-stars
# webhook:     Extension webhook
function copilot{ gh copilot @args; }



# ===========================================================================
# Tools for Notes
# npm install -g log4brains nb.sh
# pip install -U kb-manager
# ===========================================================================
# https://github.com/gnebbia/kb#notes-for-windows-users
function kbl { kb list $args }
function kbe { kb edit $args }
function kba { kb add  $args }
function kbv { kb view $args }
function kbd { kb delete --id $args }
function kbg { kb grep $args }
function kbt { kb list --tags $args }

# https://github.com/xwmx/nb





# ===========================================================================
# connect-AzAccount -TenantId afe3b0e5-8b43-47c4-974d-3dab5cefc96a -UseDeviceAuthentication
# az alias create --name rg --command group
# az alias create --name ls --command list
# AzGovVizParallel.ps1 -ManagementGroupId afe3b0e5-8b43-47c4-974d-3dab5cefc96a


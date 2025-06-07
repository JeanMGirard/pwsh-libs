

# GIT
# Add-SshKey ($ScriptDir+"/.ssh/id_rsa")
# Start-SshAgent -Quiet
# git config --global user.name "JeanMGirard"
# git config --global user.email Jean.M.Girard@Outlook.com



function git-flow  { git flow   @args ; }
function git-commit{ git commit @args ; }

Function git-add-commit-push($msg) {
    git add . ;
    git commit -m "$msg"  @args;
    git push;
}
Function git-help() {

}
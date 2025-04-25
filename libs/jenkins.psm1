

$JENKINS_URL="https://jenkins.ssqti.ca"


function Install-JenkinsTools {
  Write-Host " You will need your username and an authentication token from your Jenkins Profile.."
  Write-Host " Find them at $JENKINS_URL/me"
  Write-Host ""

  $user_email = Read-Host "Enter your email"
  $jenkins_user = Read-Host "Enter your jenkins username from AzureAD (uuid)"
  $jenkins_token = Read-Host "Enter your jenkins auth token" -AsSecureString

  $jar_url="$JENKINS_URL/jnlpJars/jenkins-cli.jar"

  # Creates bin directory
  if (-not (Test-Path "${HOME}\bin" -PathType Container)){
    mkdir "${HOME}\bin"
    $prev_path=[Environment]::GetEnvironmentVariable("PATH", "user")
    [Environment]::SetEnvironmentVariable("PATH", "$prev_path;${HOME}\bin", "User")
  }

  # Creates SSH key
  if (-not (Test-Path "${HOME}\.ssh\id_rsa" -PathType Leaf)){
    ssh-keygen -t rsa -C "jean-michel.girard@beneva.ca" -N "" -b 4096 -f "${HOME}\.ssh\id_rsa"; 
  }
  
  Invoke-WebRequest $jar_url -OutFile "$env:JENKINS_JAR"

  Write-Host " Saving user environment variables..."
  [Environment]::SetEnvironmentVariable("USER_EMAIL", $user_email, "User")
  [Environment]::SetEnvironmentVariable("JENKINS_URL", $JENKINS_URL, "User")
  [Environment]::SetEnvironmentVariable("JENKINS_USER_ID", $jenkins_user, "User")
  [Environment]::SetEnvironmentVariable("JENKINS_API_TOKEN", $jenkins_token, "User")
  [Environment]::SetEnvironmentVariable("JENKINS_JAR", $env:JENKINS_JAR, "User")

  Clear-Host
  Write-Host " "
  Write-Host " Jenkins installation successful."
  Write-Host " Dont forget to set your public SSH key in you Jenkins profile at this url: $env:JENKINS_URL/me/security ! "
  Write-Host " "
  Write-Host " Here's the value you must input:"
  Write-Host " "
  Get-Content "${HOME}\.ssh\id_rsa.pub"
  Write-Host " "
}

function Use-Jenkins {
  java -jar "$env:JENKINS_JAR" `
    -ssh -i "$HOME/.ssh/id_rsa" -user "$env:JENKINS_USER_ID" `
    -s $env:JENKINS_URL @args;
}

function Test-Jenkinsfile {
  curl -X POST --user "${env:JENKINS_USER_ID}:${env:JENKINS_API_TOKEN}" -F "jenkinsfile=<Jenkinsfile" "${env:JENKINS_URL}/pipeline-model-converter/validate"
}

Set-Alias -Name jenkins -Value Use-Jenkins
Set-Alias -Name pipelint -Value Test-Jenkinsfile

Export-ModuleMember -Function *
Export-ModuleMember -Alias *

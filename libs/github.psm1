
Import-Module -Name "$PSScriptRoot/git.psm1"
Import-Module -Name "$PSScriptRoot/windows.psm1"
Import-Module -Name "$PSScriptRoot/windows.paths.psm1"


# $env:DOCKER_HOST = 'ssh://user@host'
# act -s GITHUB_TOKEN="$(gh auth token)"



function Install-GithubWorkflowTools {

}

function Get-GitHubToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Scope
    )

    $token = gh auth token --scopes $Scope
    if (-not $token) {
        throw "Failed to retrieve GitHub token for scope '$Scope'."
    }
    return $token
}


function Install-GithubWorkflowRunner {
  [CmdletBinding()]
  param (
      [Parameter()][string]$InstallRoot = 'C:\github-actions-runner',
      [Parameter()][string]$Version = '2.324.0'
  )
  begin {
    Add-Type -AssemblyName System.IO.Compression.FileSystem;
    $Arch=(Get-SystemArchitecture)
  }
  process {
    New-Item -ItemType Directory -Path $InstallRoot -Force | Out-Null
    Set-Location -Path $InstallRoot
    
    # Download the latest runner package
    Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v$Version/actions-runner-win-$Arch-$Version.zip" `
      -OutFile actions-runner-win-$Arch-$Version.zip
    
    # Extract the installer
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD\actions-runner-win-$Arch-$Version.zip", "$PWD")
    Remove-Item -Path "$PWD\actions-runner-win-$Arch-$Version.zip" -Force

    # Configure the runner
    $runnerConfig = "$InstallRoot\config.cmd"

    if (-not (Test-Path -Path $runnerConfig)) {
        throw "Runner configuration script not found at '$runnerConfig'."
    }
  }
  end {
    Add-SystemPath -Path "$InstallRoot/bin" -Scope "User"
  }
}

function Push-GithubBranch {
    param (
        [string]$BranchName,
        [string]$CommitMessage
    )
    if (-not (Test-Path -Path $PrListFile)) {
        New-Item -Path $PrListFile -ItemType File -Force
    }
    git checkout $BranchName
    if ((git rev-list --count $BranchName...HEAD) -eq "0") {
        Write-Host "No changes to commit in branch $BranchName. Skipping push and PR creation."
        return
    }

    git push origin $BranchName --force --no-verify
    $PrURL=$(gh pr create --title  --fill --head $BranchName)
    Write-Host "Created PR: $PrURL"
    Add-Content -Path $PrListFile -Value "* ${PrURL}"

    git checkout $(Get-GitDefaultBranch)
    git branch -D $BranchName
    gh pr merge "${PrURL}" --auto
}
function Update-GithubWorkflow {
    param (
        [string]$BranchName,
        [string]$WorkflowFile,
        [string]$OldWorkflowFile,
        [string]$CommitMessage
    )
    Write-Host "----------------------------------------"

    $repoName = (Get-Item .).Name
    Write-Host "Updating: ${repoName}"

    Reset-GitBranch -BranchName $BranchName
    New-Item -Path ".github/workflows" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

    if (Test-Path -Path $OldWorkflowFile) {
        # TODO: if both files exist, compare and merge if needed
        Move-Item -Path $OldWorkflowFile -Destination $WorkflowFile -Force
    }
    if (-not (Test-Path -Path $WorkflowFile)) {
        New-Item -Path $WorkflowFile -ItemType File -Force -Value @'
name: PR Scan
on:
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [master, main, develop]
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
permissions:
  pull-requests: write
  contents: read
'@
    }
    yq -i 'with(select(.concurrency == null); .concurrency = {} ) |
        .concurrency.group = "${{ github.workflow }}-${{ github.ref }}" |
        .concurrency.cancel-in-progress = true
    ' $WorkflowFile
    yq -i 'with(select(.permissions == null); .permissions = {} ) |
        .permissions.pull-requests = "write"
    ' $WorkflowFile
    yq -i 'with(select(.jobs == null); .jobs = {} ) |
        .jobs.labels = {
            "name": "PR Labels",
            "uses": "beneva-int/ec-github-reusable-workflows/.github/workflows/pr-labels.yaml@v3",
            "secrets": "inherit",
            "with": { }
        }
    ' $WorkflowFile
    yq -i --indent 2 -r -P $WorkflowFile

    git add $WorkflowFile $OldWorkflowFile
    git commit -m $CommitMessage --no-verify
}


# $Branch = "chore/PN-248_PrLabels"
# $Message = "chore(pn-248): add PR labels workflow"

# Invoke-ForEachRepo Update-GithubWorkflow `
#     -BranchName $Branch -CommitMessage $Message `
#     -WorkflowFile ".github/workflows/pr-scan.yaml" `
#     -OldWorkflowFile ".github/workflows/scan-pr.yaml"

# Invoke-ForEachRepo Push-GitBranch `
#     -BranchName $Branch


Export-ModuleMember -Function "Install-*"
Export-ModuleMember -Function "Update-**"
Export-ModuleMember -Function "Push-**"

param(
    [Parameter(Mandatory=$true)]
    [string]$ServiceName
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ServiceName)) {
    throw "Service Name is empty"
}

$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PlatformDir = Join-Path $BaseDir ".."
$ConfigFile = Join-Path $PlatformDir "platform-config.yaml"
$BoundedContextsDir = yq ".platform.boundedContexts.dir" $ConfigFile
$TargetDir = [IO.Path]::GetFullPath("$PlatformDir/$BoundedContextsDir/$ServiceName")

$ToolsDir = "$BaseDir/.tools"
$env:PATH = "$ToolsDir;$env:PATH"

$Owner = "komelgman"
$RepositoryName = "imanai-tap.$ServiceName"
$RepoUrl = "https://github.com/$Owner/$RepositoryName.git"
$TemplateRepo = "$Owner/imanai-tap.bc-service-template"


Write-Host "Creating repository $RepositoryName from template..." -ForegroundColor Cyan
gh repo create $RepositoryName --template $TemplateRepo --public

if ($LASTEXITCODE -ne 0) {
    throw "Failed to create repository. Exit code: $LASTEXITCODE"
}

$maxAttempts = 30
$attempt = 0
$repoReady = $false
while ($attempt -lt $maxAttempts) {
    Start-Sleep -Seconds 2

    $repoInfo = gh repo view $RepositoryName --json defaultBranchRef 2>$null
    if ($LASTEXITCODE -eq 0 -and $repoInfo) {
        $branchInfo = $repoInfo | ConvertFrom-Json
        if ($branchInfo.defaultBranchRef) {
            $repoReady = $true
            break
        }
    }

    $attempt++
    Write-Host "." -NoNewline
}

if (-not $repoReady) {
    throw "Repository was not ready after $($maxAttempts * 2) seconds"
}

Write-Host "Cloning repository $RepositoryName from template..." -ForegroundColor Cyan
git clone -b main $RepoUrl $TargetDir
if ($LASTEXITCODE -ne 0) {
    throw "Failed to clone repository. Exit code: $LASTEXITCODE"
}

Write-Host "Initializing repository from templates..." -ForegroundColor Cyan
$InitScript = Join-Path $TargetDir "bootstrap/init-new-service.ps1"
if (Test-Path $InitScript) {
    try {
        $NS="http://maven.apache.org/POM/4.0.0"
        $VerXPath="/p:project/p:version"
        $ParentPomVersion = Select-Xml -Path pom.xml -Namespace @{p=$NS} -XPath $VerXPath |
                ForEach-Object { $_.Node.InnerText }

        Push-Location $TargetDir
        & $InitScript $ParentPomVersion

        if ($LASTEXITCODE -ne 0) {
            throw "Failed to init repository. Exit code: $LASTEXITCODE"
        }

        Remove-Item $InitScript -Force

        git add .
        git commit -m "chore: Initialise repo from templates"
        git push origin main
    } finally {
        Pop-Location
    }
}

Write-Host "Bootstrapping repository..." -ForegroundColor Cyan
$BootstrapScript = Join-Path $TargetDir "bootstrap/main.ps1"
if (Test-Path $BootstrapScript) {
    try {
        Push-Location $TargetDir
        & $BootstrapScript
    } finally {
        Pop-Location
    }
}

# TODO: generate service documentation stub

Write-Host "Updating $ConfigFile..." -ForegroundColor Cyan
yq eval ".platform.boundedContexts.services += [{\`"name\`": \`"$ServiceName\`", \`"repo\`": \`"$RepoUrl\`"}]" -i $ConfigFile
if ($LASTEXITCODE -ne 0) {
    throw "Failed to update configuration. Exit code: $LASTEXITCODE"
}

Write-Host "Committing changes..." -ForegroundColor Cyan
git add $ConfigFile
if ($LASTEXITCODE -ne 0) {
    throw "Failed to stage configuration file. Exit code: $LASTEXITCODE"
}

git commit -m "Add service $ServiceName to configuration"
if ($LASTEXITCODE -ne 0) {
    throw "Failed to commit changes. Exit code: $LASTEXITCODE"
}

Write-Host "`nDone!" -ForegroundColor Green

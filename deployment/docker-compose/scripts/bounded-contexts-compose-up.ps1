param(
    [string]$PlatformDir,
    [string]$ConfigFile
)

$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BoundedContextsDir = yq ".platform.boundedContexts.dir" $ConfigFile
$BoundedContextsPath = [IO.Path]::GetFullPath("$PlatformDir/$BoundedContextsDir")

$PlatformComposeFile = "$PlatformDir/deployment/docker-compose/docker-compose.yml"
Write-Host "[bounded-contexts-compose-up.ps1] Launching platform compose: $PlatformComposeFile"
& docker compose -f $PlatformComposeFile up -d --remove-orphans

# Project structure
#
# project-root
# ├── platform
# │   └── deployment
# │       └── docker-compose
# │           └── docker-compose.yml
# ├── bounded-contexts
# │   ├── <service>
# │   │   ├── src
# │   │   └── docker-compose.yml
# │   └── ...
# └── ...

$env:DOCKER_BUILDKIT = "1"
$Services = yq ".platform.boundedContexts.services[].name" $ConfigFile | ForEach-Object { $_.Trim() }
foreach ($svc in $Services) {
    $BoundedContextsServiceDir = "$BoundedContextsPath/$svc"
    $ServiceComposeFile = "$BoundedContextsServiceDir/docker-compose.yml"

    if (Test-Path $ServiceComposeFile) {
        Write-Host "[bounded-contexts-compose-up.ps1] Launching service compose: $ServiceComposeFile"
        & docker compose -f $ServiceComposeFile up -d --remove-orphans
    } else {
        Write-Host "[bounded-contexts-compose-up.ps1:Warning] Compose file for service '$svc' not found at $ServiceComposeFile"
    }
}
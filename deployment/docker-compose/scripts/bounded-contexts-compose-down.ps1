param(
    [string]$PlatformDir,
    [string]$ConfigFile
)

$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BoundedContextsDir = yq ".platform.boundedContexts.dir" $ConfigFile
$BoundedContextsPath = [IO.Path]::GetFullPath("$PlatformDir/$BoundedContextsDir")
$PlatformComposeFile = "$PlatformDir/deployment/docker-compose/docker-compose.yml"

$AllServices = yq ".platform.boundedContexts.services[].name" $ConfigFile | ForEach-Object { $_.Trim() }

foreach ($svc in $AllServices) {
    $BoundedContextsServiceDir = "$BoundedContextsPath/$svc"
    $ServiceComposeFile = "$BoundedContextsServiceDir/docker-compose.yml"

    if (Test-Path $ServiceComposeFile) {
        Write-Host "[bounded-contexts-compose-down.ps1] Stopping service compose: $ServiceComposeFile"
        & docker compose -f $ServiceComposeFile down
    } else {
        Write-Host "[bounded-contexts-compose-down.ps1:Warning] Compose file for service '$svc' not found at $ServiceComposeFile" -ForegroundColor Yellow
    }
}

Write-Host "[bounded-contexts-compose-down.ps1] Stopping platform compose: $PlatformComposeFile"
& docker compose -f $PlatformComposeFile down

Write-Host "[bounded-contexts-compose-down.ps1] Removing docker network..."
& "$BaseDir/remove-docker-network.ps1" $ConfigFile
param(
    [string]$PlatformDir,
    [string]$ConfigFile,
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$ServicesToBuild
)

$env:DOCKER_BUILDKIT = "1"

$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BoundedContextsDir = yq ".platform.boundedContexts.dir" $ConfigFile
$BoundedContextsPath = [IO.Path]::GetFullPath("$PlatformDir/$BoundedContextsDir")
$PlatformComposeFile = "$PlatformDir/deployment/docker-compose/docker-compose.yml"

Write-Host "[bounded-contexts-compose-up.ps1] Creating docker network..."
& "$BaseDir/add-docker-network.ps1" $ConfigFile

Write-Host "[bounded-contexts-compose-up.ps1] Launching platform compose: $PlatformComposeFile"
& docker compose -f $PlatformComposeFile up -d --remove-orphans

$AllServices = yq ".platform.boundedContexts.services[].name" $ConfigFile | ForEach-Object { $_.Trim() }

if ($ServicesToBuild -and $ServicesToBuild.Count -gt 0) {
    Write-Host "[bounded-contexts-compose-up.ps1] Rebuilding specific services: $($ServicesToBuild -join ', ')"

    $InvalidServices = $ServicesToBuild | Where-Object { $AllServices -notcontains $_ }
    if ($InvalidServices) {
        Write-Host "[bounded-contexts-compose-up.ps1:Warning] Services not found in config: $($InvalidServices -join ', ')" -ForegroundColor Yellow
        exit 1
    }
}

foreach ($svc in $AllServices) {
    $BoundedContextsServiceDir = "$BoundedContextsPath/$svc"
    $ServiceComposeFile = "$BoundedContextsServiceDir/docker-compose.yml"

    if (Test-Path $ServiceComposeFile) {
        $shouldBuild = ($ServicesToBuild.Count -gt 0) -and ($ServicesToBuild -contains $svc)

        Write-Host "[bounded-contexts-compose-up.ps1] Launching service compose: $ServiceComposeFile $(if ($shouldBuild) {'with rebuild'})"

        if ($shouldBuild) {
            & docker compose -f $ServiceComposeFile up -d --build --force-recreate --remove-orphans
        } else {
            & docker compose -f $ServiceComposeFile up -d --remove-orphans
        }
    } else {
        Write-Host "[bounded-contexts-compose-up.ps1:Warning] Compose file for service '$svc' not found at $ServiceComposeFile" -ForegroundColor Yellow
    }
}
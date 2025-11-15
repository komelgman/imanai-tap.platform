param(
    [string]$PlatformDir,
    [string]$ConfigFile,
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$ServicesToBuild
)

$env:DOCKER_BUILDKIT = "1"

$BoundedContextsDir = yq ".platform.boundedContexts.dir" $ConfigFile
$BoundedContextsPath = [IO.Path]::GetFullPath("$PlatformDir/$BoundedContextsDir")

$AllServices = yq ".platform.boundedContexts.services[].name" $ConfigFile | ForEach-Object { $_.Trim() }

if (-not $AllServices) {
    Write-Host "[bounded-contexts-up.ps1:Error] No services found in config" -ForegroundColor Red
    exit 1
}

if ($ServicesToBuild -and $ServicesToBuild.Count -gt 0) {
    Write-Host "[bounded-contexts-up.ps1] Rebuilding specific services: $($ServicesToBuild -join ', ')"

    $InvalidServices = $ServicesToBuild | Where-Object { $AllServices -notcontains $_ }
    if ($InvalidServices) {
        Write-Host "[bounded-contexts-up.ps1:Error] Services not found in config: $($InvalidServices -join ', ')" -ForegroundColor Red
        exit 1
    }
}

foreach ($svc in $AllServices) {
    $BoundedContextsServiceDir = "$BoundedContextsPath/$svc"
    $ServiceComposeFile = "$BoundedContextsServiceDir/docker-compose.yml"

    if (Test-Path $ServiceComposeFile) {
        $shouldBuild = ($ServicesToBuild.Count -gt 0) -and ($ServicesToBuild -contains $svc)

        Write-Host "[bounded-contexts-up.ps1] Launching service: $svc $(if ($shouldBuild) {'with rebuild'})"

        if ($shouldBuild) {
            & docker compose -f $ServiceComposeFile up -d --build --force-recreate
        } else {
            & docker compose -f $ServiceComposeFile up -d
        }

        if ($LASTEXITCODE -ne 0) {
            Write-Host "[bounded-contexts-up.ps1:Error] Failed to launch service '$svc'" -ForegroundColor Red
            exit $LASTEXITCODE
        }
    } else {
        Write-Host "[bounded-contexts-up.ps1:Warning] Compose file for service '$svc' not found at $ServiceComposeFile" -ForegroundColor Yellow
    }
}

Write-Host "[bounded-contexts-up.ps1] All services launched successfully" -ForegroundColor Green
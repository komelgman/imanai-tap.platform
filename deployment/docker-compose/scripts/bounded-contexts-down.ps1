param(
    [string]$PlatformDir,
    [string]$ConfigFile
)

$BoundedContextsDir = yq ".platform.boundedContexts.dir" $ConfigFile
$BoundedContextsPath = [IO.Path]::GetFullPath("$PlatformDir/$BoundedContextsDir")
$AllServices = yq ".platform.boundedContexts.services[].name" $ConfigFile | ForEach-Object { $_.Trim() }

if (-not $AllServices)
{
    Write-Host "[bounded-contexts-compose-down.ps1:Warning] No services found in config" -ForegroundColor Yellow
    exit 0
}

[array]::Reverse($AllServices)

foreach ($svc in $AllServices)
{
    $BoundedContextsServiceDir = "$BoundedContextsPath/$svc"
    $ServiceComposeFile = "$BoundedContextsServiceDir/docker-compose.yml"

    if (Test-Path $ServiceComposeFile)
    {
        Write-Host "[bounded-contexts-compose-down.ps1] Stopping service: $svc"

        & docker compose -f $ServiceComposeFile down --remove-orphans

        if ($LASTEXITCODE -ne 0)
        {
            Write-Host "[bounded-contexts-compose-down.ps1:Warning] Failed to stop service '$svc' cleanly" -ForegroundColor Yellow
        }
    }
    else
    {
        Write-Host "[bounded-contexts-compose-down.ps1:Warning] Compose file for service '$svc' not found at $ServiceComposeFile" -ForegroundColor Yellow
    }
}

Write-Host "[bounded-contexts-compose-down.ps1] All services stopped" -ForegroundColor Green

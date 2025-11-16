param(
    [string]$ConfigFile
)


$NetworkName = yq ".platform.network.name" $ConfigFile
$existing = docker network ls --format "{{.Name}}" | Where-Object { $_ -eq $NetworkName }

if ($existing)
{
    Write-Host "[remove-docker-network.ps1] Removing network '$NetworkName'..."
    docker network rm $NetworkName

    if ($LASTEXITCODE -eq 0)
    {
        Write-Host "[remove-docker-network.ps1] Network '$NetworkName' removed successfully."
    }
    else
    {
        Write-Host "[remove-docker-network.ps1] Failed to remove network '$NetworkName'. It may be in use." -ForegroundColor Yellow
    }
}
else
{
    Write-Host "[remove-docker-network.ps1] Network '$NetworkName' does not exist. Skipping."
}

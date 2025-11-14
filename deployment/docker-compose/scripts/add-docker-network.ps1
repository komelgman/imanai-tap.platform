param(
    [string]$ConfigFile
)

$NetworkName = yq ".platform.network.name" $ConfigFile
$existing = docker network ls --format "{{.Name}}" | Where-Object { $_ -eq $NetworkName }

if (-not $existing) {
    Write-Host "[add-docker-network.ps1] Creating network '$NetworkName'..."
    docker network create $NetworkName
} else {
    Write-Host "[add-docker-network.ps1] Network '$NetworkName' already exists. Skipping."
}
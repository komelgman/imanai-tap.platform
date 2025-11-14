param(
    [string]$PlatformDir,
    [string]$ConfigFile
)

$InfraFiles = @()

$InfraConfigEntries = yq ".platform.infra | to_entries | .[] | .value" $ConfigFile 2>$null
if ($InfraConfigEntries) {
    foreach ($relPath in $InfraConfigEntries) {
        $absPath = [IO.Path]::GetFullPath("$PlatformDir/$relPath")
        if (Test-Path $absPath) {
            $InfraFiles += $absPath
        }
    }
}

if ($InfraFiles.Count -eq 0) {
    Write-Host "[platform-infra-down.ps1:Warning] No infrastructure compose files found" -ForegroundColor Yellow
    exit 0
}

[array]::Reverse($InfraFiles)

foreach ($composeFile in $InfraFiles) {
    Write-Host "[platform-infra-down.ps1] Stopping infrastructure: $composeFile"

    & docker compose -f $composeFile down --remove-orphans

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[platform-infra-down.ps1:Warning] Failed to stop $composeFile cleanly" -ForegroundColor Yellow
    }
}

Write-Host "[platform-infra-down.ps1] Platform infrastructure stopped" -ForegroundColor Green
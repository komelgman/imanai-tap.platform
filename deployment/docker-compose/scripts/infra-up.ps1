param(
    [string]$PlatformDir,
    [string]$ConfigFile
)

$InfraFiles = @()

$InfraConfigEntries = yq ".platform.infra | to_entries | .[] | .value" $ConfigFile 2> $null
if ($InfraConfigEntries)
{
    foreach ($relPath in $InfraConfigEntries)
    {
        $absPath = [IO.Path]::GetFullPath("$PlatformDir/$relPath")
        if (Test-Path $absPath)
        {
            $InfraFiles += $absPath
        }
        else
        {
            Write-Host "[infra-up.ps1:Warning] Infra file not found: $absPath" -ForegroundColor Yellow
        }
    }
}

if ($InfraFiles.Count -eq 0)
{
    Write-Host "[infra-up.ps1:Error] No infrastructure compose files found" -ForegroundColor Red
    exit 1
}

foreach ($composeFile in $InfraFiles)
{
    Write-Host "[infra-up.ps1] Launching infrastructure: $composeFile"

    & docker compose -f $composeFile up -d --remove-orphans

    if ($LASTEXITCODE -ne 0)
    {
        Write-Host "[infra-up.ps1:Error] Failed to launch $composeFile" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

Write-Host "[infra-up.ps1] Platform infrastructure started successfully" -ForegroundColor Green

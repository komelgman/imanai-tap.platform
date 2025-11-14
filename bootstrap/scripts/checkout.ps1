param(
    [string]$ServiceName,
    [string]$Repo,
    [string]$TargetDir
)

Write-Host "[checkout.ps1] ServiceName = $ServiceName"
Write-Host "[checkout.ps1] Repository = $Repo"
Write-Host "[checkout.ps1] TargetDir = $TargetDir"

$ServicePath = Join-Path $TargetDir $ServiceName
if (-not (Test-Path "$ServicePath/.git")) {
    git clone $Repo $ServicePath
} else {
    git -C $ServicePath pull
}
param(
    [string]$PlatformBaseDir
)

$HooksDir = "$PlatformBaseDir/.github/hooks"

if (-not (Test-Path $HooksDir -PathType Container)) {
    Write-Error "[install-git-hooks.ps1:error] '$HooksDir' not found."
    exit 1
}

git config core.hooksPath $HooksDir

Write-Host "[install-git-hooks.ps1] Git hooks configured via core.hooksPath" -ForegroundColor Green

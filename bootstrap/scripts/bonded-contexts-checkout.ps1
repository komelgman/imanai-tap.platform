param(
    [string]$PlatformDir,
    [string]$ConfigFile
)

try {
    $BoundedContextsDir = yq ".platform.boundedContexts.dir" $ConfigFile
    $BoundedContextsFullPath = [IO.Path]::GetFullPath("$PlatformDir/$BoundedContextsDir")
    $Services = yq ".platform.boundedContexts.services[].name" $ConfigFile | ForEach-Object { $_.Trim() }

    if (-not (Test-Path $BoundedContextsFullPath)) {
        Write-Warning "[bounded-contexts-checkout.ps1] Directory does not exist, creating: $BoundedContextsFullPath"
        New-Item -ItemType Directory -Path $BoundedContextsFullPath -Force | Out-Null
    }

    $BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path

    foreach ($svc in $Services) {
        Write-Host "[bounded-contexts-checkout.ps1] Checking out '$svc'..."

        $RepoFilter = ".platform.boundedContexts.services[] | select(.name == \`"$svc\`") | .repo"
        $Repo = yq $RepoFilter $ConfigFile

        & "$BaseDir/checkout.ps1" $svc $Repo $BoundedContextsFullPath
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to checkout service '$svc'"
            continue
        }

        $ServicePath = Join-Path $BoundedContextsFullPath $svc
        $BootstrapScript = Join-Path $ServicePath "bootstrap/main.ps1"

        if (Test-Path $BootstrapScript) {
            Write-Host "[bounded-contexts-checkout.ps1] Running bootstrap for '$svc'..."

            try {
                Push-Location $ServicePath
                & $BootstrapScript

                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[bounded-contexts-checkout.ps1] Bootstrap completed successfully for '$svc'" -ForegroundColor Green
                } else {
                    Write-Warning "[bounded-contexts-checkout.ps1] Bootstrap failed for '$svc' with exit code $LASTEXITCODE"
                }
            } catch {
                Write-Error "[bounded-contexts-checkout.ps1] Bootstrap error for '$svc': $_"
            } finally {
                Pop-Location
            }
        } else {
            Write-Host "[bounded-contexts-checkout.ps1] No bootstrap script found for '$svc'" -ForegroundColor DarkGray
        }
    }
} catch {
    Write-Error "[bounded-contexts-checkout.ps1] Fatal error: $_"
    exit 1
}

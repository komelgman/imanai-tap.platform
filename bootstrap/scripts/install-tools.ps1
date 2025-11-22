$ErrorActionPreference = "Stop"

# Configuration
$Config = @{
    YqVersion = "4.43.1"
    GhVersion = "2.83.1"
    ScriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
$Config.ToolsDir = Join-Path $Config.ScriptsDir "../.tools"

# Initialize tools directory
if (-not (Test-Path $Config.ToolsDir)) {
    Write-Host "[install-tools.ps1] Creating tools directory: $($Config.ToolsDir)"
    New-Item -ItemType Directory -Path $Config.ToolsDir -Force | Out-Null
}

$env:PATH = "$($Config.ToolsDir);$env:PATH"

function Test-ToolInstalled {
    param([string]$ExeName, [string]$LocalPath)

    if (Test-Path $LocalPath) { return "local" }
    if (Get-Command $ExeName -ErrorAction SilentlyContinue) { return "global" }
    return $null
}

function Get-FileSecure {
    param([string]$Url, [string]$OutFile, [int]$MinSize = 1000)

    Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing

    if (-not (Test-Path $OutFile)) {
        throw "Download failed: file not found"
    }

    $size = (Get-Item $OutFile).Length
    if ($size -lt $MinSize) {
        throw "Download failed: file too small ($size bytes, expected >$MinSize)"
    }
}

function Install-SimpleTool {
    param(
        [string]$Name,
        [string]$ExeName,
        [string]$Url,
        [string]$Version
    )

    $toolPath = Join-Path $Config.ToolsDir $ExeName
    $status = Test-ToolInstalled -ExeName $ExeName -LocalPath $toolPath

    switch ($status) {
        "local" {
            Write-Host "[install-tools.ps1] $Name already installed locally"
            return
        }
        "global" {
            Write-Host "[install-tools.ps1] $Name found in PATH, skipping local install"
            return
        }
    }

    Write-Host "[install-tools.ps1] Installing $Name $Version..."

    try {
        Get-FileSecure -Url $Url -OutFile $toolPath
        Write-Host "[install-tools.ps1] Successfully installed $Name"
    }
    catch {
        if (Test-Path $toolPath) { Remove-Item $toolPath -Force }
        throw "[install-tools.ps1] Failed to install ${Name}: $($_.Exception.Message)"
    }
}

function Install-ArchivedTool {
    param(
        [string]$Name,
        [string]$ExeName,
        [string]$Url,
        [string]$Version
    )

    $toolPath = Join-Path $Config.ToolsDir $ExeName
    $status = Test-ToolInstalled -ExeName $ExeName -LocalPath $toolPath

    switch ($status) {
        "local" {
            Write-Host "[install-tools.ps1] $Name already installed locally"
            return
        }
        "global" {
            Write-Host "[install-tools.ps1] $Name found in PATH, skipping local install"
            return
        }
    }

    Write-Host "[install-tools.ps1] Installing $Name $Version..."

    $zipPath = Join-Path $Config.ToolsDir "temp_$Name.zip"
    $extractPath = Join-Path $Config.ToolsDir "temp_${Name}_extract"

    try {
        Get-FileSecure -Url $Url -OutFile $zipPath -MinSize 10000

        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

        $exeFile = Get-ChildItem -Path $extractPath -Filter $ExeName -Recurse -File |
                Select-Object -First 1

        if (-not $exeFile) {
            throw "$ExeName not found in archive"
        }

        Move-Item $exeFile.FullName -Destination $toolPath -Force
        Write-Host "[install-tools.ps1] Successfully installed $Name"
    }
    catch {
        throw "[install-tools.ps1] Failed to install ${Name}: $($_.Exception.Message)"
    }
    finally {
        # Cleanup regardless of success/failure
        @($zipPath, $extractPath) | Where-Object { Test-Path $_ } |
                ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

# Install tools
$yqUrl = "https://github.com/mikefarah/yq/releases/download/v$($Config.YqVersion)/yq_windows_amd64.exe"
Install-SimpleTool -Name "yq" -ExeName "yq.exe" -Url $yqUrl -Version $Config.YqVersion

$ghUrl = "https://github.com/cli/cli/releases/download/v$($Config.GhVersion)/gh_$($Config.GhVersion)_windows_amd64.zip"
Install-ArchivedTool -Name "GitHub CLI" -ExeName "gh.exe" -Url $ghUrl -Version $Config.GhVersion

Write-Host "[install-tools.ps1] All tools installed successfully!" -ForegroundColor Green

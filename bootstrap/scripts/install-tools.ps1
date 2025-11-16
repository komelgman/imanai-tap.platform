$YqVersion = "v4.43.1"
$ScriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ToolsDir = "$ScriptsDir/../.tools"

if (-not (Get-Command yq -ErrorAction SilentlyContinue))
{
    Write-Host "[install-tools.ps1] yq not found, installing locally..."
    $Url = "https://github.com/mikefarah/yq/releases/download/$YqVersion/yq_windows_amd64.exe"
    Invoke-WebRequest -Uri $Url -OutFile "$ToolsDir/yq.exe"
}

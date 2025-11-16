param(
    [string]$PlatformDir,
    [string]$ConfigFile
)

$BoundedContextsDir = yq ".platform.boundedContexts.dir" $ConfigFile
$BoundedContextsFullPath = [IO.Path]::GetFullPath("$PlatformDir/$BoundedContextsDir")
$Services = yq ".platform.boundedContexts.services[].name" $ConfigFile | ForEach-Object { $_.Trim() }

$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
foreach ($svc in $Services)
{
    Write-Host "[bounded-contexts-checkout.ps1] checkout '$svc'..."
    $RepoFilter = ".platform.boundedContexts.services[] | select(.name == \`"$svc\`") | .repo"
    $Repo = yq $RepoFilter $ConfigFile

    & "$BaseDir/checkout.ps1" $svc $Repo $BoundedContextsFullPath
}

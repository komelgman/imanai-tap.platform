$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PlatformBaseDir = "$BaseDir/../"

& "$BaseDir/scripts/install-tools.ps1"
& "$BaseDir/scripts/install-git-hooks.ps1" $PlatformBaseDir

$ToolsDir = "$BaseDir/.tools"
$env:PATH = "$ToolsDir;$env:PATH"
$ConfigFile = "$BaseDir/../platform-config.yaml"

& "$BaseDir/scripts/bonded-contexts-checkout.ps1" $PlatformBaseDir $ConfigFile


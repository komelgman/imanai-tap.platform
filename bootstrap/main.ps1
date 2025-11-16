$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PlatformBaseDir = "$BaseDir/../"

& "$BaseDir/scripts/install-tools.ps1"
& "$BaseDir/scripts/install-precommit-hooks.ps1"

$ToolsDir = "$BaseDir/.tools"
$env:PATH = "$ToolsDir;$env:PATH"
$ConfigFile = "$BaseDir/../platform-config.yaml"

& "$BaseDir/scripts/bonded-contexts-checkout.ps1" $PlatformBaseDir $ConfigFile


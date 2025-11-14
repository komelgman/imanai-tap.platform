$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$BootstrapDir = "$BaseDir/bootstrap"
$ToolsDir = "$BootstrapDir/.tools"
$env:PATH = "$ToolsDir;$env:PATH"

$ScriptsDir = "$BaseDir/deployment/docker-compose/scripts"
$ConfigFile = "$BaseDir/platform-config.yaml"

& "$ScriptsDir/bounded-contexts-compose-up.ps1" $BaseDir $ConfigFile
$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$BootstrapDir = "$BaseDir/bootstrap"
$ToolsDir = "$BootstrapDir/.tools"
$env:PATH = "$ToolsDir;$env:PATH"

$ScriptsDir = "$BaseDir/deployment/docker-compose/scripts"
$ConfigFile = "$BaseDir/platform-config.yaml"

& "$ScriptsDir/bounded-contexts-down.ps1" $BaseDir $ConfigFile

& "$ScriptsDir/infra-down.ps1" $BaseDir $ConfigFile

& "$ScriptsDir/remove-docker-network.ps1" $ConfigFile
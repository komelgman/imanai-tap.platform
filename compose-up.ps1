$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$BootstrapDir = "$BaseDir/bootstrap"
$ToolsDir = "$BootstrapDir/.tools"
$env:PATH = "$ToolsDir;$env:PATH"

$ScriptsDir = "$BaseDir/deployment/docker-compose/scripts"
$ConfigFile = "$BaseDir/platform-config.yaml"

& "$ScriptsDir/add-docker-network.ps1" $ConfigFile

& "$ScriptsDir/infra-up.ps1" $BaseDir $ConfigFile

& "$ScriptsDir/bounded-contexts-up.ps1" $BaseDir $ConfigFile $args
$WorkspaceDir = "./docs"
$AbsolutePath = (Resolve-Path $WorkspaceDir).Path
$LocalPort = 9877

if (-not (Test-Path -Path $WorkspaceDir -PathType Container)) {
    Write-Host "Warning: The '$WorkspaceDir' folder was not found." -ForegroundColor Yellow
    Write-Host "Please create it and place your 'workspace.dsl' file inside." -ForegroundColor Yellow
}

Write-Host "=============================================" -ForegroundColor Green
Write-Host " Structurizr Site Gen is running in dev mode" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""
Write-Host " Your workspace (from the $WorkspaceDir folder) is available at:" -ForegroundColor Cyan
Write-Host "   => http://localhost:$LocalPort/" -ForegroundColor Cyan
Write-Host ""
Write-Host "To stop the service and exit, press Ctrl+C." -ForegroundColor DarkGray
Write-Host ""

docker run -it --rm -p "$LocalPort`:8080" -v "${AbsolutePath}:/var/model" ghcr.io/avisi-cloud/structurizr-site-generatr serve --workspace-file workspace.dsl --assets-dir assets


Write-Host "`nService stopped. Goodbye!" -ForegroundColor Green

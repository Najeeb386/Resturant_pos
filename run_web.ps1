# Powershell helper to build and host the POS Web application locally for testing

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "1. Building Flutter Web Application..." -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

cd resturant_pos_app
flutter build web

if ($LASTEXITCODE -ne 0) {
    Write-Host "Flutter Web compilation failed!" -ForegroundColor Red
    Exit
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Green
Write-Host "2. Starting Local Web Server (Python) on http://localhost:8000" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host "Open http://localhost:8000 in your browser to test the web client."
Write-Host "Press Ctrl+C in this terminal to stop the server."
Write-Host ""

python -m http.server 8000 --directory build\web

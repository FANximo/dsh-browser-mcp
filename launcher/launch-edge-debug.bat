@echo off
rem Debug launcher: same logic as start-browser.ps1 with a console window for troubleshooting.
rem Daily use: double-click the .vbs file instead (silent, no black box).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-browser.ps1"
echo.
timeout /t 4 >nul
exit /b 0
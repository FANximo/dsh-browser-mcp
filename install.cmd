@echo off
rem dsh-browser-mcp - double-click launcher for the portable installer.
setlocal
set "HERE=%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%install.ps1" %*
set RC=%ERRORLEVEL%
echo.
if not "%RC%"=="0" echo Installer exited with code %RC%.
pause
endlocal
exit /b %RC%
# Start (or reuse) the debugging Edge window that the browser MCP server attaches to.
# Modes: CDP endpoint http://127.0.0.1:9222, dedicated profile ./profile (keeps Taobao login).
# ASCII-only on purpose: Windows PowerShell 5.1 mis-decodes UTF-8 files without BOM.

$ErrorActionPreference = 'Stop'

$root    = Split-Path -Parent $MyInvocation.MyCommand.Path
$profile = Join-Path $root 'profile'

$edge = $null
foreach ($p in @(
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "$env:LOCALAPPDATA\Microsoft\Edge\Application\msedge.exe"
)) { if (-not $edge -and (Test-Path $p)) { $edge = $p } }
if (-not $edge) {
    try {
        $k = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe' -ErrorAction SilentlyContinue
        if ($k -and (Test-Path $k.'(default)')) { $edge = $k.'(default)' }
    } catch { }
}
if (-not $edge) {
    try {
        $k = Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe' -ErrorAction SilentlyContinue
        if ($k -and (Test-Path $k.'(default)')) { $edge = $k.'(default)' }
    } catch { }
}
if (-not $edge) { Write-Host '[ERROR] msedge.exe not found - install Microsoft Edge first.'; exit 1 }
if (-not (Test-Path $profile)) { New-Item -ItemType Directory -Path $profile -Force | Out-Null }

function Test-Cdp {
    try {
        $r = Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:9222/json/version' -TimeoutSec 3
        return ($r.StatusCode -eq 200)
    } catch { return $false }
}

if (Test-Cdp) {
    Write-Host '[OK] CDP 9222 is already up - reuse the existing window.'
    exit 0
}

$edgeArgs = @(
    '--remote-debugging-port=9222',
    "--user-data-dir=$profile",
    '--lang=zh-CN',
    '--no-first-run',
    '--no-default-browser-check',
    '--disable-blink-features=AutomationControlled'
)
Start-Process -FilePath $edge -ArgumentList $edgeArgs

for ($i = 0; $i -lt 24; $i++) {
    Start-Sleep -Milliseconds 500
    if (Test-Cdp) {
        Write-Host '[OK] Edge is ready on 9222. Go back to DSH and let the agent drive it.'
        exit 0
    }
}

Write-Host '[WARN] Port 9222 not listening after 12s. Check for security software blocking it.'
exit 1
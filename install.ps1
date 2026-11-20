# dsh-browser-mcp portable installer - self-deploying, no manual path editing.
# ASCII-only on purpose: Windows PowerShell 5.1 mis-decodes UTF-8 scripts without BOM.
#
# What it does, in order:
#   1. finds node.exe (PATH, DSH bundle runtimes, Program Files, registry)
#   2. checks the bundled MCP runtime (@playwright/mcp) -> no npm, no network
#   3. rewrites bundle\cordis.patch.yml with the real absolute paths of THIS folder
#   4. finds the DSH home + profile, installs the bundle into the profile (backup kept)
#   5. starts the debugging Edge window on port 9222
#
# Usage:
#   install.cmd                       (double-click: same as below)
#   powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1
#   ...\install.ps1 -CheckOnly        # verify payload + node only, change nothing
#   ...\install.ps1 -NoStartEdge      # do not launch Edge
#   ...\install.ps1 -NoRegister       # do not touch any DSH profile
#   ...\install.ps1 -Profile bili-duty # register into a different profile name
param(
    [string]$NodePath,
    [string]$Profile = 'desktop',
    [switch]$CheckOnly,
    [switch]$NoRegister,
    [switch]$NoStartEdge
)

$ErrorActionPreference = 'Stop'
$root     = Split-Path -Parent $MyInvocation.MyCommand.Path
$runtime  = Join-Path $root 'runtime'
$launcher = Join-Path $root 'launcher'
$bundle   = Join-Path $root 'bundle'
$pkgName  = '@local/dsh-browser-mcp'

function Fail($msg) { Write-Host ''; Write-Host "[ERROR] $msg" -ForegroundColor Red; Write-Host ''; exit 1 }
function Ok($msg)   { Write-Host "[OK]   $msg" -ForegroundColor Green }
function Info($msg) { Write-Host "[..]   $msg" }
function Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }

Write-Host ''
Write-Host '  dsh-browser-mcp - portable bundle installer' -ForegroundColor Cyan
Write-Host "  folder: $root"
Write-Host ''

# ---------------------------------------------------------------- 1. payload
foreach ($f in @('bundle\package.json', 'bundle\cordis.patch.yml', 'launcher\playwright-mcp.config.json',
                 'launcher\stealth.js', 'launcher\start-browser.ps1')) {
    if (-not (Test-Path (Join-Path $root $f))) { Fail "package is incomplete: missing $f" }
}
Ok 'payload files present'

$cli = Join-Path $runtime 'node_modules\@playwright\mcp\cli.js'
if (-not (Test-Path $cli)) {
    Fail ('the bundled MCP runtime is missing (runtime\node_modules\@playwright\mcp\cli.js).' +
          ' Re-extract the zip - it already contains everything, no npm needed.')
}
Ok 'bundled MCP runtime present (no download needed)'

# ---------------------------------------------------------------- 2. node
function Test-Node($p) { $p -and (Test-Path $p) }

if (-not $NodePath) {
    $c = Get-Command node.exe -ErrorAction SilentlyContinue
    if ($c) { $NodePath = $c.Source }
}
if (-not (Test-Node $NodePath)) {
    $w = Get-Command where.exe -ErrorAction SilentlyContinue
    if ($w) {
        # native stderr must not abort the script (PS 5.1 turns it into a terminating error when EAP=Stop)
        $prevEap = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $found = (& where.exe node.exe 2>$null | Where-Object { $_ -and $_ -notmatch 'INFO:' } | Select-Object -First 1)
            if ($found) { $NodePath = $found.Trim() }
        } catch { }
        $ErrorActionPreference = $prevEap
    }
}
if (-not (Test-Node $NodePath)) {
    $cands = @(
        "$env:ProgramFiles\nodejs\node.exe",
        "${env:ProgramFiles(x86)}\nodejs\node.exe",
        "$env:LOCALAPPDATA\Programs\nodejs\node.exe"
    )
    # every DSH bundle runtime on any fixed drive
    foreach ($d in (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -ne $null })) {
        $cands += (Join-Path $d.Root 'DSH\home\dsh-runtimes\dsh-primary-runtime\dependencies\node\bin\node.exe')
        $cands += (Join-Path $d.Root 'dsh\home\dsh-runtimes\dsh-primary-runtime\dependencies\node\bin\node.exe')
    }
    foreach ($p in $cands) { if (Test-Node $p) { $NodePath = $p; break } }
}
if (-not (Test-Node $NodePath)) {
    try {
        $reg = Get-ItemProperty 'HKLM:\SOFTWARE\Node.js' -ErrorAction SilentlyContinue
        if ($reg -and $reg.InstallPath) {
            $p = Join-Path $reg.InstallPath 'node.exe'
            if (Test-Node $p) { $NodePath = $p }
        }
    } catch { }
}
if (-not (Test-Node $NodePath)) {
    Fail ('node.exe not found. Install the DeepSeek Harness desktop app or Node.js 20+ first, ' +
          'or rerun with -NodePath "<full path to node.exe>".')
}
$nodeVer = (& $NodePath --version 2>$null)
Ok "node: $NodePath ($nodeVer)"
$nodeDir = Split-Path -Parent $NodePath
$nodeFwd = $NodePath.Replace('\', '/')

if ($CheckOnly) {
    Info 'CheckOnly: nothing was written.'
    exit 0
}

# ---------------------------------------------------------------- 3. cordis patch
$cliFwd    = $cli.Replace('\', '/')
$configFwd = (Join-Path $launcher 'playwright-mcp.config.json').Replace('\', '/')
$cwdFwd    = $launcher.Replace('\', '/')

$patch = @"
# Generated by install.ps1 - absolute paths of THIS folder, nothing machine specific.
- insert:
    - id: browser-mcp
      name: '@deepseek-ai/dsh-mcp-client'
      config:
        serverName: browser
        transport: stdio
        command: '$nodeFwd'
        args:
          - '$cliFwd'
          - '--config'
          - '$configFwd'
        cwd: '$cwdFwd'
        failOnStartupError: true
"@
Set-Content -Path (Join-Path $bundle 'cordis.patch.yml') -Value ($patch -replace "`r`n", "`n") -Encoding ASCII -NoNewline
Ok 'bundle\cordis.patch.yml rewritten with this folder''s paths'

if (-not (Test-Path (Join-Path $launcher 'output'))) {
    New-Item -ItemType Directory -Path (Join-Path $launcher 'output') -Force | Out-Null
}

# ---------------------------------------------------------------- 4. DSH profile
function Find-DshHome {
    $c = @()
    if ($env:DSH_HOME) { $c += $env:DSH_HOME }
    $c += @("$env:USERPROFILE\.dsh", "$env:APPDATA\DSH\home", "$env:LOCALAPPDATA\DSH\home", "$env:ProgramData\DSH\home")
    foreach ($d in (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -ne $null })) {
        $c += @((Join-Path $d.Root 'DSH\home'), (Join-Path $d.Root 'dsh\home'), (Join-Path $d.Root 'DSH'))
    }
    foreach ($h in $c) {
        if ($h -and (Test-Path (Join-Path $h 'profiles'))) { return $h }
    }
    # last resort: one level down from each drive root
    foreach ($d in (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -ne $null })) {
        $tops = Get-ChildItem $d.Root -Directory -ErrorAction SilentlyContinue
        foreach ($t in $tops) {
            $inner = Join-Path $t.FullName 'home\profiles'
            if (Test-Path $inner) { return (Join-Path $t.FullName 'home') }
        }
    }
    return $null
}

if ($NoRegister) {
    Warn 'NoRegister: skipped DSH profile registration.'
    $dshHome = $null
} else {
    $dshHome = Find-DshHome
    if (-not $dshHome) { Warn 'no DSH home found - install DeepSeek Harness, then rerun install.ps1.' }
}

if ($dshHome) {
    Ok "DSH home: $dshHome"
    $profileDir = Join-Path $dshHome "profiles\$Profile"
    if (-not (Test-Path $profileDir)) {
        $first = Get-ChildItem (Join-Path $dshHome 'profiles') -Directory -ErrorAction SilentlyContinue |
                 Where-Object { Test-Path (Join-Path $_.FullName 'package.json') } | Select-Object -First 1
        if ($first) { $profileDir = $first.FullName; Warn "profile '$Profile' not found, using '$($first.Name)'" }
    }
    $pkgJson = Join-Path $profileDir 'package.json'
    if (-not (Test-Path $pkgJson)) { Fail "profile package.json not found: $pkgJson" }

    Copy-Item $pkgJson ($pkgJson + '.bak-browser') -Force
    $j = Get-Content $pkgJson -Raw | ConvertFrom-Json

    $bundleFwd = $bundle.Replace('\', '/')
    if (-not $j.dependencies) { $j | Add-Member -NotePropertyName dependencies -NotePropertyValue ([pscustomobject]@{}) }
    $j.dependencies | Add-Member -NotePropertyName $pkgName -NotePropertyValue ("link:" + $bundleFwd) -Force

    if (-not $j.dsh) { $j | Add-Member -NotePropertyName dsh -NotePropertyValue ([pscustomobject]@{}) }
    if (-not $j.dsh.profile) { $j.dsh | Add-Member -NotePropertyName profile -NotePropertyValue ([pscustomobject]@{}) }
    $bundles = @()
    if ($j.dsh.profile.bundles) { $bundles = @($j.dsh.profile.bundles) }
    if ($bundles -notcontains $pkgName) { $bundles += $pkgName }
    $j.dsh.profile | Add-Member -NotePropertyName bundles -NotePropertyValue $bundles -Force

    $json = $j | ConvertTo-Json -Depth 30
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText($pkgJson, $json, $utf8)
    Ok "registered in profile: $profileDir (backup: package.json.bak-browser)"

    # make it resolvable without pnpm: real folder under node_modules
    $target = Join-Path $profileDir ("node_modules\@local\dsh-browser-mcp")
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
    New-Item -ItemType Directory -Path (Split-Path $target -Parent) -Force | Out-Null
    Copy-Item $bundle $target -Recurse -Force
    Ok "bundle copied to $target"
}

# ---------------------------------------------------------------- 5. Edge
if (-not $NoStartEdge) {
    $starter = Join-Path $launcher 'start-browser.ps1'
    Info 'starting the debugging Edge window (port 9222)...'
    & powershell -NoProfile -ExecutionPolicy Bypass -File $starter
}

Write-Host ''
Ok 'installation finished. next:'
Write-Host '   1) restart the DeepSeek Harness app so it loads the new plugin'
Write-Host '   2) ask the agent: "list the browser tabs"'
Write-Host '      tools show up as mcp__browser__browser_*  (25 tools)'
Write-Host ''
Info "keep this folder in place - the Edge login profile lives in $launcher\profile (created on first Edge run)."
Info 'to undo: restore package.json.bak-browser in the profile folder and delete node_modules\@local\dsh-browser-mcp.'
Write-Host ''
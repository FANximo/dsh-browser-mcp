# dsh-browser-mcp bootstrap installer
#
# Downloads the portable release asset from GitHub, expands it into a temp
# folder, runs its install.ps1, then deletes the temp folder.
#
# One-liner (PowerShell):
#   irm https://raw.githubusercontent.com/FANximo/dsh-browser-mcp/main/bootstrap.ps1 | iex
#
# Optional overrides (set as environment variables before running):
#   $env:BMC_VERSION     release version to fetch        (default 1.3.1)
#   $env:BMC_REPO        owner/repo                      (default FANximo/dsh-browser-mcp)
#   $env:BMC_NODE_PATH   node.exe to use                 (default: autodetect)
#   $env:BMC_CHECKONLY   "1" to only run the checks
#   $env:BMC_NOREGISTER  "1" to skip DSH registration
#   $env:BMC_NOSTARTEDGE "1" to skip starting the browser
#
# The same switches are accepted as arguments when the file is run directly:
#   powershell -ExecutionPolicy Bypass -File bootstrap.ps1 -CheckOnly

$BmcArgs = @($args)
$BmcExit = 1

& {
  $ErrorActionPreference = 'Stop'
  $ProgressPreference = 'SilentlyContinue'
  try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 } catch {}

  $version = '1.3.1'
  if ($env:BMC_VERSION) { $version = $env:BMC_VERSION }
  $repo = 'FANximo/dsh-browser-mcp'
  if ($env:BMC_REPO) { $repo = $env:BMC_REPO }

  $flagCheck = ($env:BMC_CHECKONLY -eq '1')
  $flagNoReg = ($env:BMC_NOREGISTER -eq '1')
  $flagNoEdge = ($env:BMC_NOSTARTEDGE -eq '1')
  foreach ($a in $BmcArgs) {
    if ($a -eq '-CheckOnly') { $flagCheck = $true }
    elseif ($a -eq '-NoRegister') { $flagNoReg = $true }
    elseif ($a -eq '-NoStartEdge') { $flagNoEdge = $true }
    elseif ($a -match '^-NodePath=(.+)$') { $env:BMC_NODE_PATH = $Matches[1] }
  }

  $asset = "dsh-browser-mcp-portable-v$version.zip"
  $url = "https://github.com/$repo/releases/download/v$version/$asset"
  $temp = Join-Path ([IO.Path]::GetTempPath()) ("browser-mcp-" + [Guid]::NewGuid().ToString('N').Substring(0, 8))
  New-Item -ItemType Directory -Path $temp -Force | Out-Null

  $code = 1
  try {
    $zip = Join-Path $temp $asset
    Write-Host "Downloading $url"
    try {
      Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
    } catch {
      Write-Host ("Invoke-WebRequest failed: {0}" -f $_.Exception.Message)
      Write-Host "Trying curl.exe"
      $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
      if (-not $curl) { throw "Cannot download $url. Download $asset manually and run install.cmd inside it." }
      & curl.exe -L --fail --ssl-no-revoke -o $zip $url
      if ($LASTEXITCODE -ne 0) { throw "curl.exe failed to download $url" }
    }
    Write-Host ("Downloaded {0:N0} bytes" -f (Get-Item $zip).Length)

    Write-Host "Extracting"
    Expand-Archive -LiteralPath $zip -DestinationPath $temp -Force
    $payload = Join-Path $temp 'dsh-browser-mcp-portable'
    $installer = Join-Path $payload 'install.ps1'
    if (-not (Test-Path $installer)) { throw "install.ps1 is missing from the archive" }

    $installArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $installer)
    if ($flagCheck) { $installArgs += '-CheckOnly' }
    if ($flagNoReg) { $installArgs += '-NoRegister' }
    if ($flagNoEdge) { $installArgs += '-NoStartEdge' }
    if ($env:BMC_NODE_PATH) { $installArgs += @('-NodePath', $env:BMC_NODE_PATH) }

    Write-Host "Running installer"
    & powershell.exe @installArgs
    $code = $LASTEXITCODE
    Write-Host ("Installer finished with exit code {0}" -f $code)
  } catch {
    Write-Host ("Install failed: {0}" -f $_.Exception.Message)
    $code = 1
  } finally {
    Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
  }

  if ($code -ne 0) {
    Write-Host "Manual fallback: download $asset from https://github.com/$repo/releases and run install.cmd"
  }
  $script:BmcCode = $code
  $global:LASTEXITCODE = $code
}

$BmcExit = $script:BmcCode
if ($BmcExit -eq $null) { $BmcExit = 1 }
# Under `irm ... | iex` there is no script path, and `exit` there would close the
# user's PowerShell session, so only a real -File run reports a process exit code.
if ($PSCommandPath) { exit $BmcExit }
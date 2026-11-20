# dsh-browser-mcp

A DSH plugin that lets the agent drive **your own Microsoft Edge** through CDP 鈥?so it can read pages you are already logged in to (orders, tracking, product pages) instead of asking you for screenshots.

Tools show up as `mcp__browser__browser_*` (25 of them: navigate, snapshot, click, type, screenshot, wait, evaluate, 鈥?.

- Real Edge engine, dedicated persistent profile, reduced automation fingerprint
- No re-login, no captcha solving: it attaches to a window **you** signed in to
- Browse and read only 鈥?the agent is told never to order, pay, or confirm receipt
- Self-contained portable bundle: **no npm, no network** needed at install time

---

## Install with one command

PowerShell (no clone, no npm):

```powershell
irm https://raw.githubusercontent.com/FANximo/dsh-browser-mcp/main/bootstrap.ps1 | iex
```

It downloads the release asset, expands it to a temp folder, finds `node.exe`, registers the bundle in your DSH profile, starts the dedicated Edge window, and deletes the temp folder. Then restart DeepSeek Harness.

Checks only, change nothing:

```powershell
$env:BMC_CHECKONLY='1'; irm https://raw.githubusercontent.com/FANximo/dsh-browser-mcp/main/bootstrap.ps1 | iex
```

If `raw.githubusercontent.com` is slow or blocked, use the release asset instead (see [Quick start](#quick-start)) 鈥?it is the same thing without the download step.

## Quick start

1. **Download** `dsh-browser-mcp-portable-v1.3.1.zip` from [Releases](../../releases).
2. **Extract** to a permanent folder, e.g. `D:\tools\dsh-browser-mcp`.
   Don't use the Desktop or a temp folder 鈥?the Edge login profile is stored next to the app.
3. **Double-click `install.cmd`.** It:
   - finds `node.exe` (PATH 鈫?registry 鈫?Program Files 鈫?the runtime that ships with DSH),
   - uses the bundled MCP runtime (no `npm install`, no internet),
   - rewrites `bundle\cordis.patch.yml` with **this** folder's absolute paths,
   - finds your DSH home/profile and registers the plugin (keeps a `package.json.bak-browser` backup),
   - starts the dedicated Edge window on port 9222.
4. **Restart DeepSeek Harness**, then ask the agent: *鈥渓ist the browser tabs鈥?.

Command-line equivalents:

```powershell
.\install.ps1              # same as double-clicking install.cmd
.\install.ps1 -CheckOnly   # verify node + payload only, change nothing
.\install.ps1 -NoStartEdge # do not launch Edge
.\install.ps1 -Profile bili-duty        # register into a different profile
.\install.ps1 -NodePath "C:\Program Files\nodejs\node.exe"
```

## Requirements

| | |
|---|---|
| OS | Windows 10/11 |
| DSH | desktop app, 0.2.x |
| Node.js | 20+ (DSH ships one; the installer finds it) |
| Browser | Microsoft Edge (ships with Windows) |

## Daily use

- The debugging Edge window is started by the installer. Later, double-click `launcher\鍚姩璋冭瘯娴忚鍣?vbs` (or `launcher\launch-edge-debug.bat` if you want the console output); an already-running window is reused.
- Then just talk to the agent: *鈥渙pen Taobao and check my recent orders鈥?, *鈥渨here is this parcel鈥?.
- That window is a separate Edge profile, independent from your everyday browser. Sign in once, it stays signed in.

## What it does not do

- Does not order, pay, confirm receipt, or change account settings.
- Does not ship any cookies, tokens, or personal data 鈥?the login profile is created on **your** machine, in `launcher\profile`.
- Does not phone home.

## Layout

```
bootstrap.ps1               one-command installer used by the irm one-liner
install.cmd / install.ps1   one-click installer (self-deploying)
runtime-package.json        dependency list of the bundled MCP runtime (reference)
runtime\                    pre-installed @playwright/mcp 0.0.85 (~18 MB, offline)
bundle\                     the DSH plugin itself (what DSH loads)
  cordis.patch.yml          launch config 鈥?rewritten by install.ps1
  package.json  icon.svg  locale\
launcher\
  鍚姩璋冭瘯娴忚鍣?vbs           daily "start the debugging browser"
  launch-edge-debug.bat     same, with console output
  start-browser.ps1         the actual launcher logic
  playwright-mcp.config.json  CDP endpoint, timeouts, outputDir
  stealth.js                strips automation fingerprints
  safety.md                 security boundary the agent must follow
```

After the first Edge run you also get `launcher\profile\` (your logins) and `launcher\output\` (screenshots). **Never share those two.**

## Troubleshooting

| Symptom | Fix |
|---|---|
| `node.exe not found` | install Node.js 20+, or pass `-NodePath "<full path>"` |
| `install.cmd` closes instantly | run `install.cmd -CheckOnly` from a terminal to see the error |
| `connect ECONNREFUSED 127.0.0.1:9222` | the debugging Edge window isn't up 鈥?run the .vbs; check nothing else holds 9222 |
| No `mcp__browser__*` tools in DSH | 鈶?`@local/dsh-browser-mcp` in the profile's `dsh.profile.bundles`? 鈶?did DSH really restart? 鈶?is `cdpEndpoint` still `http://127.0.0.1:9222`? |
| Moved the folder | run `install.cmd` again 鈥?it rewrites every path; logins may need redoing |

## Uninstall

Restore `package.json.bak-browser` in your DSH profile folder, delete the profile's `node_modules\@local\dsh-browser-mcp`, and delete this folder.

## License

MIT
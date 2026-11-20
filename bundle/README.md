# Browser takeover

Connects a Playwright-driven Microsoft Edge browser to DeepSeek Harness as the `browser` MCP server, so the agent can read Taobao pages directly (orders, logistics, products) instead of asking for screenshots.

Version 1.3.0 is self-deploying: run `install.cmd` once inside the extracted folder and it resolves node, rewrites the launch config with that folder's own absolute paths, registers itself into your DSH profile, and starts the debugging Edge window. No npm, no network, nothing to edit by hand.

The browser itself is hardened against account risk control: real Edge engine, persistent signed-in profile, reduced automation fingerprinting, human-like action pacing, and idle auto-close.

## What it adds

- Tools named `mcp__browser__browser_*` (navigate, snapshot, click, type, screenshot, wait, etc.).
- A dedicated Edge profile stored in `launcher/profile` inside the workspace; output files go to `launcher/output`.
- No automatic ordering or payment. The agent should only browse and read.

## Configuration

The server is launched with a single config file, `launcher/playwright-mcp.config.json`:

| Setting | Value | Why |
|---|---|---|
| `channel` | `msedge` | Uses the installed Edge 157, so engine/UA/TLS fingerprints match a normal user |
| `userDataDir` | `./profile` | Same device and same session every time; login persists across restarts |
| `slowMo` | `150` ms | Human speed per action |
| `timeouts.settle` | `1500` ms | Minimum gap after every action |
| `timeouts.idle` | `1800000` ms | Closes the browser after 30 min idle, relaunches on demand |
| `initScript` | `./stealth.js` | Removes `navigator.webdriver`, restores `window.chrome`, fixes `zh-CN` languages |
| `locale` / `timezoneId` | `zh-CN` / `Asia/Shanghai` | Matches the real user's location |
| `webmcp` | `false` | Pages cannot register tools the agent might call |
| `outputMaxSize` | `200 MiB` | Evicts old screenshots automatically |

Launch args additionally pass `--disable-blink-features=AutomationControlled`.

## First use

1. Call any `mcp__browser__browser_*` tool (for example `browser_navigate` to `https://www.taobao.com`). An Edge window opens.
2. Sign in manually: in the Edge window choose 扫码登录 and scan the QR code with the Taobao mobile app. The agent cannot and should not type your password.
3. The session is saved in the profile directory, so later calls stay signed in. Signing out in the window clears it.
4. If Taobao shows a slider or SMS verification, complete it by hand in that window.

## Security and limits

- The browser profile contains your Taobao login cookies; treat `launcher/profile` as sensitive. Delete it to sign out permanently.
- Only browse and read. Do not confirm receipt, submit orders, pay, or change account settings without explicit per-action approval from you.
- Taobao may flag automated browsing; the full pacing and stop rules are in `launcher/safety.md`. Summary: no bulk pagination, no polling the same page, at most about 5 cart writes per session with 5 s spacing, and stop immediately on any slider, SMS check or "访问异常" page.

## Runtime layout

- `runtime/` — local Node install of `@playwright/mcp` (launched with the bundled Node; installed with the hoisted linker so the CLI path is stable).
- `bundle/` — this DSH bundle (patch + locale + icon).
- `playwright-mcp.config.json` — server configuration.
- `stealth.js` — fingerprint-reduction init script.
- `safety.md` — pacing rules and hard stop conditions.
- `profile/` — Edge user-data directory.
- `output/` — screenshots and downloads.

## Remove

Disable or remove the bundle in Plugin Manager, then delete `launcher/profile` if you want to clear the saved login.
# 浏览器接管 MCP 插件 · 绿色版安装说明

这是把 DSH 里那个"能自己开浏览器逛淘宝"的能力打包成的独立插件包：装上之后，DSH 里的 agent 可以直接开真 Edge、看订单、看物流、搜商品，工具名是 `mcp__browser__browser_*`。

包里**不含任何登录态、不含 cookie、不含个人数据、不含打包者的本机路径**——安装脚本在你自己的电脑上现场生成所有路径。你装好之后自己登录淘宝，登录态存在你自己电脑的 `launcher\profile\` 里。

---

## 一、准备（缺一不可）

| 需要 | 说明 |
|---|---|
| Windows 10/11 | 只支持 Windows |
| Microsoft Edge | 系统自带即可，脚本会自动找 `msedge.exe` |
| DeepSeek Harness（DSH） | 桌面版，能打开 Web GUI |
| Node.js | 建议 20 以上。装了 DSH 的机器通常自带一份，脚本会自动找 |

---

## 二、安装（两步）

### 第 1 步：解压

解压到一个**固定位置**，例如 `D:\tools\dsh-browser-mcp`。
⚠️ 别放桌面或临时目录 —— 后面 Edge 的登录态就存在这个文件夹里，换位置等于重新登录淘宝。

### 第 2 步：双击 `install.cmd`

它就干这一件事，剩下的全自动：

1. 找 `node.exe`（先查 PATH，再查到注册表、Program Files、以及 DSH 自带的运行时目录）；
2. 检查内置的 MCP 运行时（`@playwright/mcp` 已随包附带，**不需要联网、不需要 npm**）；
3. 用「你现在这个文件夹」的绝对路径重写 `bundle\cordis.patch.yml`；
4. 自动找到 DSH 的 home 和 profile，把插件注册进去（原 `package.json` 备份成 `package.json.bak-browser`），并把 bundle 复制到 profile 的 `node_modules\@local\dsh-browser-mcp`，**不需要 pnpm**；
5. 拉起专用 Edge 窗口（端口 9222）。

看到 `installation finished` 就成功了。然后**重启 DSH**，对助手说「列出浏览器标签页」。

命令行等价写法：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1
.\install.ps1 -CheckOnly     # 只体检，不改任何东西
.\install.ps1 -NoStartEdge   # 不自动开 Edge
.\install.ps1 -Profile bili-duty   # 注册到别的 profile
```

> 如果提示 "no DSH home found"，说明 DSH 没装在常见位置：先装 DSH，或按下面「四、手动注册」填两行。

---

## 三、怎么用

- 专用 Edge 窗口（9222）由安装脚本拉起，之后每次开机双击 `launcher\启动调试浏览器.vbs` 即可（脚本会复用已经在跑的那个窗口）；
- 然后正常跟 DSH 说话，比如：「打开淘宝，看看我最近的订单」「查一下这个快递到哪了」；
- 那个 Edge 窗口是专用窗口，和你平时用的 Edge 互不干扰，登录一次淘宝就一直记住。

---

## 四、手动注册（脚本没找到 profile 时）

打开 `<DSH_HOME>\profiles\desktop\package.json`（Windows 常见位置：`C:\Users\你\.dsh`，或 DSH 安装目录下的 `DSH\home`），改两处：

```json
"dependencies": {
  "@local/dsh-browser-mcp": "link:D:/tools/dsh-browser-mcp/bundle"
},
"dsh": {
  "profile": {
    "bundles": [ "@local/dsh-browser-mcp" ]
  }
}
```

路径用**正斜杠**，指到 `bundle` 子目录。然后把 `bundle\cordis.patch.yml` 里的 `command` / `args` / `cwd` 改成你自己机器上的绝对路径（照着字段填 node.exe、cli.js、config.json、launcher 目录），再重启 DSH。

---

## 五、常见问题

**Q：双击 install.cmd 一闪就没了**
A：用 `install.cmd -CheckOnly` 或右键「在终端中打开」跑 `powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1`，能看到具体报错。

**Q：提示 node.exe not found**
A：装 Node.js 20+，或者 `install.ps1 -NodePath "C:\Program Files\nodejs\node.exe"`。装了 DSH 的机器也可以直接把 DSH 自带的那份 node 路径传进去。

**Q：助手说工具初始化失败 / `connect ECONNREFUSED 127.0.0.1:9222`**
A：浏览器窗口没起来。双击 `launcher\启动调试浏览器.vbs`；还是不行就用 `launcher\launch-edge-debug.bat` 看报错。

**Q：端口 9222 起不来**
A：可能被安全软件拦了，或者你已经有另一个程序占着 9222。关掉别的调试浏览器再试。

**Q：DSH 里看不到 `mcp__browser__browser_*` 工具**
A：三件事按顺序查——① 插件有没有出现在 profile 的 `dsh.profile.bundles` 里（有没有 `@local/dsh-browser-mcp`）；② DSH 有没有真正重启；③ `launcher\playwright-mcp.config.json` 里的 `cdpEndpoint` 是不是 `http://127.0.0.1:9222`。

**Q：换了电脑 / 换了文件夹**
A：重跑一次 `install.cmd`（它会用新路径重写配置），登录态可能需要重新登。

---

## 六、文件说明

```
dsh-browser-mcp-portable/
├─ install.cmd                 ← 双击这个（装完自己会部署到 DSH）
├─ install.ps1                 ← 安装逻辑（ASCII 源码，PS 5.1 也不会乱码）
├─ runtime-package.json        ← MCP 运行时依赖清单（参考用）
├─ runtime\                    ← 已装好的 MCP 运行时（@playwright/mcp 0.0.85，18 MB，无需联网）
├─ bundle\                     ← 插件本体（DSH 加载这个目录）
│  ├─ cordis.patch.yml         ← 启动配置，install.ps1 会按你的路径重写
│  ├─ package.json / icon.svg / locale\
├─ launcher\                   ← 浏览器启动器
│  ├─ 启动调试浏览器.vbs         ← 日常双击这个
│  ├─ launch-edge-debug.bat    ← 排查时用（带黑框输出）
│  ├─ start-browser.ps1        ← 逻辑本体
│  ├─ playwright-mcp.config.json
│  ├─ stealth.js               ← 降低自动化指纹
│  └─ safety.md                ← 安全边界说明
```

装好之后会多出 `launcher\profile\`（你的 Edge 登录态）和 `launcher\output\`（截图等临时文件），这两个都**不要发给别人**。

---

## 七、安全边界（建议保留）

- 只做浏览与读取：查订单、查物流、搜商品、看详情；
- **不自动下单、不确认收货、不付款**；
- 遇到滑块验证、短信验证、访问异常，立刻停手，人工处理；
- 登录态只存在本机 `launcher\profile\`，不随包分发。

---

版本：`@local/dsh-browser-mcp` 1.3.0（CDP 接管模式，一键自部署）· 运行时 `@playwright/mcp` 0.0.85
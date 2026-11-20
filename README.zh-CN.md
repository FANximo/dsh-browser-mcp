# 娴忚鍣ㄦ帴绠?MCP 鎻掍欢 路 缁胯壊鐗堝畨瑁呰鏄?
杩欐槸鎶?DSH 閲岄偅涓?鑳借嚜宸卞紑娴忚鍣ㄩ€涙窐瀹?鐨勮兘鍔涙墦鍖呮垚鐨勭嫭绔嬫彃浠跺寘锛氳涓婁箣鍚庯紝DSH 閲岀殑 agent 鍙互鐩存帴寮€鐪?Edge銆佺湅璁㈠崟銆佺湅鐗╂祦銆佹悳鍟嗗搧锛屽伐鍏峰悕鏄?`mcp__browser__browser_*`銆?
鍖呴噷**涓嶅惈浠讳綍鐧诲綍鎬併€佷笉鍚?cookie銆佷笉鍚釜浜烘暟鎹€佷笉鍚墦鍖呰€呯殑鏈満璺緞**鈥斺€斿畨瑁呰剼鏈湪浣犺嚜宸辩殑鐢佃剳涓婄幇鍦虹敓鎴愭墍鏈夎矾寰勩€備綘瑁呭ソ涔嬪悗鑷繁鐧诲綍娣樺疂锛岀櫥褰曟€佸瓨鍦ㄤ綘鑷繁鐢佃剳鐨?`launcher\profile\` 閲屻€?
---

## 闆躲€佷竴鏉″懡浠ゅ畨瑁咃紙鎺ㄨ崘锛?
鎵撳紑 PowerShell锛岀矘杩欎竴琛岋細

```powershell
irm https://raw.githubusercontent.com/FANximo/dsh-browser-mcp/main/bootstrap.ps1 | iex
```

瀹冧細鑷姩锛氫笅杞?release 鍘嬬缉鍖?鈫?瑙ｅ埌涓存椂鐩綍 鈫?鎵?`node.exe` 鈫?鎶婃彃浠舵敞鍐岃繘浣犵殑 DSH profile 鈫?鎷夎捣涓撶敤 Edge 绐楀彛 鈫?鍒犳帀涓存椂鐩綍銆傝瀹岄噸鍚竴娆?DeepSeek Harness 鍗冲彲銆?
鍙兂鍏堟鏌ョ幆澧冦€佷笉鍐欎换浣曚笢瑗匡細

```powershell
$env:BMC_CHECKONLY='1'; irm https://raw.githubusercontent.com/FANximo/dsh-browser-mcp/main/bootstrap.ps1 | iex
```

濡傛灉 `raw.githubusercontent.com` 璁块棶涓嶄簡锛屽氨鐢ㄤ笅闈㈢殑銆岃В鍘?+ 鍙屽嚮銆嶆柟寮忥紝鏁堟灉涓€鏍枫€?
---

## 涓€銆佸噯澶囷紙缂轰竴涓嶅彲锛?
| 闇€瑕?| 璇存槑 |
|---|---|
| Windows 10/11 | 鍙敮鎸?Windows |
| Microsoft Edge | 绯荤粺鑷甫鍗冲彲锛岃剼鏈細鑷姩鎵?`msedge.exe` |
| DeepSeek Harness锛圖SH锛?| 妗岄潰鐗堬紝鑳芥墦寮€ Web GUI |
| Node.js | 寤鸿 20 浠ヤ笂銆傝浜?DSH 鐨勬満鍣ㄩ€氬父鑷甫涓€浠斤紝鑴氭湰浼氳嚜鍔ㄦ壘 |

---

## 浜屻€佸畨瑁咃紙涓ゆ锛?
### 绗?1 姝ワ細瑙ｅ帇

瑙ｅ帇鍒颁竴涓?*鍥哄畾浣嶇疆**锛屼緥濡?`D:\tools\dsh-browser-mcp`銆?鈿狅笍 鍒斁妗岄潰鎴栦复鏃剁洰褰?鈥斺€?鍚庨潰 Edge 鐨勭櫥褰曟€佸氨瀛樺湪杩欎釜鏂囦欢澶归噷锛屾崲浣嶇疆绛変簬閲嶆柊鐧诲綍娣樺疂銆?
### 绗?2 姝ワ細鍙屽嚮 `install.cmd`

瀹冨氨骞茶繖涓€浠朵簨锛屽墿涓嬬殑鍏ㄨ嚜鍔細

1. 鎵?`node.exe`锛堝厛鏌?PATH锛屽啀鏌ュ埌娉ㄥ唽琛ㄣ€丳rogram Files銆佷互鍙?DSH 鑷甫鐨勮繍琛屾椂鐩綍锛夛紱
2. 妫€鏌ュ唴缃殑 MCP 杩愯鏃讹紙`@playwright/mcp` 宸查殢鍖呴檮甯︼紝**涓嶉渶瑕佽仈缃戙€佷笉闇€瑕?npm**锛夛紱
3. 鐢ㄣ€屼綘鐜板湪杩欎釜鏂囦欢澶广€嶇殑缁濆璺緞閲嶅啓 `bundle\cordis.patch.yml`锛?4. 鑷姩鎵惧埌 DSH 鐨?home 鍜?profile锛屾妸鎻掍欢娉ㄥ唽杩涘幓锛堝師 `package.json` 澶囦唤鎴?`package.json.bak-browser`锛夛紝骞舵妸 bundle 澶嶅埗鍒?profile 鐨?`node_modules\@local\dsh-browser-mcp`锛?*涓嶉渶瑕?pnpm**锛?5. 鎷夎捣涓撶敤 Edge 绐楀彛锛堢鍙?9222锛夈€?
鐪嬪埌 `installation finished` 灏辨垚鍔熶簡銆傜劧鍚?*閲嶅惎 DSH**锛屽鍔╂墜璇淬€屽垪鍑烘祻瑙堝櫒鏍囩椤点€嶃€?
鍛戒护琛岀瓑浠峰啓娉曪細

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1
.\install.ps1 -CheckOnly     # 鍙綋妫€锛屼笉鏀逛换浣曚笢瑗?.\install.ps1 -NoStartEdge   # 涓嶈嚜鍔ㄥ紑 Edge
.\install.ps1 -Profile bili-duty   # 娉ㄥ唽鍒板埆鐨?profile
```

> 濡傛灉鎻愮ず "no DSH home found"锛岃鏄?DSH 娌¤鍦ㄥ父瑙佷綅缃細鍏堣 DSH锛屾垨鎸変笅闈€屽洓銆佹墜鍔ㄦ敞鍐屻€嶅～涓よ銆?
---

## 涓夈€佹€庝箞鐢?
- 涓撶敤 Edge 绐楀彛锛?222锛夌敱瀹夎鑴氭湰鎷夎捣锛屼箣鍚庢瘡娆″紑鏈哄弻鍑?`launcher\鍚姩璋冭瘯娴忚鍣?vbs` 鍗冲彲锛堣剼鏈細澶嶇敤宸茬粡鍦ㄨ窇鐨勯偅涓獥鍙ｏ級锛?- 鐒跺悗姝ｅ父璺?DSH 璇磋瘽锛屾瘮濡傦細銆屾墦寮€娣樺疂锛岀湅鐪嬫垜鏈€杩戠殑璁㈠崟銆嶃€屾煡涓€涓嬭繖涓揩閫掑埌鍝簡銆嶏紱
- 閭ｄ釜 Edge 绐楀彛鏄笓鐢ㄧ獥鍙ｏ紝鍜屼綘骞虫椂鐢ㄧ殑 Edge 浜掍笉骞叉壈锛岀櫥褰曚竴娆℃窐瀹濆氨涓€鐩磋浣忋€?
---

## 鍥涖€佹墜鍔ㄦ敞鍐岋紙鑴氭湰娌℃壘鍒?profile 鏃讹級

鎵撳紑 `<DSH_HOME>\profiles\desktop\package.json`锛圵indows 甯歌浣嶇疆锛歚C:\Users\浣燶.dsh`锛屾垨 DSH 瀹夎鐩綍涓嬬殑 `DSH\home`锛夛紝鏀逛袱澶勶細

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

璺緞鐢?*姝ｆ枩鏉?*锛屾寚鍒?`bundle` 瀛愮洰褰曘€傜劧鍚庢妸 `bundle\cordis.patch.yml` 閲岀殑 `command` / `args` / `cwd` 鏀规垚浣犺嚜宸辨満鍣ㄤ笂鐨勭粷瀵硅矾寰勶紙鐓х潃瀛楁濉?node.exe銆乧li.js銆乧onfig.json銆乴auncher 鐩綍锛夛紝鍐嶉噸鍚?DSH銆?
---

## 浜斻€佸父瑙侀棶棰?
**Q锛氬弻鍑?install.cmd 涓€闂氨娌′簡**
A锛氱敤 `install.cmd -CheckOnly` 鎴栧彸閿€屽湪缁堢涓墦寮€銆嶈窇 `powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1`锛岃兘鐪嬪埌鍏蜂綋鎶ラ敊銆?
**Q锛氭彁绀?node.exe not found**
A锛氳 Node.js 20+锛屾垨鑰?`install.ps1 -NodePath "C:\Program Files\nodejs\node.exe"`銆傝浜?DSH 鐨勬満鍣ㄤ篃鍙互鐩存帴鎶?DSH 鑷甫鐨勯偅浠?node 璺緞浼犺繘鍘汇€?
**Q锛氬姪鎵嬭宸ュ叿鍒濆鍖栧け璐?/ `connect ECONNREFUSED 127.0.0.1:9222`**
A锛氭祻瑙堝櫒绐楀彛娌¤捣鏉ャ€傚弻鍑?`launcher\鍚姩璋冭瘯娴忚鍣?vbs`锛涜繕鏄笉琛屽氨鐢?`launcher\launch-edge-debug.bat` 鐪嬫姤閿欍€?
**Q锛氱鍙?9222 璧蜂笉鏉?*
A锛氬彲鑳借瀹夊叏杞欢鎷︿簡锛屾垨鑰呬綘宸茬粡鏈夊彟涓€涓▼搴忓崰鐫€ 9222銆傚叧鎺夊埆鐨勮皟璇曟祻瑙堝櫒鍐嶈瘯銆?
**Q锛欴SH 閲岀湅涓嶅埌 `mcp__browser__browser_*` 宸ュ叿**
A锛氫笁浠朵簨鎸夐『搴忔煡鈥斺€斺憼 鎻掍欢鏈夋病鏈夊嚭鐜板湪 profile 鐨?`dsh.profile.bundles` 閲岋紙鏈夋病鏈?`@local/dsh-browser-mcp`锛夛紱鈶?DSH 鏈夋病鏈夌湡姝ｉ噸鍚紱鈶?`launcher\playwright-mcp.config.json` 閲岀殑 `cdpEndpoint` 鏄笉鏄?`http://127.0.0.1:9222`銆?
**Q锛氭崲浜嗙數鑴?/ 鎹簡鏂囦欢澶?*
A锛氶噸璺戜竴娆?`install.cmd`锛堝畠浼氱敤鏂拌矾寰勯噸鍐欓厤缃級锛岀櫥褰曟€佸彲鑳介渶瑕侀噸鏂扮櫥銆?
---

## 鍏€佹枃浠惰鏄?
```
dsh-browser-mcp-portable/
鈹溾攢 install.cmd                 鈫?鍙屽嚮杩欎釜锛堣瀹岃嚜宸变細閮ㄧ讲鍒?DSH锛?鈹溾攢 install.ps1                 鈫?瀹夎閫昏緫锛圓SCII 婧愮爜锛孭S 5.1 涔熶笉浼氫贡鐮侊級
鈹溾攢 runtime-package.json        鈫?MCP 杩愯鏃朵緷璧栨竻鍗曪紙鍙傝€冪敤锛?鈹溾攢 runtime\                    鈫?宸茶濂界殑 MCP 杩愯鏃讹紙@playwright/mcp 0.0.85锛?8 MB锛屾棤闇€鑱旂綉锛?鈹溾攢 bundle\                     鈫?鎻掍欢鏈綋锛圖SH 鍔犺浇杩欎釜鐩綍锛?鈹? 鈹溾攢 cordis.patch.yml         鈫?鍚姩閰嶇疆锛宨nstall.ps1 浼氭寜浣犵殑璺緞閲嶅啓
鈹? 鈹溾攢 package.json / icon.svg / locale\
鈹溾攢 launcher\                   鈫?娴忚鍣ㄥ惎鍔ㄥ櫒
鈹? 鈹溾攢 鍚姩璋冭瘯娴忚鍣?vbs         鈫?鏃ュ父鍙屽嚮杩欎釜
鈹? 鈹溾攢 launch-edge-debug.bat    鈫?鎺掓煡鏃剁敤锛堝甫榛戞杈撳嚭锛?鈹? 鈹溾攢 start-browser.ps1        鈫?閫昏緫鏈綋
鈹? 鈹溾攢 playwright-mcp.config.json
鈹? 鈹溾攢 stealth.js               鈫?闄嶄綆鑷姩鍖栨寚绾?鈹? 鈹斺攢 safety.md                鈫?瀹夊叏杈圭晫璇存槑
```

瑁呭ソ涔嬪悗浼氬鍑?`launcher\profile\`锛堜綘鐨?Edge 鐧诲綍鎬侊級鍜?`launcher\output\`锛堟埅鍥剧瓑涓存椂鏂囦欢锛夛紝杩欎袱涓兘**涓嶈鍙戠粰鍒汉**銆?
---

## 涓冦€佸畨鍏ㄨ竟鐣岋紙寤鸿淇濈暀锛?
- 鍙仛娴忚涓庤鍙栵細鏌ヨ鍗曘€佹煡鐗╂祦銆佹悳鍟嗗搧銆佺湅璇︽儏锛?- **涓嶈嚜鍔ㄤ笅鍗曘€佷笉纭鏀惰揣銆佷笉浠樻**锛?- 閬囧埌婊戝潡楠岃瘉銆佺煭淇￠獙璇併€佽闂紓甯革紝绔嬪埢鍋滄墜锛屼汉宸ュ鐞嗭紱
- 鐧诲綍鎬佸彧瀛樺湪鏈満 `launcher\profile\`锛屼笉闅忓寘鍒嗗彂銆?
---

鐗堟湰锛歚@local/dsh-browser-mcp` 1.3.0锛圕DP 鎺ョ妯″紡锛屼竴閿嚜閮ㄧ讲锛壜?杩愯鏃?`@playwright/mcp` 0.0.85
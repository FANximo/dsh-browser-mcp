' Silent launcher: starts the debugging Edge window for the browser MCP server.
' No console window, no black box. Safe to double-click repeatedly (it reuses a running window).
Dim sh, fso, base
Set sh  = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
base = fso.GetParentFolderName(WScript.ScriptFullName)
sh.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & base & "\start-browser.ps1""", 0, False
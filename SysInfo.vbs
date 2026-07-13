Set oShell = CreateObject("Wscript.Shell")
oShell.Run "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName) & "\SysInfo.ps1""", 0, False

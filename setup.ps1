$wsh = New-Object -ComObject WScript.Shell
$desktop = [Environment]::GetFolderPath("Desktop")
$shortcut = $wsh.CreateShortcut("$desktop\SysInfo.lnk")
$shortcut.TargetPath = "$desktop\line\SysInfo.vbs"
$shortcut.IconLocation = "imageres.dll,27"
$shortcut.Description = "System Info Monitor"
$shortcut.Save()
Write-Output "Shortcut cree sur le bureau !"

$Host.UI.RawUI.ForegroundColor = [ConsoleColor]::Cyan
@"
██╗     ██╗███╗   ██╗███████╗
██║     ██║████╗  ██║██╔════╝
██║     ██║██╔██╗ ██║█████╗
██║     ██║██║╚██╗██║██╔══╝
███████╗██║██║ ╚████║███████╗
╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝
"@ | Write-Host
$Host.UI.RawUI.ForegroundColor = [ConsoleColor]::White

Write-Host "Line is Not an Emulator - Installateur" -ForegroundColor Cyan
Write-Host ""

$BaseDir = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop", "line")
$LinePs1 = [System.IO.Path]::Combine($BaseDir, "line.ps1")

# 1. Verifier WSL
Write-Host "[1/5] Verification de WSL..." -ForegroundColor Yellow
$wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
if (-not $wsl) {
    Write-Host "  WSL n'est pas installe. Installe-le d'abord: wsl --install" -ForegroundColor Red
    exit 1
}
$wslVer = wsl.exe --version 2>$null
if ($wslVer) {
    $verLine = ($wslVer -split "`n")[0]
    Write-Host "  WSL OK: $verLine" -ForegroundColor Green
} else {
    Write-Host "  WSL installe, verifie la distribution Ubuntu" -ForegroundColor Green
}

# 2. Ajouter au PATH
Write-Host "[2/5] Ajout au PATH utilisateur..." -ForegroundColor Yellow
$path = [Environment]::GetEnvironmentVariable("Path", "User")
if ($path -notlike "*$BaseDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$path;$BaseDir", "User")
    Write-Host "  Ajoute au PATH (terminal neuf requis)" -ForegroundColor Green
} else {
    Write-Host "  Deja dans le PATH" -ForegroundColor Green
}

# 3. Creer raccourci sur le bureau
Write-Host "[3/5] Creation des raccourcis..." -ForegroundColor Yellow
$wsh = New-Object -ComObject WScript.Shell
$desktop = [Environment]::GetFolderPath("Desktop")

$shortcut = $wsh.CreateShortcut("$desktop\LINE.lnk")
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$LinePs1`""
$shortcut.WorkingDirectory = $BaseDir
$shortcut.IconLocation = "powershell.exe,0"
$shortcut.Description = "LINE - Linux on Windows"
$shortcut.Save()

$shortcut2 = $wsh.CreateShortcut("$desktop\SysInfo.lnk")
$shortcut2.TargetPath = "$BaseDir\SysInfo.vbs"
$shortcut2.IconLocation = "imageres.dll,27"
$shortcut2.Description = "System Info Monitor"
$shortcut2.Save()
Write-Host "  Raccourcis crees sur le bureau" -ForegroundColor Green

# 4. Verifier les packages
Write-Host "[4/5] Verification des packages..." -ForegroundColor Yellow
$packages = Get-ChildItem "$BaseDir\packages\*\*" -Directory -ErrorAction SilentlyContinue
if ($packages) {
    Write-Host "  Packages installes:" -ForegroundColor Green
    $packages | ForEach-Object { Write-Host "    - $($_.Parent.Name)/$($_.Name)" }
} else {
    Write-Host "  Aucun package installe" -ForegroundColor Green
}

# 5. Terminer
Write-Host "[5/5] Installation terminee !" -ForegroundColor Yellow
Write-Host ""
Write-Host "Commandes disponibles:" -ForegroundColor Cyan
Write-Host "  line install <fichier>    Installer un .deb, .appimage ou binaire"
Write-Host "  line run <package> [args] Executer un package via WSL"
Write-Host "  line list                 Lister les packages installes"
Write-Host "  line remove <package>     Supprimer un package"
Write-Host ""
Write-Host "Ouvre un nouveau terminal pour utiliser 'line'." -ForegroundColor Cyan

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Args
)

$BaseDir = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop", "line")
$PackagesDir = [System.IO.Path]::Combine($BaseDir, "packages")
$DebDir = [System.IO.Path]::Combine($PackagesDir, "deb")
$AppImageDir = [System.IO.Path]::Combine($PackagesDir, "appimage")
$BinDir = [System.IO.Path]::Combine($PackagesDir, "bin")
$CacheDir = [System.IO.Path]::Combine($BaseDir, "cache")
$ConfigDir = [System.IO.Path]::Combine($BaseDir, "config")

foreach ($d in @($BaseDir, $PackagesDir, $DebDir, $AppImageDir, $BinDir, $CacheDir, $ConfigDir)) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

function WinToWsl($path) {
    $p = $path -replace '\\', '/'
    if ($p -match '^([A-Za-z]):(.*)') { return "/mnt/$($Matches[1].ToLower())$($Matches[2])" }
    return $p
}

function Get-WslBinary($dir) {
    $files = Get-ChildItem $dir -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "run.bat" -and $_.Name -ne "run.sh" }
    if (-not $files) { return $null }
    $exe = $files | Where-Object { $_.Extension -eq "" -or $_.Extension -eq ".bin" -or $_.Extension -eq ".appimage" -or $_.Name -like "checkra1n*" } | Select-Object -First 1
    if (-not $exe) { $exe = $files | Select-Object -First 1 }
    return $exe
}

function Show-Banner {
    Write-Host "LINE - Line is Not an Emulator" -ForegroundColor Cyan
    Write-Host "WSL Backend - Execute Linux binaires sur Windows" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Help {
    Write-Host "Commandes:"
    Write-Host "  install <fichier>    Installer un .deb, .appimage ou binaire Linux"
    Write-Host "  run <package> [args] Executer un package (via WSL)"
    Write-Host "  list                 Lister les packages installes"
    Write-Host "  remove <package>     Supprimer un package"
    Write-Host ""
}

function Install-Package($FilePath) {
    if (-not (Test-Path $FilePath)) { Write-Host "Fichier non trouve: $FilePath" -ForegroundColor Red; return }
    $fileExt = [System.IO.Path]::GetExtension($FilePath).ToLower()
    if ($fileExt -eq ".deb") { Install-Deb $FilePath }
    elseif ($fileExt -eq ".appimage") { Install-AppImage $FilePath }
    else { Install-Binary $FilePath }
}

function Install-Deb($DebFile) {
    $pkg = [System.IO.Path]::GetFileNameWithoutExtension($DebFile)
    $dir = [System.IO.Path]::Combine($DebDir, $pkg)
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $dest = [System.IO.Path]::Combine($dir, [System.IO.Path]::GetFileName($DebFile))
    Copy-Item -Path $DebFile -Destination $dest -Force
    $wslDeb = WinToWsl $dest
    $wslDir = WinToWsl $dir
    $result = wsl.exe bash -c "cd '$wslDir' && ar x '$wslDeb' && tar xf data.tar.* 2>/dev/null; if (Test-Path data.tar.zst) { zstd -d data.tar.zst --stdout | tar xf - }" 2>&1
    Write-Host $result
    Write-Host "Paquet .deb installe: $pkg" -ForegroundColor Green
}

function Install-AppImage($AppImageFile) {
    $app = [System.IO.Path]::GetFileNameWithoutExtension($AppImageFile)
    $dir = [System.IO.Path]::Combine($AppImageDir, $app)
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $dest = [System.IO.Path]::Combine($dir, [System.IO.Path]::GetFileName($AppImageFile))
    Copy-Item -Path $AppImageFile -Destination $dest -Force
    $wslDest = WinToWsl $dest
    wsl.exe bash -c "chmod +x '$wslDest'" 2>$null
    Write-Host "AppImage installee: $app" -ForegroundColor Green
}

function Install-Binary($BinaryFile) {
    $bin = [System.IO.Path]::GetFileNameWithoutExtension($BinaryFile)
    $dir = [System.IO.Path]::Combine($BinDir, $bin)
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $dest = [System.IO.Path]::Combine($dir, [System.IO.Path]::GetFileName($BinaryFile))
    Copy-Item -Path $BinaryFile -Destination $dest -Force
    $wslDest = WinToWsl $dest
    wsl.exe bash -c "chmod +x '$wslDest'" 2>$null
    Write-Host "Binaire installe: $bin" -ForegroundColor Green
}

function Run-Package($PackageName, $ExecArgs) {
    $dirs = @([System.IO.Path]::Combine($BinDir, $PackageName), [System.IO.Path]::Combine($AppImageDir, $PackageName), [System.IO.Path]::Combine($DebDir, $PackageName))
    foreach ($d in $dirs) {
        if (Test-Path $d) {
            $file = Get-WslBinary $d
            if ($file) {
                $wslPath = WinToWsl $file.FullName
                $argsStr = if ($ExecArgs) { ($ExecArgs | ForEach-Object { "'$_'" }) -join " " } else { "" }
                Write-Host "Lancement via WSL: $wslPath" -ForegroundColor Yellow
                if ($argsStr) { wsl.exe bash -c "'$wslPath' $argsStr" }
                else { wsl.exe bash -c "'$wslPath'" }
                return
            }
        }
    }
    Write-Host "Package non trouve: $PackageName" -ForegroundColor Red
}

function List-Packages {
    Write-Host ""
    Write-Host "Packages installes:" -ForegroundColor Yellow
    $deb = Get-ChildItem $DebDir -Directory -ErrorAction SilentlyContinue
    $app = Get-ChildItem $AppImageDir -Directory -ErrorAction SilentlyContinue
    $bin = Get-ChildItem $BinDir -Directory -ErrorAction SilentlyContinue
    if ($deb) { Write-Host "  .deb:"; $deb | ForEach-Object { Write-Host "    - $($_.Name)" } }
    if ($app) { Write-Host "  AppImage:"; $app | ForEach-Object { Write-Host "    - $($_.Name)" } }
    if ($bin) { Write-Host "  Binaires:"; $bin | ForEach-Object { Write-Host "    - $($_.Name)" } }
    if (-not $deb -and -not $app -and -not $bin) { Write-Host "  Aucun" }
    Write-Host ""
}

function Remove-Package($PackageName) {
    $paths = @([System.IO.Path]::Combine($DebDir, $PackageName), [System.IO.Path]::Combine($AppImageDir, $PackageName), [System.IO.Path]::Combine($BinDir, $PackageName))
    $found = $false
    foreach ($p in $paths) { if (Test-Path $p) { Remove-Item -Path $p -Recurse -Force; $found = $true; Write-Host "Supprime: $PackageName" -ForegroundColor Green } }
    if (-not $found) { Write-Host "Package non trouve: $PackageName" -ForegroundColor Red }
}

# Main
Show-Banner
if ($Args.Count -eq 0) { Show-Help; exit 0 }
$cmd = $Args[0]
$cmdArgs = @($Args[1..($Args.Count - 1)])
switch ($cmd.ToLower()) {
    "install" { if ($cmdArgs.Count -gt 0) { Install-Package $cmdArgs[0] } else { Write-Host "Usage: line install <fichier>" } }
    "run" { if ($cmdArgs.Count -gt 0) { Run-Package $cmdArgs[0] $cmdArgs[1..$cmdArgs.Count] } else { Write-Host "Usage: line run <package>" } }
    "list" { List-Packages }
    "remove" { if ($cmdArgs.Count -gt 0) { Remove-Package $cmdArgs[0] } else { Write-Host "Usage: line remove <package>" } }
    "--version" { Write-Host "LINE v0.1.0 - WSL Backend" }
    "--help" { Show-Help }
    default { Write-Host "Commande inconnue: $cmd"; Show-Help }
}

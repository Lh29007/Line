#!/usr/bin/env pwsh
<#
.SYNOPSIS
LINE GUI - Version PowerShell (Sans .NET, sans Admin, pur Windows!)

.DESCRIPTION
Interface interactive pour LINE - gestion des packages Linux sur Windows
Fonctionne avec PowerShell uniquement (aucune dépendance externe)

.EXAMPLE
.\line-gui.ps1
#>

param(
    [switch]$Portable,
    [switch]$Debug
)

# Configuration
$BaseDir = "$env:USERPROFILE\Desktop\line"
$PackagesDir = "$BaseDir\packages"
$DebDir = "$PackagesDir\deb"
$AppImageDir = "$PackagesDir\appimage"
$BinDir = "$PackagesDir\bin"
$CacheDir = "$BaseDir\cache"

# Garantir les répertoires
@($BaseDir, $PackagesDir, $DebDir, $AppImageDir, $BinDir, $CacheDir) | ForEach-Object {
    if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

# ============================================================================
# UI - Menu interactif
# ============================================================================

function Show-Menu {
    Clear-Host
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  🚀 LINE - Line is Not an Emulator (PowerShell Edition)    ║" -ForegroundColor Cyan
    Write-Host "║  Wine inversé pour Linux sur Windows                      ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    Show-Statistics
    
    Write-Host "┌────────────────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
    Write-Host "│  MENU PRINCIPAL                                            │" -ForegroundColor DarkCyan
    Write-Host "├────────────────────────────────────────────────────────────┤" -ForegroundColor DarkCyan
    Write-Host "│                                                            │" -ForegroundColor DarkCyan
    Write-Host "│  1. 📦 Installer un package (.deb/.appimage/.bin)         │" -ForegroundColor DarkCyan
    Write-Host "│  2. 📋 Lister tous les packages                            │" -ForegroundColor DarkCyan
    Write-Host "│  3. ▶️  Exécuter un package                                │" -ForegroundColor DarkCyan
    Write-Host "│  4. 🗑️  Supprimer un package                               │" -ForegroundColor DarkCyan
    Write-Host "│  5. 📁 Ouvrir le dossier packages                          │" -ForegroundColor DarkCyan
    Write-Host "│  6. 🧹 Nettoyer le cache                                  │" -ForegroundColor DarkCyan
    Write-Host "│  7. ℹ️  À propos                                           │" -ForegroundColor DarkCyan
    Write-Host "│  0. ❌ Quitter                                             │" -ForegroundColor DarkCyan
    Write-Host "│                                                            │" -ForegroundColor DarkCyan
    Write-Host "└────────────────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
    Write-Host ""
}

function Show-Statistics {
    $DebCount = (Get-ChildItem $DebDir -Directory -ErrorAction SilentlyContinue).Count
    $AppImageCount = (Get-ChildItem $AppImageDir -Directory -ErrorAction SilentlyContinue).Count
    $BinCount = (Get-ChildItem $BinDir -Directory -ErrorAction SilentlyContinue).Count
    $Total = $DebCount + $AppImageCount + $BinCount
    
    Write-Host "📊 STATISTIQUES:" -ForegroundColor Yellow
    Write-Host "  Paquets total: $Total  |  .deb: $DebCount  |  AppImage: $AppImageCount  |  Binaires: $BinCount" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================================================
# FONCTIONS
# ============================================================================

function Menu-Installer {
    Write-Host "📦 INSTALLER UN PACKAGE" -ForegroundColor Green
    Write-Host ""
    
    $FilePath = Read-Host "Chemin du fichier (.deb/.appimage/.bin/.exe)"
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "❌ Fichier non trouvé!" -ForegroundColor Red
        Read-Host "Appuyer sur Entrée pour continuer"
        return
    }
    
    $FileName = Split-Path $FilePath -Leaf
    $FileExt = [System.IO.Path]::GetExtension($FilePath).ToLower()
    $PackageName = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
    
    Write-Host ""
    Write-Host "Fichier: $FileName" -ForegroundColor Cyan
    Write-Host "Type: $FileExt" -ForegroundColor Cyan
    Write-Host "Nom du package: $PackageName" -ForegroundColor Cyan
    Write-Host ""
    
    if ($FileExt -eq ".deb") {
        $TargetDir = Join-Path $DebDir $PackageName
        Write-Host "Installation en tant que package .deb..." -ForegroundColor Yellow
    } elseif ($FileExt -eq ".appimage") {
        $TargetDir = Join-Path $AppImageDir $PackageName
        Write-Host "Installation en tant qu'AppImage..." -ForegroundColor Yellow
    } else {
        $TargetDir = Join-Path $BinDir $PackageName
        Write-Host "Installation en tant que binaire..." -ForegroundColor Yellow
    }
    
    try {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
        Copy-Item -Path $FilePath -Destination (Join-Path $TargetDir $FileName) -Force
        Write-Host "✅ Package installé avec succès!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erreur lors de l'installation: $_" -ForegroundColor Red
    }
    
    Read-Host "`nAppuyer sur Entrée pour continuer"
}

function Menu-Lister {
    Write-Host "📋 TOUS LES PACKAGES" -ForegroundColor Green
    Write-Host ""
    
    $Packages = @()
    
    # .deb
    Get-ChildItem $DebDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $Packages += @{
            Name = $_.Name
            Type = "📦 .deb"
            Path = $_.FullName
            Icon = "📦"
        }
    }
    
    # AppImage
    Get-ChildItem $AppImageDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $Packages += @{
            Name = $_.Name
            Type = "🐧 AppImage"
            Path = $_.FullName
            Icon = "🐧"
        }
    }
    
    # Binaires
    Get-ChildItem $BinDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $Packages += @{
            Name = $_.Name
            Type = "⚙️ Binaire"
            Path = $_.FullName
            Icon = "⚙️"
        }
    }
    
    if ($Packages.Count -eq 0) {
        Write-Host "Aucun package installé. Utilisez l'option 1 pour en installer." -ForegroundColor Yellow
    } else {
        Write-Host "$($Packages.Count) package(s) trouvé(s):" -ForegroundColor Cyan
        Write-Host ""
        
        $i = 1
        foreach ($Pkg in $Packages) {
            Write-Host "$i. $($Pkg.Icon) $($Pkg.Name)" -ForegroundColor Green
            Write-Host "   Type: $($Pkg.Type) | Chemin: $($Pkg.Path)" -ForegroundColor Gray
            Write-Host ""
            $i++
        }
    }
    
    Read-Host "Appuyer sur Entrée pour continuer"
}

function Menu-Executer {
    Write-Host "▶️  EXÉCUTER UN PACKAGE" -ForegroundColor Green
    Write-Host ""
    
    $Packages = @()
    
    Get-ChildItem $AppImageDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $Packages += @{
            Name = $_.Name
            Path = $_
            Type = "appimage"
        }
    }
    
    Get-ChildItem $BinDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $Packages += @{
            Name = $_.Name
            Path = $_
            Type = "bin"
        }
    }
    
    if ($Packages.Count -eq 0) {
        Write-Host "❌ Aucun package exécutable trouvé!" -ForegroundColor Red
        Read-Host "Appuyer sur Entrée pour continuer"
        return
    }
    
    Write-Host "Packages exécutables:" -ForegroundColor Yellow
    Write-Host ""
    
    $i = 1
    foreach ($Pkg in $Packages) {
        Write-Host "$i. $($Pkg.Name)" -ForegroundColor Cyan
        $i++
    }
    
    Write-Host ""
    [int]$Choice = Read-Host "Choisir le package à exécuter (numéro)"
    
    if ($Choice -lt 1 -or $Choice -gt $Packages.Count) {
        Write-Host "❌ Choix invalide" -ForegroundColor Red
        Read-Host "Appuyer sur Entrée pour continuer"
        return
    }
    
    $Selected = $Packages[$Choice - 1]
    Write-Host ""
    Write-Host "Exécution de: $($Selected.Name)" -ForegroundColor Yellow
    Write-Host ""
    
    try {
        if ($Selected.Type -eq "appimage") {
            $AppImageFile = Get-ChildItem $Selected.Path.FullName -Filter "*.appimage" | Select-Object -First 1
            if ($AppImageFile) {
                Start-Process -FilePath $AppImageFile.FullName -NoNewWindow
                Write-Host "✅ Application lancée!" -ForegroundColor Green
            } else {
                Write-Host "❌ Fichier AppImage non trouvé" -ForegroundColor Red
            }
        } else {
            $ExeFile = Get-ChildItem $Selected.Path.FullName | Where-Object { $_.Extension -in @(".exe", ".bin", "") -and -not $_.PSIsContainer } | Select-Object -First 1
            if ($ExeFile) {
                Start-Process -FilePath $ExeFile.FullName -NoNewWindow
                Write-Host "✅ Application lancée!" -ForegroundColor Green
            } else {
                Write-Host "❌ Exécutable non trouvé" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "❌ Erreur: $_" -ForegroundColor Red
    }
    
    Read-Host "`nAppuyer sur Entrée pour continuer"
}

function Menu-Supprimer {
    Write-Host "🗑️  SUPPRIMER UN PACKAGE" -ForegroundColor Green
    Write-Host ""
    
    $Packages = @()
    
    Get-ChildItem $DebDir -Directory -ErrorAction SilentlyContinue | ForEach-Object { $Packages += @{Name=$_.Name; Path=$_.FullName; Type="deb"} }
    Get-ChildItem $AppImageDir -Directory -ErrorAction SilentlyContinue | ForEach-Object { $Packages += @{Name=$_.Name; Path=$_.FullName; Type="appimage"} }
    Get-ChildItem $BinDir -Directory -ErrorAction SilentlyContinue | ForEach-Object { $Packages += @{Name=$_.Name; Path=$_.FullName; Type="bin"} }
    
    if ($Packages.Count -eq 0) {
        Write-Host "❌ Aucun package à supprimer!" -ForegroundColor Red
        Read-Host "Appuyer sur Entrée pour continuer"
        return
    }
    
    Write-Host "Packages:" -ForegroundColor Yellow
    Write-Host ""
    
    $i = 1
    foreach ($Pkg in $Packages) {
        Write-Host "$i. $($Pkg.Name) ($($Pkg.Type))" -ForegroundColor Cyan
        $i++
    }
    
    Write-Host ""
    [int]$Choice = Read-Host "Choisir le package à supprimer (numéro)"
    
    if ($Choice -lt 1 -or $Choice -gt $Packages.Count) {
        Write-Host "❌ Choix invalide" -ForegroundColor Red
        Read-Host "Appuyer sur Entrée pour continuer"
        return
    }
    
    $Selected = $Packages[$Choice - 1]
    Write-Host ""
    Write-Host "Vous êtes sur le point de supprimer: $($Selected.Name)" -ForegroundColor Yellow
    $Confirm = Read-Host "Confirmer (O/n)"
    
    if ($Confirm -ne "n" -and $Confirm -ne "N") {
        try {
            Remove-Item -Path $Selected.Path -Recurse -Force
            Write-Host "✅ Package supprimé!" -ForegroundColor Green
        } catch {
            Write-Host "❌ Erreur: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠️  Suppression annulée" -ForegroundColor Yellow
    }
    
    Read-Host "`nAppuyer sur Entrée pour continuer"
}

function Menu-Dossier {
    Write-Host "📁 Ouverture du dossier packages..." -ForegroundColor Yellow
    try {
        Invoke-Item $PackagesDir
        Write-Host "✅ Dossier ouvert" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erreur: $_" -ForegroundColor Red
    }
    Read-Host "`nAppuyer sur Entrée pour continuer"
}

function Menu-Cache {
    Write-Host "🧹 NETTOYER LE CACHE" -ForegroundColor Yellow
    Write-Host ""
    
    $CacheSize = (Get-ChildItem $CacheDir -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "Taille actuelle du cache: $([Math]::Round($CacheSize, 2))MB" -ForegroundColor Cyan
    Write-Host ""
    
    $Confirm = Read-Host "Vider le cache? (O/n)"
    
    if ($Confirm -ne "n" -and $Confirm -ne "N") {
        try {
            Get-ChildItem $CacheDir -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "✅ Cache nettoyé!" -ForegroundColor Green
        } catch {
            Write-Host "❌ Erreur: $_" -ForegroundColor Red
        }
    }
    
    Read-Host "`nAppuyer sur Entrée pour continuer"
}

function Menu-About {
    Clear-Host
    Write-Host "ℹ️  À PROPOS DE LINE" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  LINE - Line is Not an Emulator                            ║" -ForegroundColor Cyan
    Write-Host "║  Version 0.1.0 (PowerShell Edition)                        ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "🎯 CONCEPT:" -ForegroundColor Yellow
    Write-Host "  Wine inversé pour exécuter du Linux sur Windows" -ForegroundColor Gray
    Write-Host "  Sans WSL, sans virtualization, sans admin!" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "📦 FORMATS SUPPORTÉS:" -ForegroundColor Yellow
    Write-Host "  • .deb  - Paquets Debian/Ubuntu" -ForegroundColor Gray
    Write-Host "  • .appimage - Applications portables" -ForegroundColor Gray
    Write-Host "  • .exe / .bin - Binaires Windows/Linux" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "✨ FONCTIONNALITÉS:" -ForegroundColor Yellow
    Write-Host "  • Installer des packages Linux" -ForegroundColor Gray
    Write-Host "  • Exécuter directement depuis Windows" -ForegroundColor Gray
    Write-Host "  • Gérer vos applications" -ForegroundColor Gray
    Write-Host "  • Sans dépendances externes" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "📂 LOCALISATION:" -ForegroundColor Yellow
    Write-Host "  $BaseDir" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "🔧 TECHNOLOGIE:" -ForegroundColor Yellow
    Write-Host "  PowerShell 5.1+ (natif Windows)" -ForegroundColor Gray
    Write-Host "  Pur script - Aucune compilation!" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "📚 DOCUMENTATION:" -ForegroundColor Yellow
    Write-Host "  Voir: GUI_QUICKSTART.md" -ForegroundColor Gray
    Write-Host "       GUI_README.md" -ForegroundColor Gray
    Write-Host "       INDEX.md" -ForegroundColor Gray
    Write-Host ""
    
    Read-Host "Appuyer sur Entrée pour continuer"
}

# ============================================================================
# BOUCLE PRINCIPALE
# ============================================================================

while ($true) {
    Show-Menu
    
    $Choice = Read-Host "Votre choix (0-7)"
    
    switch ($Choice) {
        "1" { Menu-Installer }
        "2" { Menu-Lister }
        "3" { Menu-Executer }
        "4" { Menu-Supprimer }
        "5" { Menu-Dossier }
        "6" { Menu-Cache }
        "7" { Menu-About }
        "0" { 
            Write-Host ""
            Write-Host "👋 Au revoir!" -ForegroundColor Yellow
            exit 0
        }
        default {
            Write-Host "❌ Choix invalide" -ForegroundColor Red
            Read-Host "Appuyer sur Entrée pour continuer"
        }
    }
}

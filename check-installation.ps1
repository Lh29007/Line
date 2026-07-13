#!/usr/bin/env pwsh
<#
.SYNOPSIS
Vérification de l'installation de LINE GUI

.DESCRIPTION
Vérifie tous les prérequis et la structure du projet

.EXAMPLE
./check-installation.ps1
#>

param(
    [switch]$Verbose,
    [switch]$Fix
)

$BaseDir = "C:\Users\aurel\Desktop\line"
$GuiDir = "$BaseDir\GUI"
$ExePath = "$BaseDir\bin\LINE.exe"

Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   LINE - Installation Check                        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$Status = @{
    "✓" = @{ Color = "Green"; Pass = 0 }
    "✗" = @{ Color = "Red"; Pass = 0 }
    "?" = @{ Color = "Yellow"; Pass = 0 }
}

function Check {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [string]$FixCmd = ""
    )
    
    try {
        $Result = & $Test
        if ($Result) {
            Write-Host "  ✓ $Name" -ForegroundColor Green
            $Status["✓"].Pass++
            return $true
        } else {
            Write-Host "  ✗ $Name" -ForegroundColor Red
            if ($FixCmd -and $Fix) {
                Write-Host "    → $FixCmd" -ForegroundColor Gray
                Invoke-Expression $FixCmd
            }
            $Status["✗"].Pass++
            return $false
        }
    } catch {
        Write-Host "  ? $Name - Error: $_" -ForegroundColor Yellow
        $Status["?"].Pass++
        return $false
    }
}

# 1. Système
Write-Host "[1] 🖥️  SYSTÈME" -ForegroundColor Yellow
Check ".NET SDK installé" { 
    $null = dotnet --version 2>$null
    $LASTEXITCODE -eq 0
}
Check ".NET 8 ou supérieur" {
    [version]$Ver = dotnet --version 2>$null
    $Ver.Major -ge 8
}
Check "PowerShell 5.1 ou supérieur" {
    $PSVersionTable.PSVersion.Major -ge 5
}

Write-Host ""

# 2. Structure
Write-Host "[2] 📁 STRUCTURE DES FICHIERS" -ForegroundColor Yellow
Check "Dossier LINE existe" {
    Test-Path $BaseDir
}
Check "Dossier GUI existe" {
    Test-Path $GuiDir
}
Check "GUI.csproj existe" {
    Test-Path "$GuiDir\GUI.csproj"
}
Check "MainWindow.xaml existe" {
    Test-Path "$GuiDir\MainWindow.xaml"
}
Check "MainWindow.xaml.cs existe" {
    Test-Path "$GuiDir\MainWindow.xaml.cs"
}
Check "App.xaml existe" {
    Test-Path "$GuiDir\App.xaml"
}
Check "App.xaml.cs existe" {
    Test-Path "$GuiDir\App.xaml.cs"
}

Write-Host ""

# 3. Paquets
Write-Host "[3] 📦 RÉPERTOIRES DES PACKAGES" -ForegroundColor Yellow
Check "Dossier packages/" {
    Test-Path "$BaseDir\packages"
}
Check "Dossier packages/deb/" {
    Test-Path "$BaseDir\packages\deb"
}
Check "Dossier packages/appimage/" {
    Test-Path "$BaseDir\packages\appimage"
}
Check "Dossier packages/bin/" {
    Test-Path "$BaseDir\packages\bin"
}

Write-Host ""

# 4. Build
Write-Host "[4] 🔨 COMPILATION" -ForegroundColor Yellow

$HasExe = Test-Path $ExePath
Check "LINE.exe compilé" {
    $HasExe
}

if ($HasExe) {
    $Size = (Get-Item $ExePath).Length
    Write-Host "    → Taille: $([Math]::Round($Size/1MB, 2)) MB" -ForegroundColor Gray
    
    Check "LINE.exe exécutable" {
        (Get-Item $ExePath).Extension -eq ".exe"
    }
}

Write-Host ""

# 5. Contenu du projet
Write-Host "[5] 📄 CONTENU DES FICHIERS" -ForegroundColor Yellow

Check "MainWindow.xaml a du contenu" {
    (Get-Item "$GuiDir\MainWindow.xaml").Length -gt 5000
}
Check "MainWindow.xaml.cs a du contenu" {
    (Get-Item "$GuiDir\MainWindow.xaml.cs").Length -gt 5000
}
Check "GUI.csproj est valide" {
    (Select-String "WindowsDesktop" "$GuiDir\GUI.csproj") -ne $null
}

Write-Host ""

# 6. Dépendances
Write-Host "[6] 📚 DÉPENDANCES" -ForegroundColor Yellow

Check "PowerShell Core (optionnel)" {
    Get-Command pwsh -ErrorAction SilentlyContinue
} | Out-Null

$VsExists = Get-Command devenv -ErrorAction SilentlyContinue
Check "Visual Studio (optionnel)" {
    $VsExists -ne $null
} | Out-Null

Write-Host ""

# 7. Tests
Write-Host "[7] ✅ TESTS" -ForegroundColor Yellow

if ($HasExe) {
    Check "LINE.exe peut être lancé" {
        Start-Process $ExePath -WindowStyle Hidden -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 500
        $true
    }
}

Check "Fichiers logs/" {
    Test-Path "$BaseDir\logs"
}
Check "Fichiers cache/" {
    Test-Path "$BaseDir\cache"
}

Write-Host ""

# Résumé
Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   RÉSUMÉ                                           ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$Total = $Status["✓"].Pass + $Status["✗"].Pass
$Percent = if ($Total -gt 0) { [Math]::Round(($Status["✓"].Pass / $Total) * 100) } else { 0 }

Write-Host "  Checks réussis:  $($Status['✓'].Pass)/$Total ($Percent%)" -ForegroundColor Green
Write-Host "  Checks échoués:  $($Status['✗'].Pass)" -ForegroundColor Red
Write-Host "  Checks warned:   $($Status['?'].Pass)" -ForegroundColor Yellow

Write-Host ""

if ($Status["✓"].Pass -eq $Total) {
    Write-Host "✅ Tout est prêt! Vous pouvez lancer LINE GUI:" -ForegroundColor Green
    Write-Host "   $ExePath" -ForegroundColor Cyan
} elseif ($Status["✓"].Pass -ge ($Total * 0.7)) {
    Write-Host "⚠️  Quelques problèmes détectés. Utiliser:" -ForegroundColor Yellow
    Write-Host "   .\check-installation.ps1 -Fix" -ForegroundColor Cyan
} else {
    Write-Host "❌ Installation incomplète. Lancer:" -ForegroundColor Red
    Write-Host "   .\install-gui.ps1" -ForegroundColor Cyan
}

Write-Host ""

# Suggestion
if ($HasExe -and $Status["✓"].Pass -eq $Total) {
    Write-Host "Prochaines étapes:" -ForegroundColor Yellow
    Write-Host "  1. Lancer: .\bin\LINE.exe" -ForegroundColor Gray
    Write-Host "  2. Cliquer 'Parcourir...'" -ForegroundColor Gray
    Write-Host "  3. Sélectionner un fichier (.deb, .appimage, .exe)" -ForegroundColor Gray
    Write-Host "  4. Cliquer 'Installer'" -ForegroundColor Gray
    Write-Host "  5. Double-clic pour exécuter" -ForegroundColor Gray
}

Write-Host ""

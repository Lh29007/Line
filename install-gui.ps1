#!/usr/bin/env pwsh
<#
.SYNOPSIS
Installation complète de LINE GUI

.DESCRIPTION
Installe et configure LINE GUI

.EXAMPLE
./install-gui.ps1
#>

param(
    [switch]$BuildOnly,
    [switch]$NoLaunch
)

$BaseDir = "C:\Users\aurel\Desktop\line"
$GuiDir = "$BaseDir\GUI"
$PackagesDir = "$BaseDir\packages"

Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   LINE GUI - Installation Script                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Vérifier les répertoires
Write-Host "[*] Préparation de l'environnement..." -ForegroundColor Yellow
@(
    $BaseDir,
    $GuiDir,
    $PackagesDir,
    "$PackagesDir\deb",
    "$PackagesDir\appimage",
    "$PackagesDir\bin",
    "$BaseDir\cache",
    "$BaseDir\config",
    "$BaseDir\logs"
) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
        Write-Host "  ✓ Créé: $_" -ForegroundColor Green
    }
}

Write-Host ""

# Step 2: Vérifier le .NET SDK
Write-Host "[*] Vérification du .NET SDK..." -ForegroundColor Yellow
$dotnetVersion = dotnet --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  [OK] .NET SDK: $dotnetVersion" -ForegroundColor Green
} else {
    Write-Host "  [X] .NET SDK non trouvé!" -ForegroundColor Red
    Write-Host "  Installer depuis: https://dotnet.microsoft.com/en-us/download" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Step 3: Compiler
Write-Host "[*] Compilation de LINE GUI..." -ForegroundColor Yellow
Push-Location $BaseDir

Write-Host "  → dotnet build GUI -c Release" -ForegroundColor Gray
dotnet build GUI -c Release | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "  [X] Compilation échouée!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "  [OK] Compilation réussie" -ForegroundColor Green

Write-Host ""

# Step 4: Publisher (single file .exe)
Write-Host "[*] Publication en single file..." -ForegroundColor Yellow
Write-Host "  → dotnet publish GUI -c Release -o bin" -ForegroundColor Gray
dotnet publish GUI -c Release -o bin --no-build 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "  [X] Publication échouée!" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "  [OK] Publication réussie" -ForegroundColor Green

Pop-Location

Write-Host ""

# Step 5: Vérifier le résultat
$ExePath = "$BaseDir\bin\LINE.exe"
if (Test-Path $ExePath) {
    $Size = (Get-Item $ExePath).Length / 1MB
    Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║   [OK] Installation Réussie!                       ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Exécutable: $ExePath" -ForegroundColor Cyan
    Write-Host "  Taille: $([Math]::Round($Size, 2)) MB" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "[X] Erreur: LINE.exe non trouvé!" -ForegroundColor Red
    exit 1
}

if (-not $BuildOnly) {
    Write-Host "[?] Lancer l'application maintenant?" -ForegroundColor Yellow
    Write-Host "  Y = Oui (défaut)" -ForegroundColor Gray
    Write-Host "  N = Non" -ForegroundColor Gray
    Write-Host ""
    
    if (-not $NoLaunch) {
        $Response = Read-Host "Votre choix"
        if ($Response -eq "N" -or $Response -eq "n") {
            Write-Host ""
            Write-Host "Pour lancer plus tard:" -ForegroundColor Yellow
            Write-Host "  $ExePath" -ForegroundColor Gray
            exit 0
        }
    }
    
    Write-Host ""
    Write-Host "[*] Lancement de LINE GUI..." -ForegroundColor Yellow
    & $ExePath
}

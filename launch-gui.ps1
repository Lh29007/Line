#!/usr/bin/env pwsh
<#
.SYNOPSIS
Lanceur pour LINE GUI

.DESCRIPTION
Lance l'application LINE GUI (interface WPF)

.EXAMPLE
./launch-gui.ps1
#>

$BaseDir = "C:\Users\aurel\Desktop\line"
$GuiExe = "$BaseDir\bin\LINE.exe"
$ProjectFile = "$BaseDir\GUI\GUI.csproj"

Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   LINE - GUI Launcher                              ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Vérifier le .NET SDK
Write-Host "[*] Vérification du .NET SDK..." -ForegroundColor Yellow
$dotnetVersion = dotnet --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] .NET SDK trouvé: $dotnetVersion" -ForegroundColor Green
} else {
    Write-Host "[X] Erreur: .NET SDK non trouvé" -ForegroundColor Red
    Write-Host "    Installer depuis: https://dotnet.microsoft.com/en-us/download" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Vérifier si l'EXE existe
if (Test-Path $GuiExe) {
    Write-Host "[*] Application trouvée: $GuiExe" -ForegroundColor Green
    Write-Host "[*] Lancement de LINE GUI..." -ForegroundColor Yellow
    Write-Host ""
    
    & $GuiExe
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "[OK] Application fermée correctement" -ForegroundColor Green
    }
} else {
    Write-Host "[!] L'application n'a pas été compilée" -ForegroundColor Yellow
    Write-Host "[*] Compilation en cours..." -ForegroundColor Yellow
    Write-Host ""
    
    # Build
    dotnet build $ProjectFile -c Release
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[X] Compilation échouée" -ForegroundColor Red
        exit 1
    }
    
    # Publish
    Write-Host ""
    Write-Host "[*] Publication..." -ForegroundColor Yellow
    dotnet publish "$BaseDir\GUI" -c Release -o "$BaseDir\bin" --no-build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "[OK] Compilation réussie!" -ForegroundColor Green
        Write-Host "[*] Lancement..." -ForegroundColor Yellow
        Write-Host ""
        
        & $GuiExe
    } else {
        Write-Host "[X] Publication échouée" -ForegroundColor Red
        exit 1
    }
}

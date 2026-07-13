@echo off
REM Lanceur GUI - Quick Start
REM Double-clic pour compiler et lancer LINE GUI

cls
echo.
echo ╔════════════════════════════════════════════════════╗
echo ║   LINE GUI - Quick Start                           ║
echo ║   Compilation et lancement automatique             ║
echo ╚════════════════════════════════════════════════════╝
echo.

setlocal enabledelayedexpansion

set "BASEDIR=%~dp0"
set "GUIEXE=%BASEDIR%bin\LINE.exe"

REM Vérifier .NET SDK
echo [*] Vérification du .NET SDK...
dotnet --version >nul 2>&1
if errorlevel 1 (
    echo [X] Erreur: .NET SDK non trouvé
    echo.
    echo Installer depuis: https://dotnet.microsoft.com/en-us/download
    pause
    exit /b 1
)

REM Vérifier si l'EXE existe
if exist "%GUIEXE%" (
    echo [OK] Application trouvée
    echo [*] Lancement...
    echo.
    start "" "%GUIEXE%"
    exit /b 0
)

REM Compiler si nécessaire
echo [*] Compilation en cours (première fois)...
echo.
call "%BASEDIR%install-gui.ps1" -NoLaunch
exit /b %errorlevel%

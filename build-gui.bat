@echo off
REM BUILD GUI - Script de compilation pour LINE GUI

cls
echo.
echo ╔════════════════════════════════════════════════════╗
echo ║   LINE - Build GUI Script                          ║
echo ║   Compilation de l'interface graphique WPF         ║
echo ╚════════════════════════════════════════════════════╝
echo.

REM Vérifier le .NET SDK
echo [*] Vérification du .NET SDK...
dotnet --version >nul 2>&1
if errorlevel 1 (
    echo [X] Erreur: .NET SDK non trouvé
    echo.
    echo Installer depuis: https://dotnet.microsoft.com/en-us/download
    pause
    exit /b 1
)
echo [OK] .NET SDK trouvé

echo.
echo [*] Compilation de la GUI en mode Release...
cd /d "%~dp0"

dotnet build GUI -c Release

if errorlevel 1 (
    echo.
    echo [X] Erreur lors de la compilation
    pause
    exit /b 1
)

echo.
echo [*] Publication en single file...
dotnet publish GUI -c Release -o bin

if errorlevel 1 (
    echo.
    echo [X] Erreur lors de la publication
    pause
    exit /b 1
)

echo.
echo ╔════════════════════════════════════════════════════╗
echo ║   [OK] Compilation réussie!                        ║
echo ╚════════════════════════════════════════════════════╝
echo.
echo Résultat: %CD%\bin\LINE.exe
echo.
echo Lancer:
echo   %CD%\bin\LINE.exe
echo.
pause

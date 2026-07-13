@echo off
REM BUILD.bat - Script de compilation pour LINE

cls
echo.
echo ╔════════════════════════════════════════════════════╗
echo ║   LINE - Build Script                              ║
echo ║   Compilation pour Windows                         ║
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
echo [*] Compilation en mode Release...
cd /d "%~dp0"
dotnet build -c Release

if errorlevel 1 (
    echo.
    echo [X] Erreur lors de la compilation
    pause
    exit /b 1
)

echo.
echo [*] Publication en single file...
dotnet publish -c Release -o bin

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
echo Résultat: %CD%\bin\line.exe
echo.
echo Test:
echo   %CD%\bin\line.exe --help
echo.
pause

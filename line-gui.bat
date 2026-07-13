@echo off
REM Lanceur LINE GUI - PowerShell Edition
REM Fonctionne sans .NET, sans Admin, pur PowerShell!

cls
echo.
echo  ╔════════════════════════════════════════════════════════╗
echo  ║  LINE GUI - PowerShell Edition                        ║
echo  ║  Fonctionne sans .NET ni Admin!                       ║
echo  ╚════════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "line-gui.ps1"

@echo off
REM LINE - Launcher pour PowerShell Edition
setlocal enabledelayedexpansion
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"
powershell -ExecutionPolicy Bypass -File "line.ps1" %*
exit /b %errorlevel%

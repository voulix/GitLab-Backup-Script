@echo off
REM Script-Pfad relativ zu dieser BAT-Datei bestimmen
set SCRIPT_DIR=%~dp0
set SCRIPT_PATH=%SCRIPT_DIR%backup-gitlab.ps1

REM PowerShell-Skript ausführen
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"

pause
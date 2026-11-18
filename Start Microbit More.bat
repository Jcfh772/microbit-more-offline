@echo off
setlocal
rem ---------------------------------------------------------------
rem  Microbit More - offline editor launcher
rem  Browser to use: auto (Edge, then Chrome), edge or chrome
set "MBM_BROWSER=auto"
rem ---------------------------------------------------------------

if not exist "%~dp0app\server.ps1" (
  echo Please extract the whole zip file first, then run this file again.
  echo.
  pause
  exit /b 1
)

where powershell.exe >nul 2>&1
if errorlevel 1 (
  echo Windows PowerShell was not found on this computer.
  echo.
  pause
  exit /b 1
)

rem Runs the small local web server in a minimized window and opens the editor.
start "Microbit More" /min powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0app\server.ps1" -Browser %MBM_BROWSER%
exit /b 0

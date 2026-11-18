@echo off
setlocal
title Install Microbit More program on micro:bit
if not exist "%~dp0app\flash.ps1" (
  echo Please extract the whole zip file first, then run this file again.
  echo.
  pause
  exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0app\flash.ps1"
echo.
pause

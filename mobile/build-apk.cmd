@echo off
rem Double-click this file to build a release APK in one step.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build-apk.ps1" %*
echo.
pause

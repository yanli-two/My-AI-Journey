@echo off
title QQBot Stopper
echo Stopping AstrBot and SnowLuma ...
powershell -NoProfile -ExecutionPolicy Bypass -File "D:\AI\QQBot\stop-all.ps1"
echo.
echo Stopped. Use start-all.bat to bring the bot back.
ping -n 6 127.0.0.1 >nul

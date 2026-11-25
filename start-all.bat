@echo off
chcp 65001 >nul
title QQ Bot Launcher
powershell -NoProfile -ExecutionPolicy Bypass -File "D:\AI\QQBot\start-all.ps1"
if errorlevel 1 (
    echo.
    echo [ERROR] Launcher failed. Press any key to close.
    pause >nul
)

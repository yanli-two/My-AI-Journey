@echo off
REM ==== Start services only (no browser). Safe to run repeatedly. ====
setlocal

netstat -ano | findstr ":5099 " | findstr LISTENING >nul
if errorlevel 1 (
    start "SnowLuma" /min "D:\AI\QQBot\run-snowluma.bat"
    echo [1/2] SnowLuma starting ...
) else (
    echo [1/2] SnowLuma already running
)

ping -n 9 127.0.0.1 >nul

netstat -ano | findstr ":6199 " | findstr LISTENING >nul
if errorlevel 1 (
    start "AstrBot" /min "D:\AI\QQBot\run-astrbot.bat"
    echo [2/2] AstrBot starting ...
) else (
    echo [2/2] AstrBot already running
)

endlocal

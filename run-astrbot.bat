@echo off
REM AstrBot runner with persistent log
cd /d "D:\AI\QQBot\astrbot"
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8
"D:\AI\QQBot\venv\Scripts\python.exe" main.py > "D:\AI\QQBot\_logs\astrbot.log" 2>&1

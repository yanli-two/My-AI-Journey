@echo off
REM SnowLuma runner with persistent log
cd /d "D:\AI\QQBot\snowluma"
"D:\AI\QQBot\snowluma\node.exe" "D:\AI\QQBot\snowluma\index.mjs" > "D:\AI\QQBot\_logs\snowluma.log" 2>&1

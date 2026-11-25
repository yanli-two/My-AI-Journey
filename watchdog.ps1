# QQBot watchdog: restart a service only if its port is closed (i.e. the process died).
# Exits when the stop flag exists, so stop-all.bat is respected.
$ErrorActionPreference = 'SilentlyContinue'
$root = 'D:\AI\QQBot'
$flag = Join-Path $root '_logs\watchdog.stop'

$mutex = New-Object System.Threading.Mutex($false, 'QQBotWatchdogMutex')
if (-not $mutex.WaitOne(0)) { exit }   # already running

function Test-Port([int]$p) {
    return [bool](Get-NetTCPConnection -State Listen -LocalPort $p -ErrorAction SilentlyContinue)
}

while ($true) {
    if (Test-Path $flag) { break }

    if (-not (Test-Port 5099)) {
        Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','"D:\AI\QQBot\run-snowluma.bat"' -WindowStyle Hidden
        Start-Sleep -Seconds 20
    }
    if (-not (Test-Port 6199)) {
        Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','"D:\AI\QQBot\run-astrbot.bat"' -WindowStyle Hidden
        Start-Sleep -Seconds 15
    }
    Start-Sleep -Seconds 45
}

$mutex.ReleaseMutex()

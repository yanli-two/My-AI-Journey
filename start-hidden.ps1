# Silent autostart: QQ -> SnowLuma -> AstrBot -> watchdog.
# 带重试：即使 360 在开机时拦掉第一次启动，也会自动再试，直到端口起来。

$ErrorActionPreference = 'Continue'
$root = 'D:\AI\QQBot'
$flag = Join-Path $root '_logs\watchdog.stop'
$log = Join-Path $root '_logs\autostart.log'

if (Test-Path $flag) { Remove-Item $flag -Force -ErrorAction SilentlyContinue }

function Write-Log([string]$msg) {
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg"
    Add-Content -Path $log -Value $line -Encoding UTF8 -ErrorAction SilentlyContinue
}

function Test-Port([int]$p) {
    return [bool](Get-NetTCPConnection -State Listen -LocalPort $p -ErrorAction SilentlyContinue)
}

Write-Log "autostart begin"

# 0) 给 360 之类留出启动窗口，避免开机瞬间和它抢
Start-Sleep -Seconds 20

# 1) QQ 必须先起来
if (-not (Get-Process -Name QQ -ErrorAction SilentlyContinue)) {
    $exe = 'D:\Program Files\Tencent\QQNT\QQ.exe'
    if (Test-Path $exe) {
        Start-Process -FilePath $exe
        Write-Log "qq launched"
        Start-Sleep -Seconds 25
    }
}

# 2) SnowLuma：最多试 6 次，每次间隔 40 秒
for ($i = 1; $i -le 6; $i++) {
    if (Test-Port 5099) { break }
    Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','"D:\AI\QQBot\run-snowluma.bat"' -WindowStyle Hidden
    Write-Log "snowluma start attempt $i"
    Start-Sleep -Seconds 40
}
Write-Log ("snowluma port 5099 = " + (Test-Port 5099))

# 3) AstrBot：同样重试
for ($i = 1; $i -le 4; $i++) {
    if (Test-Port 6199) { break }
    Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','"D:\AI\QQBot\run-astrbot.bat"' -WindowStyle Hidden
    Write-Log "astrbot start attempt $i"
    Start-Sleep -Seconds 35
}
Write-Log ("astrbot port 6199 = " + (Test-Port 6199))

# 4) 看门狗
$wd = Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" |
      Where-Object { $_.CommandLine -like '*-File*QQBot\watchdog.ps1*' }
if (-not $wd) {
    Start-Process -FilePath 'powershell.exe' `
        -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-WindowStyle','Hidden','-File','"D:\AI\QQBot\watchdog.ps1"' `
        -WindowStyle Hidden
    Write-Log "watchdog started"
}

Write-Log "autostart done"

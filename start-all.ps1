# QQ Bot 启动器（带自检，窗口不会一闪而过）
$ErrorActionPreference = 'Continue'
$Root = 'D:\AI\QQBot'

function Test-Port([int]$p) {
    return [bool](Get-NetTCPConnection -State Listen -LocalPort $p -ErrorAction SilentlyContinue)
}
function Test-QQ {
    return [bool](Get-Process -Name QQ -ErrorAction SilentlyContinue)
}

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "   QQ 机器人启动器  空晞 (3695820197)" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# ---------- 1. QQ 客户端 ----------
Write-Host "[1/4] 检查 QQ 客户端 ..." -NoNewline
if (Test-QQ) {
    Write-Host " 已在运行" -ForegroundColor Green
} else {
    $exe = 'D:\Program Files\Tencent\QQNT\QQ.exe'
    if (Test-Path $exe) {
        Start-Process -FilePath $exe
        Write-Host " 已拉起，等待登录窗口 ..." -ForegroundColor Yellow
        Start-Sleep -Seconds 15
    } else {
        Write-Host " 找不到 QQ.exe！" -ForegroundColor Red
    }
}

# ---------- 2. SnowLuma ----------
Write-Host "[2/4] 检查 SnowLuma ..." -NoNewline
$needWait = $false
if (Test-Port 5099) {
    Write-Host " 已在运行" -ForegroundColor Green
} else {
    Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','"D:\AI\QQBot\run-snowluma.bat"' -WindowStyle Hidden
    Write-Host " 启动中 ..." -ForegroundColor Yellow
    $needWait = $true
}

# ---------- 3. 等 OneBot 端口（QQ 登录后才会开） ----------
Write-Host "[3/4] 等待 OneBot(3000) 就绪 ..." -NoNewline
$ok = $false
$loops = if ($needWait) { 24 } else { 3 }
for ($i = 0; $i -lt $loops; $i++) {
    if (Test-Port 3000) { $ok = $true; break }
    Start-Sleep -Seconds 5
}
if (-not $ok) {
    Write-Host " 未就绪，重启 SnowLuma 重试 ..." -ForegroundColor Yellow
    Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','"D:\AI\QQBot\run-snowluma.bat"' -WindowStyle Hidden
    for ($i = 0; $i -lt 18; $i++) {
        if (Test-Port 3000) { $ok = $true; break }
        Start-Sleep -Seconds 5
    }
}

if ($ok) {
    Write-Host " OneBot 已就绪" -ForegroundColor Green
} else {
    Write-Host " 未就绪" -ForegroundColor Red
    Write-Host ""
    Write-Host "  >>> QQ 还没有登录。" -ForegroundColor Yellow
    Write-Host "  >>> 请在任务栏找到 QQ 窗口，用手机扫码登录；" -ForegroundColor Yellow
    Write-Host "  >>> 登录成功后再双击一次 start-all.bat 即可。" -ForegroundColor Yellow
}

# ---------- 4. AstrBot ----------
Write-Host "[4/4] 检查 AstrBot ..." -NoNewline
if (Test-Port 6199) {
    Write-Host " 已在运行" -ForegroundColor Green
} else {
    Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','"D:\AI\QQBot\run-astrbot.bat"' -WindowStyle Hidden
    Write-Host " 启动中 ..." -ForegroundColor Yellow
    Start-Sleep -Seconds 25
}

# ---------- 汇总 ----------
Write-Host ""
Write-Host "---------------- 当前状态 ----------------" -ForegroundColor Cyan
$ports = @(
    @{ Name = 'SnowLuma WebUI'; Port = 5099 },
    @{ Name = 'OneBot HTTP  '; Port = 3000 },
    @{ Name = 'AstrBot WebUI'; Port = 6185 },
    @{ Name = 'AstrBot 反向WS'; Port = 6199 }
)
foreach ($p in $ports) {
    if (Test-Port $p.Port) {
        Write-Host ("  {0}  {1}  [OK]" -f $p.Name, $p.Port) -ForegroundColor Green
    } else {
        Write-Host ("  {0}  {1}  [未启动]" -f $p.Name, $p.Port) -ForegroundColor Red
    }
}
if (Test-QQ) { Write-Host "  QQ 客户端      运行中" -ForegroundColor Green }
else { Write-Host "  QQ 客户端      未运行" -ForegroundColor Red }

Write-Host ""
Write-Host "  面板: http://127.0.0.1:5099  /  http://127.0.0.1:6185" -ForegroundColor Gray
Write-Host "  停止: 双击 stop-all.bat" -ForegroundColor Gray
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""
Read-Host "按回车键关闭本窗口"

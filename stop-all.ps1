# Stop the bot: set the stop flag (so the watchdog stays down), kill the watchdog, then kill services by port.
$ErrorActionPreference = 'SilentlyContinue'
$flag = 'D:\AI\QQBot\_logs\watchdog.stop'

New-Item -ItemType File -Path $flag -Force | Out-Null

# only match the real watchdog process (launched with -File), never this script or the caller
Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" |
    Where-Object { $_.ProcessId -ne $PID -and $_.CommandLine -like '*-File*QQBot\watchdog.ps1*' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

$ports = 5099, 6199, 3000, 3001, 6185
$pids = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
        Where-Object { $ports -contains $_.LocalPort } |
        Select-Object -ExpandProperty OwningProcess -Unique

foreach ($p in $pids) {
    try {
        Stop-Process -Id $p -Force -ErrorAction Stop
        Write-Host ("  stopped PID " + $p)
    } catch {}
}
Write-Host 'done'

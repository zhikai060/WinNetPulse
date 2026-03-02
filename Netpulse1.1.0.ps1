<#
NetPulse v1.1
Upgrades:
- Packet Loss %
- Colorized latency display
- Full summary block after completion
- Infinite mode shows "Press Enter to exit"
#>

param()

function Show-Header {
    Clear-Host
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host "        NetPulse v1.1" -ForegroundColor Green
    Write-Host "===============================" -ForegroundColor Cyan
}

function Get-Target {
    Read-Host "Enter IP or domain"
}

function Get-Mode {
    $mode = Read-Host "Choose mode: (1) Ping [Default]  (2) Tracert"
    if ($mode -eq "2") { return "tracert" }
    return "ping"
}

function Get-PingCount {
    Write-Host "Select ping count:" -ForegroundColor Yellow
    Write-Host "1) 10"
    Write-Host "2) 30"
    Write-Host "3) 50"
    Write-Host "4) 100"
    Write-Host "5) Infinite (-t)"

    $choice = Read-Host "Choose (1-5)"

    switch ($choice) {
        "1" { return 10 }
        "2" { return 30 }
        "3" { return 50 }
        "4" { return 100 }
        "5" { return -1 }
        default { return 10 }
    }
}

function Ask-ExportCSV {
    $export = Read-Host "Export result to CSV? (Y/N)"
    if ($export -match "^[Yy]$") { return $true }
    return $false
}

function Write-ColoredLatency($time, $text) {
    if ($time -lt 20) {
        Write-Host $text -ForegroundColor Green
    }
    elseif ($time -lt 80) {
        Write-Host $text -ForegroundColor Yellow
    }
    else {
        Write-Host $text -ForegroundColor Red
    }
}

function Show-Summary($target, $sent, $received, $min, $max, $avg) {
    $lost = $sent - $received
    if ($sent -gt 0) {
        $lossPercent = [math]::Round(($lost / $sent) * 100,2)
    } else {
        $lossPercent = 0
    }

    Write-Host "`n===== NetPulse Summary =====" -ForegroundColor Cyan
    Write-Host "Target: $target"
    Write-Host "Packets: Sent = $sent, Received = $received, Lost = $lost ($lossPercent`%)"
    Write-Host "Min = ${min}ms"
    Write-Host "Max = ${max}ms"
    Write-Host "Avg = ${avg}ms"
    Write-Host "=============================" -ForegroundColor Cyan
}

function Start-Tracert($target) {
    Write-Host "Starting tracert..." -ForegroundColor Cyan
    tracert $target
}

function Start-Ping($target, $count, $exportCSV) {

    $results = @()
    $min = [int]::MaxValue
    $max = 0
    $sum = 0
    $sent = 0
    $received = 0

    if ($count -eq -1) {
        Write-Host "Infinite ping. Press Q to stop." -ForegroundColor Yellow
        while ($true) {
            if ([console]::KeyAvailable) {
                $key = [console]::ReadKey($true)
                if ($key.Key -eq 'Q') { break }
            }

            $sent++
            $reply = Test-Connection -ComputerName $target -Count 1 -ErrorAction SilentlyContinue

            if ($reply) {
                $time = $reply.ResponseTime
                $ttl = $reply.TimeToLive
                $received++

                if ($time -lt $min) { $min = $time }
                if ($time -gt $max) { $max = $time }
                $sum += $time
                $avg = [math]::Round($sum / $received,2)

                $text = "[$sent] Time=${time}ms TTL=$ttl"
                Write-ColoredLatency $time $text
            }
            else {
                Write-Host "[$sent] Request timed out." -ForegroundColor Red
            }

            Start-Sleep -Seconds 1
        }

        if ($received -gt 0) {
            $avg = [math]::Round($sum / $received,2)
        } else {
            $min = 0
            $avg = 0
        }

        Show-Summary $target $sent $received $min $max $avg
        Write-Host "`nPress Enter to exit..." -ForegroundColor DarkGray
        Read-Host | Out-Null
        return
    }

    if ($exportCSV) {
        $csvPath = Join-Path $PSScriptRoot "ping_result.csv"
    }

    for ($i=1; $i -le $count; $i++) {
        $sent++
        $reply = Test-Connection -ComputerName $target -Count 1 -ErrorAction SilentlyContinue

        if ($reply) {
            $time = $reply.ResponseTime
            $ttl = $reply.TimeToLive
            $received++

            if ($time -lt $min) { $min = $time }
            if ($time -gt $max) { $max = $time }
            $sum += $time
            $avg = [math]::Round($sum / $received,2)

            $text = "[$i/$count] Time=${time}ms TTL=$ttl"
            Write-ColoredLatency $time $text

            if ($exportCSV) {
                $results += [pscustomobject]@{
                    Index = $i
                    Time_ms = $time
                    TTL = $ttl
                }
            }
        }
        else {
            Write-Host "[$i/$count] Request timed out." -ForegroundColor Red
        }

        Start-Sleep -Seconds 1
    }

    if ($received -gt 0) {
        $avg = [math]::Round($sum / $received,2)
    } else {
        $min = 0
        $avg = 0
    }

    Show-Summary $target $sent $received $min $max $avg

    if ($exportCSV) {
        $results | Export-Csv $csvPath -NoTypeInformation -Encoding UTF8
        Write-Host "CSV exported to $csvPath" -ForegroundColor Green
    }

    Write-Host "`nPress Enter to exit..." -ForegroundColor DarkGray
    Read-Host | Out-Null
}

Show-Header
$target = Get-Target
$mode = Get-Mode

if ($mode -eq "tracert") {
    Start-Tracert $target
    Write-Host "`nPress Enter to exit..." -ForegroundColor DarkGray
    Read-Host | Out-Null
}
else {
    $count = Get-PingCount
    $export = $false
    if ($count -ne -1) {
        $export = Ask-ExportCSV
    }
    Start-Ping $target $count $export
}

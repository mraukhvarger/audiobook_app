# One command to get the app running on the emulator:
#   1. launches the AVD (if no device is connected)
#   2. waits for the device to finish booting
#   3. pushes test_books into /sdcard/Download/test_books
#   4. runs the app with `flutter run`
#
# Usage:
#   .\run-emulator.ps1
#   .\run-emulator.ps1 -Avd pixel8 -SkipPush
#   .\run-emulator.ps1 -SkipRun   (prepare device and books only)

param(
    [string]$Avd = "pixel8",
    [switch]$SkipPush,
    [switch]$SkipRun
)

$ErrorActionPreference = "Stop"

function Get-AdbDevice {
    $output = & adb devices
    foreach ($line in $output) {
        if ($line -match '^(\S+)\s+device\s*$') { return $Matches[1] }
    }
    return $null
}

function Wait-ForBoot {
    do {
        Start-Sleep -Seconds 2
        $boot = ""
        try {
            $boot = (& adb shell getprop sys.boot_completed 2>$null | Out-String).Trim()
        }
        catch {
            $boot = ""
        }
    } while ($boot -ne "1")
}

Push-Location $PSScriptRoot
try {
    $target = Get-AdbDevice
    if (-not $target) {
        Write-Host "`n=== launching emulator '$Avd' ===" -ForegroundColor Cyan
        flutter emulators --launch $Avd
        if ($LASTEXITCODE -ne 0) { throw "failed to launch emulator '$Avd'" }
        Write-Host "waiting for the device to appear..."
        adb wait-for-device
    }
    else {
        Write-Host "Using already connected device: $target"
    }

    Write-Host "`n=== waiting for boot to complete ===" -ForegroundColor Cyan
    Wait-ForBoot

    $target = Get-AdbDevice
    if (-not $target) { throw "no adb device found after boot" }
    Write-Host "Device ready: $target"

    Write-Host "`n=== setting media volume to maximum ===" -ForegroundColor Cyan
    1..15 | ForEach-Object { adb -s $target shell input keyevent 24 | Out-Null }
    adb -s $target shell settings put system volume_music 15 | Out-Null
    Write-Host "media volume: $(adb -s $target shell settings get system volume_music)"

    if (-not $SkipPush) {
        $pushScript = Join-Path $PSScriptRoot "..\scripts\push-test-books.ps1"
        if (Test-Path -LiteralPath $pushScript) {
            Write-Host "`n=== pushing test books ===" -ForegroundColor Cyan
            & $pushScript -Device $target
            if ($LASTEXITCODE -ne 0) { throw "pushing test books failed" }
        }
        else {
            Write-Host "push-test-books.ps1 not found, skipping push" -ForegroundColor Yellow
        }
    }

    if ($SkipRun) {
        Write-Host "`nDevice is ready; skipping 'flutter run' (-SkipRun)." -ForegroundColor Green
        return
    }

    Write-Host "`n=== flutter run -d $target ===" -ForegroundColor Cyan
    flutter run -d $target
}
finally {
    Pop-Location
}

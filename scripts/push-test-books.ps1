param(
    [string]$Source = (Join-Path $PSScriptRoot "..\test_books"),
    [string]$Device = "",
    [string]$Destination = "/sdcard/Download/test_books"
)

$ErrorActionPreference = "Stop"

$resolved = (Resolve-Path -LiteralPath $Source).Path
$adbArgs = @()
if ($Device) { $adbArgs = @("-s", $Device) }

Write-Host "Pushing '$resolved' -> $Destination"
& adb @adbArgs shell "rm -rf '$Destination'"
if ($LASTEXITCODE -ne 0) { throw "adb shell failed" }
& adb @adbArgs push "$resolved" $Destination
if ($LASTEXITCODE -ne 0) { throw "adb push failed" }
& adb @adbArgs shell "ls -la '$Destination'"
Write-Host "Done. In the app pick Download/test_books via the SAF dialog."

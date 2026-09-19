# Runs the full quality gate for the Flutter app:
# dependencies, static analysis, formatting check and all tests.
# Usage:  .\test-all.ps1

$ErrorActionPreference = "Stop"

Push-Location $PSScriptRoot
try {
    Write-Host "`n=== flutter pub get ===" -ForegroundColor Cyan
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed" }

    Write-Host "`n=== flutter analyze ===" -ForegroundColor Cyan
    flutter analyze
    if ($LASTEXITCODE -ne 0) { throw "flutter analyze failed" }

    Write-Host "`n=== dart format --set-exit-if-changed lib test ===" -ForegroundColor Cyan
    dart format --set-exit-if-changed lib test
    if ($LASTEXITCODE -ne 0) { throw "formatting check failed" }

    Write-Host "`n=== flutter test ===" -ForegroundColor Cyan
    flutter test
    if ($LASTEXITCODE -ne 0) { throw "tests failed" }

    Write-Host "`nAll checks passed." -ForegroundColor Green
}
finally {
    Pop-Location
}

# Packages the app for installing on an Android phone.
#   1. resolves dependencies
#   2. regenerates drift/build_runner code
#   3. builds a release APK (signed with the debug key, fine for sideloading)
#   4. optionally installs it on the connected device
#
# Usage:
#   .\build-apk.ps1                 # universal release APK
#   .\build-apk.ps1 -Install        # build and install on the phone
#   .\build-apk.ps1 -Split          # smaller per-ABI APKs
#   .\build-apk.ps1 -Bundle         # Play Store .aab instead of APK
#   .\build-apk.ps1 -SkipCodegen    # skip build_runner

param(
    [switch]$Split,
    [switch]$Bundle,
    [switch]$Install,
    [switch]$SkipCodegen,
    [string]$Device = ""
)

$ErrorActionPreference = "Stop"

function Get-AdbDevice {
    $output = & adb devices
    foreach ($line in $output) {
        if ($line -match '^(\S+)\s+device\s*$') { return $Matches[1] }
    }
    return $null
}

Push-Location $PSScriptRoot
try {
    $keyProperties = Join-Path $PSScriptRoot "android\key.properties"
    if (-not (Test-Path -LiteralPath $keyProperties)) {
        Write-Host "`n=== no release keystore configured ===" -ForegroundColor Yellow
        & (Join-Path $PSScriptRoot "android\create-keystore.ps1")
        if ($LASTEXITCODE -ne 0) { throw "keystore setup failed" }
    }

    Write-Host "`n=== flutter pub get ===" -ForegroundColor Cyan
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed" }

    if (-not $SkipCodegen) {
        Write-Host "`n=== drift / build_runner codegen ===" -ForegroundColor Cyan
        dart run build_runner build
        if ($LASTEXITCODE -ne 0) { throw "code generation failed" }
    }

    if ($Bundle) {
        Write-Host "`n=== flutter build appbundle --release ===" -ForegroundColor Cyan
        flutter build appbundle --release
        if ($LASTEXITCODE -ne 0) { throw "appbundle build failed" }
        $artifactDir = "build\app\outputs\bundle\release"
        $apkPath = Join-Path $artifactDir "app-release.aab"
    }
    elseif ($Split) {
        Write-Host "`n=== flutter build apk --release --split-per-abi ===" -ForegroundColor Cyan
        flutter build apk --release --split-per-abi
        if ($LASTEXITCODE -ne 0) { throw "apk build failed" }
        $artifactDir = "build\app\outputs\flutter-apk"
        $apkPath = ""
    }
    else {
        Write-Host "`n=== flutter build apk --release ===" -ForegroundColor Cyan
        flutter build apk --release
        if ($LASTEXITCODE -ne 0) { throw "apk build failed" }
        $artifactDir = "build\app\outputs\flutter-apk"
        $apkPath = Join-Path $artifactDir "app-release.apk"
    }

    Write-Host "`n=== artifact ===" -ForegroundColor Green
    if ($Bundle -or -not $Split) {
        $full = (Resolve-Path -LiteralPath $apkPath).Path
        $sizeMb = [math]::Round((Get-Item -LiteralPath $full).Length / 1MB, 1)
        Write-Host "$full ($sizeMb MB)"
    }
    else {
        Get-ChildItem -LiteralPath $artifactDir -Filter *.apk | ForEach-Object {
            $sizeMb = [math]::Round($_.Length / 1MB, 1)
            Write-Host "$($_.FullName) ($sizeMb MB)"
        }
    }

    if (-not $Install) {
        Write-Host "`nCopy the APK to the phone and open it, or re-run with -Install." -ForegroundColor Yellow
        return
    }

    $target = if ($Device) { $Device } else { Get-AdbDevice }
    if (-not $target) { throw "no adb device connected (connect the phone with USB debugging)" }

    Write-Host "`n=== installing on $target ===" -ForegroundColor Cyan
    if ($Split) {
        $apks = (Get-ChildItem -LiteralPath $artifactDir -Filter *.apk).FullName
        & adb -s $target install-multiple -r @apks
    }
    else {
        & adb -s $target install -r (Resolve-Path -LiteralPath $apkPath).Path
    }
    if ($LASTEXITCODE -ne 0) { throw "install failed" }
    Write-Host "`nInstalled. Launch 'player_book' on the phone." -ForegroundColor Green
}
finally {
    Pop-Location
}

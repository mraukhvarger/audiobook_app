# Creates the release signing keystore and android/key.properties.
# Run once; afterwards build-apk.ps1 signs release builds with it.
#
# Usage:
#   .\create-keystore.ps1
#   .\create-keystore.ps1 -Alias playerbook -Force
#
# Keep the generated .jks file and the password safe: losing them means you
# can no longer publish updates to an already released app.

param(
    [string]$Alias = "playerbook",
    [string]$DistinguishedName = "CN=Player Book, O=Player Book, C=RU",
    [int]$ValidityDays = 10000,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$keystoreDir = Join-Path $PSScriptRoot "keystore"
$keystorePath = Join-Path $keystoreDir "$Alias-release.jks"
$propertiesPath = Join-Path $PSScriptRoot "key.properties"

function Resolve-Keytool {
    $command = Get-Command keytool -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    $jbr = Join-Path $env:ProgramFiles "Android\Android Studio\jbr\bin\keytool.exe"
    if (Test-Path -LiteralPath $jbr) { return $jbr }
    throw "keytool not found. Install a JDK or Android Studio's JBR."
}

function ConvertTo-PlainText([System.Security.SecureString]$Secure) {
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secure)
    try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

if ((Test-Path -LiteralPath $keystorePath) -and -not $Force) {
    throw "'$keystorePath' already exists. Pass -Force to overwrite (existing releases would break)."
}

$password = Read-Host "Keystore password (you will need it again - store it safely)" -AsSecureString
$confirm = Read-Host "Repeat the password" -AsSecureString
if ((ConvertTo-PlainText $password) -ne (ConvertTo-PlainText $confirm)) {
    throw "Passwords do not match."
}

$keytool = Resolve-Keytool
New-Item -ItemType Directory -Path $keystoreDir -Force | Out-Null

Write-Host "`n=== generating keystore '$keystorePath' ===" -ForegroundColor Cyan
& $keytool -genkeypair -v `
    -keystore $keystorePath `
    -alias $Alias `
    -keyalg RSA -keysize 2048 -validity $ValidityDays `
    -storetype PKCS12 `
    -dname $DistinguishedName `
    -storepass (ConvertTo-PlainText $password) `
    -keypass (ConvertTo-PlainText $password)
if ($LASTEXITCODE -ne 0) { throw "keytool failed" }

function Escape-Property([string]$Value) {
    return $Value.Replace("\", "\\")
}

$plain = ConvertTo-PlainText $password
$storeFile = $keystorePath.Replace("\", "/")
$content = @(
    "storePassword=$(Escape-Property $plain)"
    "keyPassword=$(Escape-Property $plain)"
    "keyAlias=$Alias"
    "storeFile=$storeFile"
) -join [Environment]::NewLine
# UTF-8 without BOM: Java's Properties.load would treat a BOM as part of the key.
[System.IO.File]::WriteAllText($propertiesPath, $content + [Environment]::NewLine)

Write-Host "`nWrote $propertiesPath" -ForegroundColor Green
Write-Host "Back up '$keystorePath' and the password somewhere safe." -ForegroundColor Yellow

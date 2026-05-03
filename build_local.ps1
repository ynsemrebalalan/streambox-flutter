# Lokal Android APK build + ADB install. RC + GROQ key'leri secrets.local.properties'ten okur.
#
# Kullanim:
#   .\build_local.ps1                 # APK build + (opsiyonel) ADB install
#   .\build_local.ps1 -InstallOnly    # mevcut APK'yi tekrar install et
#   .\build_local.ps1 -NoInstall      # sadece build
#
# Ilk kullanim: secrets.local.properties.example dosyasini kopyala,
# adini secrets.local.properties yap, RC key'lerini gir.

param(
  [switch]$InstallOnly,
  [switch]$NoInstall
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$secretsFile = Join-Path $root "secrets.local.properties"
$apkPath = Join-Path $root "build\app\outputs\flutter-apk\app-release.apk"

function Read-Secrets {
  param($path)
  if (-not (Test-Path $path)) {
    Write-Host "[hata] $path bulunamadi." -ForegroundColor Red
    Write-Host "       secrets.local.properties.example dosyasini kopyala -> secrets.local.properties yap, RC key'lerini gir." -ForegroundColor Yellow
    exit 1
  }
  $hash = @{}
  Get-Content $path | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
      $parts = $line.Split("=", 2)
      $hash[$parts[0].Trim()] = $parts[1].Trim()
    }
  }
  return $hash
}

if (-not $InstallOnly) {
  Write-Host "==> Secrets okunuyor..." -ForegroundColor Cyan
  $secrets = Read-Secrets $secretsFile

  $rcAndroid = $secrets["REVENUECAT_ANDROID_KEY"]
  $rcIos     = $secrets["REVENUECAT_IOS_KEY"]
  $groqUrl   = $secrets["GROQ_PROXY_URL"]
  $groqSec   = $secrets["GROQ_PROXY_SECRET"]

  if (-not $rcAndroid -or $rcAndroid -eq "goog_REPLACE_ME") {
    Write-Host "[hata] REVENUECAT_ANDROID_KEY secrets.local.properties'te yok veya placeholder." -ForegroundColor Red
    exit 1
  }

  $defines = @(
    "--dart-define=REVENUECAT_ANDROID_KEY=$rcAndroid",
    "--dart-define=REVENUECAT_IOS_KEY=$rcIos"
  )
  if ($groqUrl) { $defines += "--dart-define=GROQ_PROXY_URL=$groqUrl" }
  if ($groqSec) { $defines += "--dart-define=GROQ_PROXY_SECRET=$groqSec" }

  Write-Host "==> flutter build apk --release ..." -ForegroundColor Cyan
  Set-Location $root
  $args = @("build", "apk", "--release") + $defines
  & flutter @args
  if ($LASTEXITCODE -ne 0) {
    Write-Host "[hata] flutter build basarisiz." -ForegroundColor Red
    exit $LASTEXITCODE
  }
}

if ($NoInstall) {
  Write-Host "==> APK: $apkPath" -ForegroundColor Green
  exit 0
}

Write-Host "==> ADB cihaz kontrolu..." -ForegroundColor Cyan
$devices = & adb devices | Select-String "device$" | Where-Object { $_ -notmatch "List of devices" }
if (-not $devices) {
  Write-Host "[uyari] Bagli cihaz bulunamadi. APK manuel transfer et: $apkPath" -ForegroundColor Yellow
  exit 0
}

Write-Host "==> APK install ediliyor..." -ForegroundColor Cyan
& adb install -r $apkPath
if ($LASTEXITCODE -eq 0) {
  Write-Host "==> Install tamam." -ForegroundColor Green
} else {
  Write-Host "[hata] adb install fail. APK: $apkPath" -ForegroundColor Red
}

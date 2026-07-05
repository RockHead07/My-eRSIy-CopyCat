<#
  reintegrate-unity.ps1 — re-apply the DARSI UaaL integration after a fresh
  Unity "Export Project". Unity regenerates unityLibrary/ + shared/ on every
  export and re-introduces the same AGP-9 incompatibilities, so this script
  re-applies them in one shot. See memory: uaal-entry-point-status (T4.4).

  Usage (from anywhere):
    pwsh -File tool\reintegrate-unity.ps1                       # export at Downloads\DARSI
    pwsh -File tool\reintegrate-unity.ps1 -Export "C:\path\to\export"

  After it finishes:
    $env:JAVA_HOME="D:\Dev\Tools\Android\Android Studio\jbr"
    $env:ANDROID_HOME="D:\Dev\SDKs\Android\Sdk"
    flutter build apk --debug
#>
param(
    [string]$Export = "C:\Users\UNKNOWN\Downloads\DARSI"
)
$ErrorActionPreference = "Stop"

# Repo android/ dir = parent of this script's tool/ folder + \android
$android = Join-Path (Split-Path -Parent $PSScriptRoot) "android"
$patched = Join-Path $PSScriptRoot "unity-patches\unityandroidpermissions.aar"

if (-not (Test-Path "$Export\unityLibrary")) { throw "No unityLibrary/ under $Export — did you Export Project (not Build)?" }
if (-not (Test-Path $patched))                { throw "Missing known-good aar at $patched" }

Write-Host "==> Copying unityLibrary + shared from $Export"
Remove-Item "$android\unityLibrary" -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item   "$Export\unityLibrary" "$android\unityLibrary" -Recurse -Force
Copy-Item   "$Export\shared"       "$android\shared"       -Recurse -Force

# Patch 1: unityandroidpermissions.aar declares package="com.google.ar.core"
# (stale Google template bug) which collides with arcore_client.aar under AGP 9.
# Its classes.jar is static across exports, so drop in the known-good patched copy.
Write-Host "==> Patch 1: overwrite buggy unityandroidpermissions.aar with known-good"
Copy-Item $patched "$android\unityLibrary\libs\unityandroidpermissions.aar" -Force

# Patch 2: AGP 9 forbids the global keep option -ignorewarnings in a consumer
# proguard file (:unityLibrary:mergeDebugConsumerProguardFiles). Comment it out.
Write-Host "==> Patch 2: comment out -ignorewarnings in proguard-unity.txt"
$pg = "$android\unityLibrary\proguard-unity.txt"
(Get-Content $pg) -replace '^\s*-ignorewarnings\s*$', '# -ignorewarnings  # removed for AGP 9 (consumer proguard)' |
    Set-Content $pg -Encoding utf8

# NOTE: orientation (screenOrientation=portrait) and the host-side manifest
# overrides (strip Unity LAUNCHER, tools:replace icon/label/exported) do NOT need
# re-applying: the former is now baked from Player Settings = Portrait, the latter
# live in the app's own AndroidManifest.xml which the export never touches.

Write-Host "`n==> Done. Now build:"
Write-Host '    $env:JAVA_HOME="D:\Dev\Tools\Android\Android Studio\jbr"'
Write-Host '    $env:ANDROID_HOME="D:\Dev\SDKs\Android\Sdk"'
Write-Host '    flutter build apk --debug'

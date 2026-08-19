param(
    [Parameter(Mandatory=$true)]
    [string]$Raz
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Exe = Join-Path $Root "target\debug\raz-package-demo.exe"
Set-Location $Root

Write-Host "== Resolve and lock registry dependencies =="
& $Raz update
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "== Force a completely cold package/project build =="
& $Raz cache clean
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $Raz clean
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "== Build; this must auto-download and produce a native executable =="
& $Raz build
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
if (!(Test-Path $Exe)) { throw "raz build succeeded but executable is missing: $Exe" }

Write-Host "== Run the produced executable directly =="
& $Exe
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "== Check/test/run/package graph =="
& $Raz check
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $Raz test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $Raz run
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $Raz tree
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $Raz metadata
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $Raz cache status
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "ONLINE NATIVE PACKAGE TEST PASSED"

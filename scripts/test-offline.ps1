param(
    [Parameter(Mandatory=$true)]
    [string]$Raz
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Exe = Join-Path $Root "target\debug\raz-package-demo.exe"
Set-Location $Root

# Keep the user-level ~/.raz package store populated by the online test, while
# deleting every project-local generated artifact/state file.
& $Raz clean
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$env:RAZ_OFFLINE = "1"

try {
    Write-Host "== Offline clean build from raz.toml + raz.lock + shared store =="
    & $Raz build
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    if (!(Test-Path $Exe)) { throw "offline raz build succeeded but executable is missing: $Exe" }

    Write-Host "== Run the offline-produced executable directly =="
    & $Exe
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host "== Offline check/test/run/tree =="
    & $Raz check
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $Raz test
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $Raz run
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $Raz tree
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host "OFFLINE NATIVE PACKAGE TEST PASSED"
}
finally {
    Remove-Item Env:RAZ_OFFLINE -ErrorAction SilentlyContinue
}

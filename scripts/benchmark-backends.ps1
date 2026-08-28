param(
    [string]$Raz = "raz",
    [ValidateSet("debug", "release")]
    [string]$Profile = "release"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Exe = Join-Path $Root ("target\{0}\bin\raz-package-demo.exe" -f $Profile)
Set-Location $Root

function Invoke-BackendBenchmark {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("forge", "llvm")]
        [string]$Backend
    )

    Write-Host ""
    Write-Host ("================ {0} ================" -f $Backend.ToUpperInvariant())

    # Keep the comparison fair: each backend gets a clean project artifact
    # tree, while the shared package/toolchain cache remains available.
    & $Raz clean
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    $BuildArgs = @("build", "--backend=$Backend")
    if ($Profile -eq "release") {
        $BuildArgs += "--release"
    }

    $BuildTimer = [System.Diagnostics.Stopwatch]::StartNew()
    & $Raz @BuildArgs
    $BuildTimer.Stop()
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    if (!(Test-Path $Exe)) {
        throw "build succeeded but executable is missing: $Exe"
    }

    $Size = (Get-Item $Exe).Length
    Write-Host ("build_ms: {0:N3}" -f $BuildTimer.Elapsed.TotalMilliseconds)
    Write-Host ("binary_bytes: {0}" -f $Size)
    Write-Host "runtime:"

    & $Exe
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host ("Raz native backend comparison ({0})" -f $Profile)
Invoke-BackendBenchmark -Backend "forge"
Invoke-BackendBenchmark -Backend "llvm"

Write-Host ""
Write-Host "Compare iterations_per_second (higher is better), ns_per_iteration (lower is better), build_ms, and binary_bytes."

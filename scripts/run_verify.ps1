$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot

Push-Location -LiteralPath $projectRoot
try {
    & vivado.bat -mode batch -source scripts/run_sim.tcl
    if ($LASTEXITCODE -ne 0) {
        throw "Vivado simulation failed with exit code $LASTEXITCODE"
    }

    & python scripts/verify_fft.py
    if ($LASTEXITCODE -ne 0) {
        throw "Bit-accurate FFT verification failed with exit code $LASTEXITCODE"
    }
}
finally {
    Pop-Location
}

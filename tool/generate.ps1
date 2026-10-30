# Alternative to dart run for Windows SDKs with Unicode path / AOT issues.
$ErrorActionPreference = 'Stop'
Push-Location (Split-Path $PSScriptRoot -Parent)
try {
    $config = (Resolve-Path '.dart_tool/package_config.json').Path
    $packages = Get-Content -LiteralPath $config -Raw | ConvertFrom-Json
    $package = $packages.packages | Where-Object name -EQ 'build_runner'
    $baseUri = [Uri]::new($config)
    $runnerUri = [Uri]::new($baseUri, $package.rootUri)
    $runner = Join-Path $runnerUri.LocalPath 'bin/build_runner.dart'
    & dart "--packages=$config" $runner build --force-jit
    if ($LASTEXITCODE -ne 0) { throw 'Code generation failed' }
} finally { Pop-Location }

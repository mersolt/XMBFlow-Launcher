param([string]$Manifest = (Join-Path $PSScriptRoot '..\packaging\minimal-smoke-inputs.json'))

$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'Test-XmbMinimalProfile.ps1')

$data = Get-Content -Raw $Manifest | ConvertFrom-Json
if ($data.entry_source -ne 'src/xmb-test.lua') {
    throw 'Minimal smoke manifest must stage src/xmb-test.lua as its entry source.'
}

$paths = @($data.inputs.path)
foreach ($path in @('eboot.bin', 'index.lua', 'sce_sys/**', 'LICENSE')) {
    if ($paths -notcontains $path) { throw "Minimal smoke manifest is missing required input: $path" }
}
foreach ($forbidden in @('DATA/**', 'addons/**', 'translations/**', 'payloads/**', 'boot.bin', 'boot.inf', '*.vpk', 'src/index.lua')) {
    if (@($data.exclusions) -notcontains $forbidden) { throw "Minimal smoke manifest is missing exclusion: $forbidden" }
}
if ($paths -contains 'DATA/**' -or $paths -contains 'src/index.lua') {
    throw 'Minimal smoke manifest must not include legacy DATA or the normal RetroFlow entry script.'
}

$unapproved = @($data.inputs | Where-Object { $_.status -ne 'approved' })
if ($unapproved.Count -gt 0) {
    throw "Minimal smoke packaging is blocked: unapproved inputs: $($unapproved.path -join ', ')"
}

Write-Host 'Minimal smoke inputs are approved for a future staging step.'
